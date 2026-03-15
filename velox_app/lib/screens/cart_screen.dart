// lib/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/api_config.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../utils/theme.dart';
import '../widgets/widgets.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _couponCtrl    = TextEditingController();
  bool  _applyingCoupon = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AuthProvider>().isLoggedIn) context.read<CartProvider>().load();
    });
  }

  Future<void> _applyCoupon() async {
    final code = _couponCtrl.text.trim().toUpperCase();
    if (code.isEmpty) return;
    setState(() => _applyingCoupon = true);
    final err = await context.read<CartProvider>().applyCoupon(code);
    if (!mounted) return;
    setState(() => _applyingCoupon = false);
    _couponCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(err ?? '✓ Coupon applied!'),
      backgroundColor: err == null ? const Color(AppColors.success) : const Color(AppColors.error)));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();

    if (!auth.isLoggedIn) {
      return Scaffold(
        backgroundColor: VeloxTheme.bg,
        appBar: const VeloxAppBar(title: 'My Cart', showBack: false),
        body: EmptyState(icon: Icons.lock_outline, title: 'Login Required',
          subtitle: 'Please login to view your cart.', actionLabel: 'Login',
          onAction: () => Navigator.pushNamed(context, '/login')));
    }

    return Scaffold(
      backgroundColor: VeloxTheme.bg,
      appBar: VeloxAppBar(title: 'Cart (${cart.count})', showBack: false,
        actions: [if (cart.count > 0) TextButton(onPressed: cart.clear,
          child: const Text('Clear', style: TextStyle(color: Color(AppColors.error))))]),
      body: cart.loading
          ? const Center(child: CircularProgressIndicator())
          : cart.isEmpty
              ? EmptyState(icon: Icons.shopping_bag_outlined, title: 'Cart is Empty',
                  subtitle: 'Add some shoes!', actionLabel: 'Shop Now',
                  onAction: () => Navigator.pushNamed(context, '/products'))
              : Column(children: [
                  Expanded(child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: cart.items.length,
                    itemBuilder: (_, i) => _CartTile(item: cart.items[i]),
                  )),

                  // SUMMARY
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color:        Color(0xFF16161f),
                      border:       Border(top: BorderSide(color: Color(0xFF22222e))),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
                    child: Column(children: [
                      // Coupon
                      Row(children: [
                        Expanded(child: TextField(controller: _couponCtrl,
                          decoration: const InputDecoration(hintText: 'Coupon code...', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                          textCapitalization: TextCapitalization.characters)),
                        const SizedBox(width: 8),
                        ElevatedButton(onPressed: _applyingCoupon ? null : _applyCoupon,
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13)),
                          child: _applyingCoupon
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Apply')),
                      ]),
                      if (cart.couponCode != null) Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(children: [
                          const Icon(Icons.check_circle, color: Color(AppColors.success), size: 16),
                          const SizedBox(width: 6),
                          Text('${cart.couponCode} applied!', style: const TextStyle(color: Color(AppColors.success), fontSize: 13, fontWeight: FontWeight.w600)),
                          const Spacer(),
                          TextButton(onPressed: cart.removeCoupon,
                            child: const Text('Remove', style: TextStyle(color: Color(AppColors.error), fontSize: 12))),
                        ])),
                      const SizedBox(height: 14),
                      _row('Subtotal', Fmt.price(cart.subtotal)),
                      _row('Shipping', cart.shipping == 0 ? 'FREE ✓' : Fmt.price(cart.shipping),
                        vc: cart.shipping == 0 ? const Color(AppColors.success) : null),
                      if (cart.discount > 0) _row('Discount', '-${Fmt.price(cart.discount)}', vc: const Color(AppColors.success)),
                      const Divider(color: Color(0xFF22222e), height: 22),
                      _row('Total', Fmt.price(cart.total), bold: true, fs: 18),
                      const SizedBox(height: 14),
                      VeloxButton(label: 'Proceed to Checkout →',
                        onPressed: () => Navigator.pushNamed(context, '/checkout')),
                    ]),
                  ),
                ]),
    );
  }

  Widget _row(String l, String v, {bool bold = false, double fs = 14, Color? vc}) =>
    Padding(padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(l, style: TextStyle(color: bold ? Colors.white : const Color(AppColors.textMuted), fontWeight: bold ? FontWeight.w800 : FontWeight.normal, fontSize: fs)),
        Text(v, style: TextStyle(fontWeight: bold ? FontWeight.w900 : FontWeight.w600, fontSize: fs, color: vc ?? Colors.white)),
      ]));

  @override void dispose() { _couponCtrl.dispose(); super.dispose(); }
}

class _CartTile extends StatelessWidget {
  final CartItem item;
  const _CartTile({required this.item});
  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:        VeloxTheme.card,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: VeloxTheme.border)),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImage(
            imageUrl: '${ApiConfig.imgUrl}${item.image}',
            width: 70, height: 70, fit: BoxFit.cover,
            errorWidget: (_, __, ___) => Container(width: 70, height: 70, color: const Color(0xFF1a1a2e),
              child: const Icon(Icons.image_not_supported_outlined, color: Color(0xFF333355)))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 3),
          Text('${item.size} · ${item.color}', style: const TextStyle(color: Color(AppColors.textMuted), fontSize: 12)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(Fmt.price(item.lineTotal), style: const TextStyle(fontWeight: FontWeight.w800, color: Color(AppColors.accent))),
            Row(children: [
              GestureDetector(
                onTap: () => cart.remove(item.id),
                child: Container(padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: const Color(0xFF3a1a1a), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.delete_outline, color: Color(AppColors.error), size: 16))),
            ]),
          ]),
        ])),
      ]),
    );
  }
}
