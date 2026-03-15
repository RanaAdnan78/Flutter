import 'dart:convert';
import 'dart:math';
// Need to add 'http' to pubspec.yaml
import '../models/invoice_model.dart';

class FbrService {
  // Production Endpoint
  static const String _fbrEndpoint =
      'https://esp.fbr.gov.pk:8244/DigitalInvoicing/v1/PostInvoiceData_v1';

  // These should be fetched from User Settings/Firestore in a real app
  static const String _posId = '12345678';
  static const String _token = 'YOUR_BEARER_TOKEN';

  /// Generates a simulated FBR Invoice Number
  static String generateFBRInvoiceNo() {
    final now = DateTime.now();
    final dateStr =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final randomStr = Random().nextInt(999999).toString().padLeft(6, '0');
    return 'FBR-$dateStr-$randomStr';
  }

  /// Sends the invoice data to FBR Servers in real-time
  /// This is the "PRO" implementation for the actual launch
  static Future<Map<String, dynamic>> submitInvoiceRealTime(
    InvoiceModel invoice,
  ) async {
    try {
      // 1. Prepare the JSON body for FBR
      final Map<String, dynamic> body = {
        "POSID": _posId,
        "USIN": invoice.invoiceNo,
        "DateTime": invoice.date.toIso8601String(),
        "BuyerNTN": invoice.buyerRegistrationNo ?? '0',
        "BuyerName": invoice.buyerBusinessName ?? 'Guest',
        "TotalBill": invoice.total,
        "TotalTax": invoice.tax,
        "Items": invoice.items
            .map(
              (item) => {
                "ItemCode": item.itemNo,
                "ItemName": item.description,
                "Quantity": item.quantity,
                "UnitPrice": item.unitPrice,
                "TaxRate": 18.0,
                "TaxAmount": item.total * 0.18,
                "Total": item.total,
              },
            )
            .toList(),
      };

      // 2. Make the API Call (Uncomment when you have real keys)
      /*
      final response = await http.post(
        Uri.parse(_fbrEndpoint),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('FBR Error: ${response.statusCode}');
      }
      */

      // Mock response for now
      await Future.delayed(const Duration(seconds: 2));
      return {
        "FiscalInvoiceNumber": generateFBRInvoiceNo(),
        "QRData": "https://iris.fbr.gov.pk/verify/${invoice.invoiceNo}",
        "Status": "Success",
      };
    } catch (e) {
      throw Exception('FBR Connection Failed: $e');
    }
  }

  /// Generates QR Code data string containing verifiable invoice details
  static String generateQRData(InvoiceModel invoice, String fbrInvoiceNo) {
    // FBR usually requires specific JSON structure for their QR codes
    final Map<String, dynamic> qrData = {
      'seller_name':
          invoice.companyId, // Should be actual business name in a real app
      'seller_ntn': '1234567-8', // Mock NTN
      'buyer_name': invoice.buyerBusinessName,
      'buyer_ntn': invoice.buyerRegistrationNo,
      'invoice_no': invoice.invoiceNo,
      'fbr_invoice_no': fbrInvoiceNo,
      'date': invoice.date.toIso8601String(),
      'total_amount': invoice.total,
      'total_tax': invoice.tax,
    };

    return jsonEncode(qrData);
  }
}
