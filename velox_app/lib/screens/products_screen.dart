// lib/screens/products_screen.dart
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';
import '../widgets/widgets.dart';

class ProductsScreen extends StatefulWidget {
  final int?    categoryId;
  final String? filter;
  final String  title;

  const ProductsScreen({super.key, this.categoryId, this.filter, this.title = 'All Products'});
  @override State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _api    = ApiService();
  List<Product> _products = [];
  bool          _loading  = true;
  String        _sort     = 'newest';

  static const _sorts = {
    'newest':     'Newest',
    'popular':    'Popular',
    'rating':     'Top Rated',
    'price_low':  'Price: Low → High',
    'price_high': 'Price: High → Low',
  };

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await _api.getProducts(
      categoryId: widget.categoryId,
      filter:     widget.filter,
      sort:       _sort,
      limit:      40,
    );
    if (!mounted) return;
    setState(() { _products = data['products']; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VeloxTheme.bg,
      appBar: VeloxAppBar(
        title: widget.title,
        actions: [
          PopupMenuButton<String>(
            icon:       const Icon(Icons.sort),
            color:      VeloxTheme.card,
            onSelected: (v) { _sort = v; _load(); },
            itemBuilder: (_) => _sorts.entries.map((e) => PopupMenuItem(
              value: e.key,
              child: Text(e.value, style: TextStyle(
                color: _sort == e.key ? VeloxTheme.accent : Colors.white,
                fontWeight: _sort == e.key ? FontWeight.w700 : FontWeight.normal)),
            )).toList(),
          ),
        ],
      ),
      body: _loading
          ? const ShimmerGrid()
          : _products.isEmpty
              ? EmptyState(icon: Icons.search_off, title: 'No Products',
                  subtitle: 'No products found.')
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 0.72,
                    crossAxisSpacing: 12, mainAxisSpacing: 12),
                  itemCount: _products.length,
                  itemBuilder: (_, i) => ProductCard(
                    product: _products[i],
                    onTap: () => Navigator.pushNamed(context, '/product', arguments: _products[i]),
                  ),
                ),
    );
  }
}
