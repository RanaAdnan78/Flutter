import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/invoice_model.dart';
import '../models/company_model.dart';

class PdfService {
  static Future<Uint8List> generateInvoicePdf(
    InvoiceModel invoice,
    CompanyModel company,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            _buildHeader(invoice, company),
            pw.SizedBox(height: 20),
            _buildInfoSection(invoice, company),
            pw.SizedBox(height: 20),
            _buildItemsTable(invoice),
            pw.SizedBox(height: 20),
            _buildTotals(invoice),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(InvoiceModel invoice, CompanyModel company) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Invoice',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              company.businessName,
              style: pw.TextStyle(fontSize: 16, color: PdfColors.red800),
            ),
          ],
        ),
        if (invoice.fbrInvoiceNo != null)
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Row(
              children: [
                pw.Text(
                  'FBR\nDIGITAL\nINVOICING',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(width: 8),
                if (invoice.qrCodeData != null)
                  pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: invoice.qrCodeData!,
                    width: 50,
                    height: 50,
                  ),
              ],
            ),
          ),
      ],
    );
  }

  static pw.Widget _buildInfoSection(
    InvoiceModel invoice,
    CompanyModel company,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Seller Information',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.Text('Business Name: ${company.businessName}'),
              pw.Text('Registration No: ${company.registrationNo}'),
              pw.Text('NTN: ${company.ntn}'),
              pw.Text('Province: ${company.province}'),
            ],
          ),
        ),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Buyer Information',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.Text('Business Name: ${invoice.buyerBusinessName}'),
              pw.Text('Registration No: ${invoice.buyerRegistrationNo}'),
              pw.Text('Province: ${invoice.buyerProvince}'),
            ],
          ),
        ),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Invoice Summary',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.Text('FBR Invoice No: ${invoice.fbrInvoiceNo ?? "N/A"}'),
              pw.Text(
                'Date: ${DateFormat('dd MMM yyyy').format(invoice.date)}',
              ),
              pw.Text('Invoice Type: ${invoice.invoiceType}'),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildItemsTable(InvoiceModel invoice) {
    const tableHeaders = [
      'Item',
      'Description',
      'Quantity',
      'Unit Price',
      'Total',
    ];

    return pw.TableHelper.fromTextArray(
      headers: tableHeaders,
      data: invoice.items.map((item) {
        return [
          item.itemNo,
          item.description,
          item.quantity.toString(),
          item.unitPrice.toStringAsFixed(2),
          item.total.toStringAsFixed(2),
        ];
      }).toList(),
      border: null,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
      },
      rowDecoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
      ),
    );
  }

  static pw.Widget _buildTotals(InvoiceModel invoice) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Row(
        children: [
          pw.Spacer(flex: 6),
          pw.Expanded(
            flex: 4,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Subtotal:'),
                    pw.Text('Rs. ${invoice.subtotal.toStringAsFixed(2)}'),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Sales Tax:'),
                    pw.Text('Rs. ${invoice.tax.toStringAsFixed(2)}'),
                  ],
                ),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Total:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Rs. ${invoice.total.toStringAsFixed(2)}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
