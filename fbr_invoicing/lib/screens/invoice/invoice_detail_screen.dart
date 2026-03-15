import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../../models/company_model.dart';
import '../../models/invoice_model.dart';
import '../../services/pdf_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final InvoiceModel invoice;
  final CompanyModel company;

  const InvoiceDetailScreen({
    super.key,
    required this.invoice,
    required this.company,
  });

  Future<void> _viewPdf(BuildContext context) async {
    final pdfBytes = await PdfService.generateInvoicePdf(invoice, company);
    
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text('Invoice ${invoice.invoiceNo}')),
            body: PdfPreview(
              build: (format) => pdfBytes,
              canChangeOrientation: false,
              canChangePageFormat: false,
            ),
          ),
        ),
      );
    }
  }

  Future<void> _sharePdf(BuildContext context) async {
    try {
      final pdfBytes = await PdfService.generateInvoicePdf(invoice, company);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/Invoice_${invoice.invoiceNo}.pdf');
      await file.writeAsBytes(pdfBytes);
      
      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(file.path)], 
        text: 'FBR Invoice ${invoice.invoiceNo} from ${company.businessName}'
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _viewPdf(context),
            tooltip: 'View/Print PDF',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _sharePdf(context),
            tooltip: 'Share',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          children: [
            // Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.paddingM),
              decoration: BoxDecoration(
                color: invoice.fbrInvoiceNo != null ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                border: Border.all(
                  color: invoice.fbrInvoiceNo != null ? AppColors.success : AppColors.warning,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    invoice.fbrInvoiceNo != null ? Icons.check_circle : Icons.pending,
                    color: invoice.fbrInvoiceNo != null ? AppColors.success : AppColors.warning,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    invoice.fbrInvoiceNo != null ? 'Synced with FBR' : 'Draft - Not Synced',
                    style: TextStyle(
                      color: invoice.fbrInvoiceNo != null ? AppColors.success : AppColors.warning,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  if (invoice.fbrInvoiceNo != null) ...[
                    const SizedBox(height: 4),
                    Text('FBR Invoice No: ${invoice.fbrInvoiceNo}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ]
                ],
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingL),
            
            // FBR Style Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('INVOICE', style: Theme.of(context).textTheme.displayMedium),
                              const SizedBox(height: 4),
                              Text(company.businessName, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                        ),
                        if (invoice.qrCodeData != null)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Column(
                                  children: [
                                    Text('FBR', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 10)),
                                    Text('DIGITAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                                    Text('INVOICING', style: TextStyle(fontSize: 8)),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                QrImageView(
                                  data: invoice.qrCodeData!,
                                  version: QrVersions.auto,
                                  size: 60,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const Divider(height: 30),
                    
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Seller Information', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(company.businessName),
                              Text('Reg: ${company.registrationNo}'),
                              Text('NTN: ${company.ntn}'),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Buyer Information', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(invoice.buyerBusinessName),
                              Text('Reg: ${invoice.buyerRegistrationNo}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingM),
            
            // Items Table
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: invoice.items.length + 1, // +1 for header
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: const [
                          Expanded(flex: 3, child: Text('Description', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(flex: 2, child: Text('Price', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(flex: 2, child: Text('Total', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                    );
                  }
                  
                  final item = invoice.items[index - 1];
                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text(item.description)),
                        Expanded(child: Text(item.quantity.toString(), textAlign: TextAlign.center)),
                        Expanded(flex: 2, child: Text(item.unitPrice.toStringAsFixed(0), textAlign: TextAlign.right)),
                        Expanded(flex: 2, child: Text(item.total.toStringAsFixed(0), textAlign: TextAlign.right)),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingM),
            
            // Totals Card
            Card(
              color: AppColors.primary.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Subtotal:'), Text(FormatHelpers.formatCurrency(invoice.subtotal))]),
                    const SizedBox(height: 4),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Sales Tax (18%):'), Text(FormatHelpers.formatCurrency(invoice.tax))]),
                    const Divider(),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Grand Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), 
                      Text(FormatHelpers.formatCurrency(invoice.total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.primary))
                    ]),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingXL),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _viewPdf(context),
                icon: const Icon(Icons.print),
                label: const Text('PRINT INVOICE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
