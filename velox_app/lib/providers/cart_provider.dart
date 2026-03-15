// lib/providers/cart_provider.dart
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items    = [];
  double _subtotal = 0;
  double _shipping = 0;
  double _total    = 0;
  double _discount = 0;
  String? _couponCode;
  bool   _loading  = false;

  List<CartItem> get items      => _items;
  double get subtotal           => _subtotal;
  double get shipping           => _shipping;
  double get discount           => _discount;
  double get total              => _total - _discount;
  int    get count              => _items.fold(0, (s, i) => s + i.quantity);
  bool   get loading            => _loading;
  bool   get isEmpty            => _items.isEmpty;
  String? get couponCode        => _couponCode;

  final _api = ApiService();

  Future<void> load() async {
    _loading = true; notifyListeners();
    final d  = await _api.getCart();
    _items    = d['items']    as List<CartItem>;
    _subtotal = d['subtotal'] as double;
    _shipping = d['shipping'] as double;
    _total    = d['total']    as double;
    _loading  = false;
    notifyListeners();
  }

  Future<String?> add(int productId, int qty, String size, String color) async {
    final res = await _api.addToCart(productId: productId, qty: qty, size: size, color: color);
    if (res['success'] == true) { await load(); return null; }
    return res['message'] ?? 'Failed to add';
  }

  Future<void> remove(int cartId) async {
    await _api.removeFromCart(cartId);
    await load();
  }

  Future<void> clear() async {
    await _api.clearCart();
    reset();
  }

  Future<String?> applyCoupon(String code) async {
    final res = await _api.applyCoupon(code, _subtotal);
    if (res['success'] == true) {
      _discount   = (res['discount'] ?? 0).toDouble();
      _couponCode = code;
      notifyListeners();
      return null;
    }
    return res['message'] ?? 'Invalid coupon';
  }

  void removeCoupon() { _discount = 0; _couponCode = null; notifyListeners(); }

  void reset() {
    _items = []; _subtotal = 0; _shipping = 0;
    _total = 0; _discount = 0; _couponCode = null;
    notifyListeners();
  }
}
