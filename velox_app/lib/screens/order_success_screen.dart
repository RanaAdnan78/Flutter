// lib/screens/order_success_screen.dart
import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../utils/theme.dart';
import '../widgets/widgets.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderNumber;
  const OrderSuccessScreen({super.key, required this.orderNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VeloxTheme.bg,
      body: SafeArea(child: Center(child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              color:  const Color(AppColors.success).withOpacity(0.12),
              shape:  BoxShape.circle,
              border: Border.all(color: const Color(AppColors.success).withOpacity(0.4), width: 2)),
            child: const Icon(Icons.check_circle_outline, color: Color(AppColors.success), size: 56)),
          const SizedBox(height: 28),
          const Text('Order Placed! 🎉', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          if (orderNumber.isNotEmpty) Text('#$orderNumber',
            style: const TextStyle(color: Color(AppColors.accent), fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          const Text('Your order has been placed successfully.\nWe\'ll prepare it right away!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(AppColors.textMuted), height: 1.7, fontSize: 14)),
          const SizedBox(height: 40),
          VeloxButton(label: 'Track My Orders',
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false)),
          const SizedBox(height: 14),
          VeloxButton(label: 'Continue Shopping', outlined: true,
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false)),
        ]),
      ))),
    );
  }
}
