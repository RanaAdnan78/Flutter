// lib/screens/search_screen.dart
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';
import '../widgets/widgets.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl    = TextEditingController();
  final _api     = ApiService();
  List<Product> _results  = [];
  bool          _loading  = false;
  bool          _searched = false;

  Future<void> _search(String q) async {
    if (q.trim().length < 2) {
      setState(() { _results = []; _searched = false; });
      return;
    }
    setState(() { _loading = true; _searched = true; });
    final r = await _api.search(q.trim());
    if (!mounted) return;
    setState(() { _results = r; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VeloxTheme.bg,
      appBar: AppBar(
        backgroundColor: VeloxTheme.primary,
        title: TextField(
          controller:  _ctrl,
          autofocus:   true,
          style:       const TextStyle(color: Colors.white),
          decoration:  const InputDecoration(
            hintText:  'Search shoes, brands...',
            hintStyle: const TextStyle(color: Color(0xFF888899)),
            border:    InputBorder.none,
            filled:    false,
            contentPadding: EdgeInsets.zero),
          onChanged:   (v) { if (v.length >= 3) _search(v); else if (v.isEmpty) setState(() { _results = []; _searched = false; }); },
          onSubmitted: _search),
        actions: [
          if (_ctrl.text.isNotEmpty)
            IconButton(icon: const Icon(Icons.clear),
              onPressed: () { _ctrl.clear(); setState(() { _results = []; _searched = false; }); }),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : !_searched
              ? const EmptyState(icon: Icons.search, title: 'Search VELOX', subtitle: 'Type to search products, brands, categories...')
              : _results.isEmpty
                  ? EmptyState(icon: Icons.search_off, title: 'No Results', subtitle: 'No products found for "${_ctrl.text}"')
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 12, mainAxisSpacing: 12),
                      itemCount: _results.length,
                      itemBuilder: (_, i) => ProductCard(
                        product: _results[i],
                        onTap: () => Navigator.pushNamed(context, '/product', arguments: _results[i]))),
    );
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }
}
