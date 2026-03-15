import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/company_model.dart';
import '../../models/invoice_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/fbr_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import 'dart:math';

class InvoiceFormScreen extends StatefulWidget {
  final CompanyModel company;

  const InvoiceFormScreen({super.key, required this.company});

  @override
  State<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends State<InvoiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestore = FirestoreService();
  bool _isLoading = false;

  final TextEditingController _buyerNameController = TextEditingController();
  final TextEditingController _buyerRegController = TextEditingController();
  final TextEditingController _buyerProvinceController = TextEditingController();
  final List<InvoiceItem> _items = [];
  
  double get _subtotal => _items.fold(0, (sum, item) => sum + item.total);
  double get _tax => _subtotal * 0.18; // Flat 18% GST standard in Pakistan
  double get _total => _subtotal + _tax;

  @override
  void dispose() {
    _buyerNameController.dispose();
    _buyerRegController.dispose();
    _buyerProvinceController.dispose();
    super.dispose();
  }

  void _addItem() {
    // Show dialog to add item
    final descController = TextEditingController();
    final qtyController = TextEditingController(text: '1');
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: qtyController,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Unit Price'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final qty = int.tryParse(qtyController.text) ?? 1;
              final price = double.tryParse(priceController.text) ?? 0.0;
              
              if (descController.text.isNotEmpty && price > 0) {
                setState(() {
                  _items.add(InvoiceItem(
                    itemNo: (_items.length + 1).toString().padLeft(3, '0'),
                    description: descController.text,
                    quantity: qty,
                    unitPrice: price,
                    total: qty * price,
                  ));
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitInvoice() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one item')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      final userId = auth.currentUserModel?.uid;
      
      if (userId == null) throw Exception('User not logged in');

      // 1. Create Base Invoice
      final invoiceId = DateTime.now().millisecondsSinceEpoch.toString();
      final invoiceNo = 'INV-${Random().nextInt(9999).toString().padLeft(4, '0')}';
      
      var invoice = InvoiceModel(
        id: invoiceId,
        companyId: widget.company.id,
        invoiceNo: invoiceNo,
        date: DateTime.now(),
        invoiceType: 'Standard',
        buyerBusinessName: _buyerNameController.text.trim(),
        buyerRegistrationNo: _buyerRegController.text.trim(),
        buyerProvince: _buyerProvinceController.text.trim(),
        items: _items,
        subtotal: _subtotal,
        tax: _tax,
        total: _total,
        status: 'Draft',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 2. Submit to Real-Time FBR Service
      final fbrResult = await FbrService.submitInvoiceRealTime(invoice);
      final fbrInvoiceNo = fbrResult['FiscalInvoiceNumber'];
      final qrData = fbrResult['QRData'];

      // 3. Update Invoice with FBR Details
      invoice = InvoiceModel(
        id: invoice.id,
        companyId: invoice.companyId,
        invoiceNo: invoice.invoiceNo,
        fbrInvoiceNo: fbrInvoiceNo,
        date: invoice.date,
        invoiceType: invoice.invoiceType,
        buyerBusinessName: invoice.buyerBusinessName,
        buyerRegistrationNo: invoice.buyerRegistrationNo,
        buyerProvince: invoice.buyerProvince,
        items: invoice.items,
        subtotal: invoice.subtotal,
        tax: invoice.tax,
        total: invoice.total,
        status: 'Submitted',
        qrCodeData: qrData,
        createdAt: invoice.createdAt,
        updatedAt: invoice.updatedAt,
      );

      // 4. Save to Firestore
      await _firestore.addInvoice(userId, invoice);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice created & synced with FBR'), backgroundColor: AppColors.success));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create FBR Invoice')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          children: [
            // Seller Info block (Read-only)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Seller Information', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    const SizedBox(height: 8),
                    Text(widget.company.businessName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('NTN: ${widget.company.ntn}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingM),

            // Buyer Info
            const Text('Buyer Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: AppConstants.paddingS),
            TextFormField(
              controller: _buyerNameController,
              decoration: const InputDecoration(labelText: 'Buyer Business Name *'),
              validator: (v) => ValidationHelpers.validateEmpty(v, 'Buyer Name'),
            ),
            const SizedBox(height: AppConstants.paddingS),
            TextFormField(
              controller: _buyerRegController,
              decoration: const InputDecoration(labelText: 'Buyer Registration/NTN *'),
              validator: (v) => ValidationHelpers.validateEmpty(v, 'Buyer Registration'),
            ),
            const SizedBox(height: AppConstants.paddingS),
            TextFormField(
              controller: _buyerProvinceController,
              decoration: const InputDecoration(labelText: 'Buyer Province *'),
              validator: (v) => ValidationHelpers.validateEmpty(v, 'Province'),
            ),
            const SizedBox(height: AppConstants.paddingL),

            // Items
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                ),
              ],
            ),
            
            if (_items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text('No items added. Click + Add Item')),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                itemBuilder: (context, i) {
                  final item = _items[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(item.description),
                      subtitle: Text('${item.quantity} x ${FormatHelpers.formatCurrency(item.unitPrice)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(FormatHelpers.formatCurrency(item.total), style: const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.delete, color: AppColors.error),
                            onPressed: () => setState(() => _items.removeAt(i)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: AppConstants.paddingM),
            
            // Totals
            Card(
              color: AppColors.primaryLight.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Subtotal:'), Text(FormatHelpers.formatCurrency(_subtotal))]),
                    const SizedBox(height: 4),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Sales Tax (18%):'), Text(FormatHelpers.formatCurrency(_tax))]),
                    const Divider(),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), 
                      Text(FormatHelpers.formatCurrency(_total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary))
                    ]),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppConstants.paddingXL),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitInvoice,
              child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.white))
                : const Text('SUBMIT & GENERATE INVOICE'),
            ),
            const SizedBox(height: AppConstants.paddingXL),
          ],
        ),
      ),
    );
  }
}
