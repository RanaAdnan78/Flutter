// lib/screens/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../config/api_config.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../utils/theme.dart';
import '../widgets/widgets.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});
  @override State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? _size;
  String? _color;
  int     _qty        = 1;
  bool    _adding     = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    if (p.sizeList.isNotEmpty)  _size  = p.sizeList.first;
    if (p.colorList.isNotEmpty) _color = p.colorList.first;
  }

  Future<void> _addToCart() async {
    if (!context.read<AuthProvider>().isLoggedIn) {
      Navigator.pushNamed(context, '/login'); return;
    }
    if (_size == null || _color == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select size and color')));
      return;
    }
    setState(() => _adding = true);
    final err = await context.read<CartProvider>().add(widget.product.id, _qty, _size!, _color!);
    if (!mounted) return;
    setState(() => _adding = false);
    if (err == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('✓ Added to cart!'),
        backgroundColor: const Color(AppColors.success),
        action: SnackBarAction(label: 'View Cart', textColor: Colors.white,
          onPressed: () => Navigator.pushNamed(context, '/cart'))));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: const Color(AppColors.error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Scaffold(
      backgroundColor: VeloxTheme.bg,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          backgroundColor: VeloxTheme.primary,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: VeloxTheme.card,
              child: p.image.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: '${ApiConfig.imgUrl}${p.image}',
                      fit: BoxFit.contain,
                      placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (_, __, ___) => const Icon(Icons.shopping_bag_outlined, size: 80, color: Color(0xFF333355)),
                    )
                  : const Icon(Icons.shopping_bag_outlined, size: 80, color: Color(0xFF333355)),
            ),
          ),
        ),

        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Category / Brand
            Wrap(spacing: 8, children: [
              if (p.category != null) _chip(p.category!, VeloxTheme.accent.withOpacity(0.15), VeloxTheme.accent),
              if (p.brand    != null) _chip(p.brand!,    VeloxTheme.card, VeloxTheme.muted),
              if (p.isNew)            _chip('NEW',        Colors.blue, Colors.white),
              if (p.isSale)           _chip('-${p.discountPercent}%', VeloxTheme.accent, Colors.white),
            ]),

            const SizedBox(height: 12),
            Text(p.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.3)),
            const SizedBox(height: 10),

            // Price
            Row(children: [
              Text(Fmt.price(p.effectivePrice),
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(AppColors.accent))),
              if (p.salePrice != null) ...[
                const SizedBox(width: 10),
                Text(Fmt.price(p.price),
                  style: const TextStyle(fontSize: 16, color: Color(AppColors.textMuted),
                    decoration: TextDecoration.lineThrough, decorationColor: Color(AppColors.textMuted))),
              ],
            ]),
            const SizedBox(height: 10),

            // Rating + Stock
            Row(children: [
              if (p.rating > 0) ...[
                RatingBarIndicator(rating: p.rating, itemSize: 16,
                  itemBuilder: (_, __) => const Icon(Icons.star, color: Color(AppColors.gold))),
                const SizedBox(width: 6),
                Text('${p.rating.toStringAsFixed(1)} (${p.reviewsCount})',
                  style: const TextStyle(fontSize: 12, color: Color(AppColors.textMuted))),
                const Spacer(),
              ],
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: p.inStock ? const Color(0xFF1a3a2a) : const Color(0xFF3a1a1a),
                  borderRadius: BorderRadius.circular(50)),
                child: Text(p.inStock ? '✓ In Stock' : '✗ Out of Stock',
                  style: TextStyle(color: p.inStock ? const Color(AppColors.success) : const Color(AppColors.error),
                    fontSize: 12, fontWeight: FontWeight.w700))),
            ]),

            const SizedBox(height: 24),
            const Divider(color: Color(0xFF22222e)),
            const SizedBox(height: 18),

            // SIZES
            if (p.sizeList.isNotEmpty) ...[
              const Text('Select Size', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8,
                children: p.sizeList.map((s) {
                  final sel = s == _size;
                  return GestureDetector(
                    onTap: () => setState(() => _size = s),
                    child: Container(
                      width: 50, height: 40,
                      decoration: BoxDecoration(
                        color:        sel ? VeloxTheme.accent : VeloxTheme.card,
                        border:       Border.all(color: sel ? VeloxTheme.accent : VeloxTheme.border, width: 1.5),
                        borderRadius: BorderRadius.circular(10)),
                      child: Center(child: Text(s,
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12,
                          color: sel ? Colors.white : const Color(AppColors.textMuted))))));
                }).toList()),
              const SizedBox(height: 18),
            ],

            // COLORS
            if (p.colorList.isNotEmpty) ...[
              const Text('Select Color', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8,
                children: p.colorList.map((c) {
                  final sel = c == _color;
                  return GestureDetector(
                    onTap: () => setState(() => _color = c),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color:        sel ? VeloxTheme.accent.withOpacity(0.12) : VeloxTheme.card,
                        border:       Border.all(color: sel ? VeloxTheme.accent : VeloxTheme.border, width: 1.5),
                        borderRadius: BorderRadius.circular(50)),
                      child: Text(c, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12,
                        color: sel ? VeloxTheme.accent : const Color(AppColors.textMuted)))));
                }).toList()),
              const SizedBox(height: 18),
            ],

            // QUANTITY
            Row(children: [
              const Text('Quantity', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              const Spacer(),
              Container(
                decoration: BoxDecoration(color: VeloxTheme.card, borderRadius: BorderRadius.circular(50), border: Border.all(color: VeloxTheme.border)),
                child: Row(children: [
                  IconButton(icon: const Icon(Icons.remove, size: 18), onPressed: _qty > 1 ? () => setState(() => _qty--) : null),
                  SizedBox(width: 32, child: Center(child: Text('$_qty', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)))),
                  IconButton(icon: const Icon(Icons.add, size: 18), onPressed: _qty < p.stock ? () => setState(() => _qty++) : null),
                ]),
              ),
            ]),

            const SizedBox(height: 20),
            const Divider(color: Color(0xFF22222e)),
            const SizedBox(height: 14),

            // DESCRIPTION
            const Text('Description', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 8),
            Text(p.description, style: const TextStyle(color: Color(AppColors.textMuted), height: 1.7, fontSize: 14)),
            const SizedBox(height: 100),
          ]),
        )),
      ]),
      bottomNavigationBar: SafeArea(child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: VeloxButton(
          label:     _adding ? 'Adding...' : 'Add to Cart 🛒',
          loading:   _adding,
          onPressed: p.inStock ? _addToCart : null),
      )),
    );
  }

  Widget _chip(String label, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    margin:  const EdgeInsets.only(bottom: 6),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(50),
      border: Border.all(color: fg.withOpacity(0.3))),
    child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg)));
}
