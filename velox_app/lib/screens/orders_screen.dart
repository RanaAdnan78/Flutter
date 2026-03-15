// lib/screens/orders_screen.dart
import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';
import '../widgets/widgets.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _api = ApiService();
  List<Order> _orders  = [];
  bool        _loading = true;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final orders = await _api.getOrders();
    if (!mounted) return;
    setState(() { _orders = orders; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VeloxTheme.bg,
      appBar: const VeloxAppBar(title: 'My Orders', showBack: false),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? EmptyState(icon: Icons.receipt_long_outlined, title: 'No Orders Yet',
                  subtitle: 'Place your first order!', actionLabel: 'Shop Now',
                  onAction: () => Navigator.pushNamed(context, '/products'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: _orders.length,
                  itemBuilder: (_, i) {
                    final o = _orders[i];
                    final sc = Fmt.statusColor(o.status);
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:        VeloxTheme.card,
                        borderRadius: BorderRadius.circular(16),
                        border:       Border.all(color: VeloxTheme.border)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          const Icon(Icons.receipt_outlined, size: 16, color: Color(AppColors.textMuted)),
                          const SizedBox(width: 6),
                          Text(o.orderNumber, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: sc.withOpacity(0.15), borderRadius: BorderRadius.circular(50)),
                            child: Text(o.status.toUpperCase(),
                              style: TextStyle(color: sc, fontSize: 10, fontWeight: FontWeight.w800))),
                        ]),
                        const SizedBox(height: 10),
                        const Divider(color: Color(0xFF22222e), height: 1),
                        const SizedBox(height: 10),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(Fmt.date(o.createdAt), style: const TextStyle(color: Color(AppColors.textMuted), fontSize: 12)),
                            Text('${o.items.length} item${o.items.length != 1 ? 's' : ''}',
                              style: const TextStyle(color: Color(AppColors.textMuted), fontSize: 12)),
                          ]),
                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Text(Fmt.price(o.total),
                              style: const TextStyle(fontWeight: FontWeight.w900, color: Color(AppColors.accent), fontSize: 16)),
                            Text(o.paymentMethod.toUpperCase(),
                              style: const TextStyle(color: Color(AppColors.textMuted), fontSize: 11)),
                          ]),
                        ]),
                      ]));
                  }),
    );
  }
}
