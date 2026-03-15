// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/api_config.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../utils/theme.dart';
import '../widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = ApiService();
  List<Category> _cats     = [];
  List<Product>  _featured = [];
  List<Product>  _newArr   = [];
  List<Product>  _sale     = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AuthProvider>().isLoggedIn) context.read<CartProvider>().load();
    });
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await Future.wait([
        _api.getCategories(),
        _api.getProducts(filter: 'featured', limit: 8),
        _api.getProducts(filter: 'new',      limit: 8),
        _api.getProducts(filter: 'sale',     limit: 8),
      ]);
      if (!mounted) return;
      setState(() {
        _cats     = res[0] as List<Category>;
        _featured = ((res[1] as Map)['products'] as List<Product>);
        _newArr   = ((res[2] as Map)['products'] as List<Product>);
        _sale     = ((res[3] as Map)['products'] as List<Product>);
        _loading  = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().count;

    return Scaffold(
      backgroundColor: VeloxTheme.bg,
      body: RefreshIndicator(
        onRefresh: _load,
        color: VeloxTheme.accent,
        child: CustomScrollView(
          slivers: [
            // APP BAR
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              stretch: true,
              backgroundColor: VeloxTheme.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [Color(0xFF1a1a2e), Color(0xFF0f2040)]),
                  ),
                  child: SafeArea(child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 50),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Row(children: [
                        Text('VELOX', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 4, color: Colors.white)),
                      ]),
                      const SizedBox(height: 14),
                      const Text('Premium Footwear 👟',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                      const Text('Walk the Future ✦',
                        style: TextStyle(color: Color(AppColors.accent), fontSize: 13)),
                    ]),
                  )),
                ),
                collapseMode: CollapseMode.pin,
                title: const Text('VELOX', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 3)),
              ),
              actions: [
                IconButton(icon: const Icon(Icons.search), onPressed: () => Navigator.pushNamed(context, '/search')),
                Stack(clipBehavior: Clip.none, children: [
                  IconButton(icon: const Icon(Icons.shopping_bag_outlined), onPressed: () => Navigator.pushNamed(context, '/cart')),
                  if (cartCount > 0) Positioned(right: 6, top: 6,
                    child: Container(width: 16, height: 16,
                      decoration: const BoxDecoration(color: Color(AppColors.accent), shape: BoxShape.circle),
                      child: Center(child: Text('$cartCount', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white))))),
                ]),
                const SizedBox(width: 4),
              ],
            ),

            // SEARCH TAP
            SliverToBoxAdapter(
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/search'),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    decoration: BoxDecoration(
                      color: VeloxTheme.card, borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: VeloxTheme.border)),
                    child: const Row(children: [
                      Icon(Icons.search, color: Color(AppColors.textMuted), size: 20),
                      SizedBox(width: 10),
                      Text('Search shoes, brands...', style: TextStyle(color: Color(AppColors.textMuted), fontSize: 14)),
                    ]),
                  ),
                ),
              ),
            ),

            if (_loading) const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.only(top: 20), child: ShimmerGrid())),

            if (!_loading) ...[
              // CATEGORIES
              if (_cats.isNotEmpty) ...[
                SliverToBoxAdapter(child: SectionHeader(title: 'Categories',
                  actionLabel: 'See All', onAction: () => Navigator.pushNamed(context, '/products'))),
                SliverToBoxAdapter(child: SizedBox(
                  height: 90,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemCount: _cats.length,
                    itemBuilder: (_, i) => _CatChip(cat: _cats[i],
                      onTap: () => Navigator.pushNamed(context, '/products',
                        arguments: {'categoryId': _cats[i].id, 'title': _cats[i].name})),
                  ),
                )),
              ],

              // SALE BANNER
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/products', arguments: {'filter': 'sale', 'title': 'On Sale'}),
                  child: Container(
                    height: 110,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFe94560), Color(0xFF9b2335)]),
                      borderRadius: BorderRadius.circular(18)),
                    padding: const EdgeInsets.all(20),
                    child: const Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('MEGA SALE 🔥', style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w700)),
                        SizedBox(height: 4),
                        Text('Up to 50% Off', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                        Text('On selected footwear', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      ])),
                      Text('👟', style: TextStyle(fontSize: 48)),
                    ]),
                  ),
                ),
              )),

              // FEATURED
              if (_featured.isNotEmpty) ...[
                SliverToBoxAdapter(child: SectionHeader(title: '⭐ Featured',
                  actionLabel: 'View All', onAction: () => Navigator.pushNamed(context, '/products', arguments: {'filter': 'featured', 'title': 'Featured'}))),
                SliverToBoxAdapter(child: _HorizList(products: _featured)),
              ],

              // NEW ARRIVALS
              if (_newArr.isNotEmpty) ...[
                SliverToBoxAdapter(child: SectionHeader(title: '🆕 New Arrivals',
                  actionLabel: 'View All', onAction: () => Navigator.pushNamed(context, '/products', arguments: {'filter': 'new', 'title': 'New Arrivals'}))),
                SliverToBoxAdapter(child: _HorizList(products: _newArr)),
              ],

              // ON SALE
              if (_sale.isNotEmpty) ...[
                SliverToBoxAdapter(child: SectionHeader(title: '🔥 On Sale',
                  actionLabel: 'View All', onAction: () => Navigator.pushNamed(context, '/products', arguments: {'filter': 'sale', 'title': 'On Sale'}))),
                SliverToBoxAdapter(child: _HorizList(products: _sale)),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          ],
        ),
      ),
    );
  }
}

class _CatChip extends StatelessWidget {
  final Category     cat;
  final VoidCallback onTap;
  const _CatChip({required this.cat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color:        VeloxTheme.card,
            borderRadius: BorderRadius.circular(16),
            border:       Border.all(color: VeloxTheme.border)),
          child: const Icon(Icons.category_outlined, color: Color(AppColors.accent), size: 24),
        ),
        const SizedBox(height: 5),
        SizedBox(width: 64, child: Text(cat.name, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, color: Color(AppColors.textMuted)),
          maxLines: 1, overflow: TextOverflow.ellipsis)),
      ]),
    );
  }
}

class _HorizList extends StatelessWidget {
  final List<Product> products;
  const _HorizList({required this.products});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: products.length,
        itemBuilder: (_, i) => ProductCard(
          product: products[i], width: 155,
          onTap: () => Navigator.pushNamed(context, '/product', arguments: products[i]),
        ),
      ),
    );
  }
}
