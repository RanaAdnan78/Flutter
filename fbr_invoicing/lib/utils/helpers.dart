import 'package:intl/intl.dart';

class FormatHelpers {
  static String formatCurrency(double amount) {
    final format = NumberFormat.currency(
      locale: 'en_PK',
      symbol: 'Rs. ',
      decimalDigits: 2,
    );
    return format.format(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  static String formatPhone(String phone) {
    // Add spaces to make phone numbers readable, e.g. +92 333 1234567
    if (phone.length == 13 && phone.startsWith('+92')) {
      return '${phone.substring(0, 3)} ${phone.substring(3, 6)} ${phone.substring(6)}';
    }
    return phone;
  }
}

class ValidationHelpers {
  static String? validateEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    // Simple verification for Pakistani pattern +923XX... or 03XX...
    final regex = RegExp(r'^(\+92|0)?3\d{2}\d{7}$');
    if (!regex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Please enter a valid Pakistani mobile number';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Optional fields
    
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }
}
