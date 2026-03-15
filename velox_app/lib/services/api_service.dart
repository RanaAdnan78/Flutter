// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/models.dart';

class ApiService {
  static final ApiService _i = ApiService._internal();
  factory ApiService() => _i;
  ApiService._internal();

  Future<String?> _token() async {
    final p = await SharedPreferences.getInstance();
    return p.getString('auth_token');
  }

  Future<Map<String, String>> _headers({bool auth = false}) async {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (auth) {
      final t = await _token();
      if (t != null) h['Authorization'] = 'Bearer $t';
    }
    return h;
  }

  Map<String, dynamic> _parse(http.Response r) {
    try {
      final d = json.decode(r.body);
      return d is Map<String, dynamic> ? d : {'success': false, 'message': 'Invalid response'};
    } catch (_) {
      return {'success': false, 'message': 'Server error ${r.statusCode}'};
    }
  }

  String _q(Map<String, String> p) =>
      p.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');

  Future<Map<String, dynamic>> _get(String ep, {Map<String, String>? params, bool auth = false}) async {
    var url = '${ApiConfig.apiUrl}?endpoint=$ep';
    if (params != null && params.isNotEmpty) url += '&${_q(params)}';
    
    // Add token to URL as backup
    if (auth) {
      final t = await _token();
      if (t != null) url += '&token=${Uri.encodeComponent(t)}';
    }
    
    try {
      final r = await http.get(
        Uri.parse(url),
        headers: await _headers(auth: auth),
      ).timeout(const Duration(seconds: 15));
      return _parse(r);
    } catch (e) {
      return {'success': false, 'message': 'Connection failed. Check server IP.'};
    }
  }
  Future<Map<String, dynamic>> _post(String ep, Map<String, dynamic> body, {bool auth = false}) async {
    try {
      final headers = await _headers(auth: auth);
      final token = auth ? await _token() : null;
      
      // Add token to URL as backup if auth required
      var url = '${ApiConfig.apiUrl}?endpoint=$ep';
      if (auth && token != null) {
        url += '&token=$token';
      }
      
      final r = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      ).timeout(const Duration(seconds: 15));
      return _parse(r);
    } catch (e) {
      return {'success': false, 'message': 'Connection failed. Check server IP.'};
    }
  }

  Future<Map<String, dynamic>> _delete(String ep, Map<String, dynamic> body, {bool auth = false}) async {
    try {
      final req = http.Request('DELETE', Uri.parse('${ApiConfig.apiUrl}?endpoint=$ep'));
      req.headers.addAll(await _headers(auth: auth));
      req.body = json.encode(body);
      final s = await req.send().timeout(const Duration(seconds: 15));
      return _parse(await http.Response.fromStream(s));
    } catch (e) {
      return {'success': false, 'message': 'Connection failed.'};
    }
  }

  // ── AUTH ────────────────────────────────────────────────────
  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _post('login', {'email': email, 'password': password});
    if (res['success'] == true && res['token'] != null) {
      final p = await SharedPreferences.getInstance();
      await p.setString('auth_token', res['token']);
      if (res['user'] != null) await p.setString('user_json', json.encode(res['user']));
    }
    return res;
  }

  Future<Map<String, dynamic>> register(String name, String email, String phone, String password) async {
    final res = await _post('register', {'full_name': name, 'email': email, 'phone': phone, 'password': password});
    if (res['success'] == true && res['token'] != null) {
      final p = await SharedPreferences.getInstance();
      await p.setString('auth_token', res['token']);
    }
    return res;
  }

  Future<void> logout() async {
    final p = await SharedPreferences.getInstance();
    await p.remove('auth_token');
    await p.remove('user_json');
  }

  Future<bool> isLoggedIn() async => (await _token()) != null;

  Future<User?> getMe() async {
    final res = await _get('me', auth: true);
    if (res['success'] == true && res['data'] != null) return User.fromJson(res['data']);
    return null;
  }

  Future<User?> getCachedUser() async {
    final p = await SharedPreferences.getInstance();
    final j = p.getString('user_json');
    if (j == null) return null;
    try { return User.fromJson(json.decode(j)); } catch (_) { return null; }
  }

  // ── PRODUCTS ────────────────────────────────────────────────
  Future<Map<String, dynamic>> getProducts({
    int? categoryId, String? filter, String sort = 'newest',
    String? query, int page = 1, int limit = 20,
  }) async {
    final p = <String, String>{'sort': sort, 'page': '$page', 'limit': '$limit'};
    if (categoryId != null) p['cat']    = '$categoryId';
    if (filter     != null) p['filter'] = filter;
    if (query      != null) p['q']      = query;
    final res = await _get('products', params: p);
    if (res['success'] == true) {
      return {
        'products': (res['data'] as List).map((x) => Product.fromJson(x)).toList(),
        'total': res['total'] ?? 0,
        'pages': res['pages'] ?? 1,
      };
    }
    return {'products': <Product>[], 'total': 0, 'pages': 1};
  }

  Future<Product?> getProduct(String slug) async {
    final res = await _get('product', params: {'slug': slug});
    if (res['success'] == true && res['data'] != null) return Product.fromJson(res['data']);
    return null;
  }

  Future<List<Product>> search(String q) async {
    final res = await _get('search', params: {'q': q});
    if (res['success'] == true && res['data'] != null) {
      return (res['data'] as List).map((x) => Product.fromJson(x)).toList();
    }
    return [];
  }

  // ── CATEGORIES ──────────────────────────────────────────────
  Future<List<Category>> getCategories() async {
    final res = await _get('categories');
    if (res['success'] == true && res['data'] != null) {
      return (res['data'] as List).map((x) => Category.fromJson(x)).toList();
    }
    return [];
  }

  // ── CART ────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getCart() async {
    final res = await _get('cart', auth: true);
    if (res['success'] == true && res['data'] != null) {
      return {
        'items':    (res['data'] as List).map((x) => CartItem.fromJson(x)).toList(),
        'subtotal': (res['subtotal'] ?? 0).toDouble(),
        'shipping': (res['shipping'] ?? 0).toDouble(),
        'total':    (res['total']    ?? 0).toDouble(),
      };
    }
    return {'items': <CartItem>[], 'subtotal': 0.0, 'shipping': 0.0, 'total': 0.0};
  }

  Future<Map<String, dynamic>> addToCart({required int productId, required int qty, required String size, required String color}) =>
      _post('cart', {'product_id': productId, 'qty': qty, 'size': size, 'color': color}, auth: true);

  Future<Map<String, dynamic>> removeFromCart(int cartId) =>
      _delete('cart', {'cart_id': cartId}, auth: true);

  Future<Map<String, dynamic>> clearCart() =>
      _delete('cart', {}, auth: true);

  // ── WISHLIST ────────────────────────────────────────────────
  Future<List<Product>> getWishlist() async {
    final res = await _get('wishlist', auth: true);
    if (res['success'] == true && res['data'] != null) {
      return (res['data'] as List).map((x) => Product.fromJson(x)).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> toggleWishlist(int productId) =>
      _post('wishlist', {'product_id': productId}, auth: true);

  // ── ORDERS ──────────────────────────────────────────────────
  Future<List<Order>> getOrders() async {
    final res = await _get('orders', auth: true);
    if (res['success'] == true && res['data'] != null) {
      return (res['data'] as List).map((x) => Order.fromJson(x)).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> placeOrder({
    required String fullName, required String email, required String phone,
    required String address,  required String city,  required String paymentMethod,
  }) => _post('orders', {'full_name': fullName, 'email': email, 'phone': phone,
        'address': address, 'city': city, 'payment_method': paymentMethod}, auth: true);

  // ── COUPON ──────────────────────────────────────────────────
  Future<Map<String, dynamic>> applyCoupon(String code, double subtotal) =>
      _post('coupon', {'code': code, 'subtotal': subtotal});

  // ── REVIEWS ─────────────────────────────────────────────────
  Future<Map<String, dynamic>> submitReview({required int productId, required int rating, required String comment}) =>
      _post('reviews', {'product_id': productId, 'rating': rating, 'comment': comment}, auth: true);
}
