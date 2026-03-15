// lib/screens/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/api_config.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';
import '../widgets/widgets.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addrCtrl  = TextEditingController();
  final _cityCtrl  = TextEditingController();
  String _payment  = 'cod';
  bool   _placing  = false;

  static const _payments = {
    'cod':       '💵 Cash on Delivery',
    'easypaisa': '📱 EasyPaisa',
    'jazz':      '📱 JazzCash',
    'card':      '💳 Debit / Credit Card',
  };

  @override
  void initState() {
    super.initState();
    final u = context.read<AuthProvider>().user;
    if (u != null) {
      _nameCtrl.text  = u.fullName;
      _emailCtrl.text = u.email;
      _phoneCtrl.text = u.phone   ?? '';
      _addrCtrl.text  = u.address ?? '';
      _cityCtrl.text  = u.city    ?? '';
    }
  }

  Future<void> _place() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _placing = true);
    final res = await ApiService().placeOrder(
      fullName: _nameCtrl.text, email: _emailCtrl.text,
      phone:    _phoneCtrl.text, address: _addrCtrl.text,
      city:     _cityCtrl.text,  paymentMethod: _payment);
    if (!mounted) return;
    setState(() => _placing = false);
    if (res['success'] == true) {
      context.read<CartProvider>().reset();
      Navigator.pushReplacementNamed(context, '/order-success', arguments: res['order_number'] ?? '');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res['message'] ?? 'Failed'), backgroundColor: const Color(AppColors.error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      backgroundColor: VeloxTheme.bg,
      appBar: const VeloxAppBar(title: 'Checkout'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          _sec('📦 Delivery Information'),
          const SizedBox(height: 14),
          _fld(_nameCtrl,  'Full Name',      Icons.person_outline),
          const SizedBox(height: 12),
          _fld(_emailCtrl, 'Email',          Icons.email_outlined,    kb: TextInputType.emailAddress),
          const SizedBox(height: 12),
          _fld(_phoneCtrl, 'Phone Number',   Icons.phone_outlined,    kb: TextInputType.phone),
          const SizedBox(height: 12),
          _fld(_addrCtrl,  'Street Address', Icons.location_on_outlined, maxLines: 2),
          const SizedBox(height: 12),
          _fld(_cityCtrl,  'City',           Icons.location_city_outlined),

          const SizedBox(height: 28),
          _sec('💳 Payment Method'),
          const SizedBox(height: 14),
          ..._payments.entries.map((e) => GestureDetector(
            onTap: () => setState(() => _payment = e.key),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _payment == e.key ? VeloxTheme.accent.withOpacity(0.1) : VeloxTheme.card,
                border: Border.all(color: _payment == e.key ? VeloxTheme.accent : VeloxTheme.border, width: 1.5),
                borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                Text(e.value, style: TextStyle(fontWeight: FontWeight.w600,
                  color: _payment == e.key ? VeloxTheme.accent : Colors.white)),
                const Spacer(),
                if (_payment == e.key) Icon(Icons.check_circle, color: VeloxTheme.accent, size: 20),
              ])),
          )).toList(),

          const SizedBox(height: 28),
          _sec('📋 Order Summary'),
          const SizedBox(height: 14),
          Container(padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: VeloxTheme.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: VeloxTheme.border)),
            child: Column(children: [
              _row('Subtotal', Fmt.price(cart.subtotal)),
              _row('Shipping', cart.shipping == 0 ? 'FREE ✓' : Fmt.price(cart.shipping),
                vc: cart.shipping == 0 ? const Color(AppColors.success) : null),
              if (cart.discount > 0) _row('Discount', '-${Fmt.price(cart.discount)}', vc: const Color(AppColors.success)),
              const Divider(color: Color(0xFF22222e), height: 22),
              _row('Total', Fmt.price(cart.total), bold: true, fs: 18),
            ])),
          const SizedBox(height: 24),
          VeloxButton(label: _placing ? 'Placing Order...' : 'Place Order ✓', loading: _placing, onPressed: _place),
          const SizedBox(height: 24),
        ])),
      ),
    );
  }

  Widget _sec(String t) => Text(t, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800));

  Widget _fld(TextEditingController c, String hint, IconData icon, {TextInputType? kb, int maxLines = 1}) =>
    TextFormField(controller: c, keyboardType: kb, maxLines: maxLines,
      decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon)),
      validator: (v) => (v?.isEmpty ?? true) ? '$hint required' : null);

  Widget _row(String l, String v, {bool bold = false, double fs = 14, Color? vc}) =>
    Padding(padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(l, style: TextStyle(color: bold ? Colors.white : const Color(AppColors.textMuted), fontWeight: bold ? FontWeight.w800 : FontWeight.normal, fontSize: fs)),
        Text(v, style: TextStyle(fontWeight: bold ? FontWeight.w900 : FontWeight.w600, fontSize: fs, color: vc ?? Colors.white)),
      ]));

  @override void dispose() { _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose(); _addrCtrl.dispose(); _cityCtrl.dispose(); super.dispose(); }
}
