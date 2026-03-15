// lib/widgets/widgets.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../config/api_config.dart';
import '../models/models.dart';
import '../utils/theme.dart';

// ── Product Card ─────────────────────────────────────────────
class ProductCard extends StatelessWidget {
  final Product      product;
  final VoidCallback onTap;
  final double?      width;

  const ProductCard({super.key, required this.product, required this.onTap, this.width});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color:        VeloxTheme.card,
          borderRadius: BorderRadius.circular(16),
          border:       Border.all(color: VeloxTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: AspectRatio(
                aspectRatio: 1.1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    product.image.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: '${ApiConfig.imgUrl}${product.image}',
                            fit: BoxFit.cover,
                            placeholder: (_, __) => _shimmer(),
                            errorWidget: (_, __, ___) => _placeholder(),
                          )
                        : _placeholder(),
                    // Badges
                    Positioned(
                      top: 8, left: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.isNew)    _badge('NEW', Colors.blue),
                          if (product.isSale)   _badge('-${product.discountPercent}%', VeloxTheme.accent),
                          if (!product.inStock) _badge('OUT', Colors.grey),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white, height: 1.3)),
                  const SizedBox(height: 4),
                  if (product.rating > 0)
                    Row(children: [
                      const Icon(Icons.star, size: 11, color: Color(AppColors.gold)),
                      const SizedBox(width: 2),
                      Text('${product.rating.toStringAsFixed(1)}',
                        style: const TextStyle(fontSize: 10, color: Color(AppColors.gold))),
                    ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    Flexible(child: Text(Fmt.price(product.effectivePrice),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(AppColors.accent)))),
                    if (product.salePrice != null) ...[
                      const SizedBox(width: 4),
                      Flexible(child: Text(Fmt.price(product.price),
                        style: const TextStyle(fontSize: 10, color: Color(AppColors.textMuted),
                          decoration: TextDecoration.lineThrough, decorationColor: Color(AppColors.textMuted)))),
                    ],
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String t, Color c) => Container(
    margin: const EdgeInsets.only(bottom: 4),
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(4)),
    child: Text(t, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
  );

  Widget _placeholder() => Container(color: const Color(0xFF1a1a2e),
    child: const Center(child: Icon(Icons.shopping_bag_outlined, color: Color(0xFF333355), size: 36)));

  Widget _shimmer() => Shimmer.fromColors(
    baseColor: const Color(0xFF1a1a2e), highlightColor: const Color(0xFF2a2a4e),
    child: Container(color: Colors.white));
}

// ── Shimmer Grid ─────────────────────────────────────────────
class ShimmerGrid extends StatelessWidget {
  const ShimmerGrid({super.key});
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 12, mainAxisSpacing: 12),
      itemCount: 6,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: const Color(0xFF1a1a2e), highlightColor: const Color(0xFF2a2a3e),
        child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)))),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final IconData     icon;
  final String       title;
  final String       subtitle;
  final String?      actionLabel;
  final VoidCallback? onAction;

  const EmptyState({super.key, required this.icon, required this.title,
    required this.subtitle, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 64, color: VeloxTheme.muted),
        const SizedBox(height: 20),
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(subtitle, textAlign: TextAlign.center,
          style: const TextStyle(color: Color(AppColors.textMuted), fontSize: 14, height: 1.6)),
        if (actionLabel != null) ...[
          const SizedBox(height: 28),
          ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ]),
    ));
  }
}

// ── VELOX App Bar ─────────────────────────────────────────────
class VeloxAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String        title;
  final List<Widget>? actions;
  final bool          showBack;

  const VeloxAppBar({super.key, required this.title, this.actions, this.showBack = true});

  @override Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title:   Text(title),
      leading: showBack ? IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        onPressed: () => Navigator.pop(context)) : null,
      actions: actions,
    );
  }
}

// ── VELOX Button ──────────────────────────────────────────────
class VeloxButton extends StatelessWidget {
  final String       label;
  final VoidCallback? onPressed;
  final bool         loading;
  final Color?       color;
  final Widget?      icon;
  final bool         outlined;

  const VeloxButton({super.key, required this.label, this.onPressed,
    this.loading = false, this.color, this.icon, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    final bg = color ?? VeloxTheme.accent;
    if (outlined) {
      return SizedBox(width: double.infinity,
        child: OutlinedButton(
          onPressed: loading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: bg), foregroundColor: bg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            padding: const EdgeInsets.symmetric(vertical: 15)),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))));
    }
    return SizedBox(width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        child: loading
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Text(label)));
  }
}

// ── Section Header ────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String        title;
  final String?       actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        if (actionLabel != null)
          TextButton(onPressed: onAction,
            child: Text(actionLabel!, style: const TextStyle(color: Color(AppColors.accent), fontSize: 13, fontWeight: FontWeight.w700))),
      ]),
    );
  }
}
