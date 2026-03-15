import 'package:flutter/material.dart';

class AppColors {
  // FBR Branding Colors (Red/White)
  static const Color primary = Color(0xFFD32F2F); // FBR Red
  static const Color primaryDark = Color(0xFFB71C1C);
  static const Color primaryLight = Color(0xFFFF6659);
  
  static const Color background = Color(0xFFF5F6FA);
  static const Color white = Colors.white;
  static const Color black = Colors.black87;
  
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textLight = Color(0xFFBDC3C7);
  
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53935);
  
  static const Color border = Color(0xFFE0E0E0);
  static const Color cardShadow = Color(0x1A000000); // 10% black
}

class AppConstants {
  static const String appName = 'FBR Digital Invoicing';
  static const String currency = 'PKR';
  
  // Padding & Margins
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  
  // Border Radius
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;
}
