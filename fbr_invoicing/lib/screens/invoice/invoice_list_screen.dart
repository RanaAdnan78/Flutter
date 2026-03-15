import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/company_model.dart';
import '../../models/invoice_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import 'invoice_form_screen.dart';
import 'invoice_detail_screen.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  final FirestoreService _firestore = FirestoreService();
  CompanyModel? _selectedCompany;

  void _navigateToCreate() {
    if (_selectedCompany == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a company first'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoiceFormScreen(company: _selectedCompany!),
      ),
    );
  }

  void _viewInvoice(InvoiceModel invoice) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            InvoiceDetailScreen(invoice: invoice, company: _selectedCompany!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final userId = auth.currentUserModel?.uid;

    if (userId == null)
      return const Scaffold(body: Center(child: Text('Please login')));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Company Selector
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            color: AppColors.white,
            child: StreamBuilder<List<CompanyModel>>(
              stream: _firestore.getCompaniesStream(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator();
                }

                final companies = snapshot.data ?? [];
                if (companies.isEmpty) {
                  return const Center(
                    child: Text(
                      'Please add a company in the Companies tab first.',
                    ),
                  );
                }

                // Auto-select first company if none selected
                if (_selectedCompany == null && companies.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() => _selectedCompany = companies.first);
                  });
                }

                return DropdownButtonFormField<CompanyModel>(
                  initialValue: _selectedCompany,
                  decoration: const InputDecoration(
                    labelText: 'Select Business',
                    prefixIcon: Icon(Icons.business_center),
                  ),
                  items: companies.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Text(c.businessName),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCompany = val),
                );
              },
            ),
          ),

          const Divider(height: 1),

          // Invoice List
          Expanded(
            child: _selectedCompany == null
                ? const SizedBox()
                : StreamBuilder<List<InvoiceModel>>(
                    stream: _firestore.getInvoicesStream(
                      userId,
                      _selectedCompany!.id,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final invoices = snapshot.data ?? [];

                      if (invoices.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.receipt,
                                size: 80,
                                color: AppColors.textLight,
                              ),
                              const SizedBox(height: AppConstants.paddingM),
                              Text(
                                'No invoices yet',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: AppConstants.paddingS),
                              const Text(
                                'Click the + button to create an invoice',
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(AppConstants.paddingM),
                        itemCount: invoices.length,
                        itemBuilder: (context, index) {
                          final invoice = invoices[index];
                          return Card(
                            margin: const EdgeInsets.only(
                              bottom: AppConstants.paddingM,
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(
                                AppConstants.paddingM,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.receipt_long,
                                  color: AppColors.primary,
                                ),
                              ),
                              title: Text(
                                'Invoice #${invoice.invoiceNo}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(invoice.buyerBusinessName),
                                  const SizedBox(height: 2),
                                  Text(
                                    FormatHelpers.formatDate(invoice.date),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    FormatHelpers.formatCurrency(invoice.total),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: invoice.fbrInvoiceNo != null
                                          ? AppColors.success
                                          : AppColors.warning,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      invoice.fbrInvoiceNo != null
                                          ? 'FBR Sync'
                                          : 'Draft',
                                      style: const TextStyle(
                                        color: AppColors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () => _viewInvoice(invoice),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreate,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }
}
