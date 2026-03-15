// lib/utils/theme.dart
import 'package:flutter/material.dart';
import '../config/api_config.dart';

class VeloxTheme {
  static const Color primary  = Color(AppColors.primary);
  static const Color accent   = Color(AppColors.accent);
  static const Color gold     = Color(AppColors.gold);
  static const Color surface  = Color(AppColors.surface);
  static const Color muted    = Color(AppColors.textMuted);
  static const Color bg       = Color(0xFF0f0f1a);
  static const Color card     = Color(0xFF16161f);
  static const Color border   = Color(0xFF22222e);
  static const Color darkInput = Color(0xFF1a1a30);

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness:   Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.dark(
      primary:  accent,
      secondary: gold,
      surface:  surface,
      error:    const Color(AppColors.error),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor:  primary,
      foregroundColor:  Colors.white,
      elevation:        0,
      centerTitle:      true,
      titleTextStyle:   TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        padding:         const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        minimumSize:     const Size.fromHeight(52),
        textStyle:       const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled:        true,
      fillColor:     darkInput,
      border:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(AppColors.accent), width: 1.5)),
      hintStyle:     const TextStyle(color: Color(AppColors.textMuted)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    ),
    cardTheme: CardThemeData(
      color:   card,
      elevation: 0,
      shape:   RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF22222e))),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor:     primary,
      selectedItemColor:   accent,
      unselectedItemColor: Color(AppColors.textMuted),
      type:                BottomNavigationBarType.fixed,
      elevation:           0,
    ),
  );
}

class Fmt {
  static String price(double p) {
    final n = p.toStringAsFixed(0);
    final buf = StringBuffer();
    int count = 0;
    for (int i = n.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write(',');
      buf.write(n[i]);
      count++;
    }
    return 'Rs. ${buf.toString().split('').reversed.join()}';
  }

  static String date(String iso) {
    try {
      final d = DateTime.parse(iso);
      const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${d.day} ${m[d.month - 1]} ${d.year}';
    } catch (_) { return iso; }
  }

  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':    return Colors.orange;
      case 'confirmed':  return Colors.blue;
      case 'processing': return Colors.indigo;
      case 'shipped':    return Colors.cyan;
      case 'delivered':  return const Color(AppColors.success);
      case 'cancelled':  return const Color(AppColors.error);
      default:           return Colors.grey;
    }
  }
}
