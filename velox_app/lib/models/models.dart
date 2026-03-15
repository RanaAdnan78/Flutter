// lib/models/models.dart

class Product {
  final int     id;
  final String  name;
  final String  slug;
  final String  description;
  final double  price;
  final double? salePrice;
  final int     stock;
  final String  image;
  final String  sizes;
  final String  colors;
  final bool    isFeatured;
  final bool    isNew;
  final bool    isSale;
  final double  rating;
  final int     reviewsCount;
  final int     soldCount;
  final String? category;
  final String? brand;
  final int     categoryId;
  final String  status;

  Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.price,
    this.salePrice,
    required this.stock,
    required this.image,
    required this.sizes,
    required this.colors,
    required this.isFeatured,
    required this.isNew,
    required this.isSale,
    required this.rating,
    required this.reviewsCount,
    required this.soldCount,
    this.category,
    this.brand,
    required this.categoryId,
    required this.status,
  });

  factory Product.fromJson(Map<String, dynamic> j) => Product(
    id:           _i(j['id']),
    name:         j['name']        ?? '',
    slug:         j['slug']        ?? '',
    description:  j['description'] ?? '',
    price:        _d(j['price']),
    salePrice:    j['sale_price'] != null &&
                  j['sale_price'].toString() != '0' &&
                  j['sale_price'].toString().isNotEmpty
                  ? _d(j['sale_price']) : null,
    stock:        _i(j['stock']),
    image:        j['image']       ?? '',
    sizes:        j['sizes']       ?? '',
    colors:       j['colors']      ?? '',
    isFeatured:   _b(j['is_featured']),
    isNew:        _b(j['is_new']),
    isSale:       _b(j['is_sale']),
    rating:       _d(j['rating']),
    reviewsCount: _i(j['reviews_count']),
    soldCount:    _i(j['sold_count']),
    category:     j['category'],
    brand:        j['brand'],
    categoryId:   _i(j['category_id']),
    status:       j['status'] ?? 'active',
  );

  double get effectivePrice   => salePrice ?? price;
  bool   get inStock          => stock > 0;
  int    get discountPercent  => salePrice != null
      ? ((price - salePrice!) / price * 100).round() : 0;
  List<String> get sizeList   => sizes.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  List<String> get colorList  => colors.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
}

class Category {
  final int    id;
  final String name;
  final String slug;
  final String icon;
  final int    productCount;

  Category({required this.id, required this.name, required this.slug, required this.icon, required this.productCount});

  factory Category.fromJson(Map<String, dynamic> j) => Category(
    id:           _i(j['id']),
    name:         j['name'] ?? '',
    slug:         j['slug'] ?? '',
    icon:         j['icon'] ?? 'tag',
    productCount: _i(j['product_count']),
  );
}

class CartItem {
  final int    id;
  final int    productId;
  final String name;
  final String image;
  final double price;
  final double? salePrice;
  final int    quantity;
  final String size;
  final String color;
  final int    stock;

  CartItem({required this.id, required this.productId, required this.name, required this.image,
    required this.price, this.salePrice, required this.quantity, required this.size, required this.color, required this.stock});

  factory CartItem.fromJson(Map<String, dynamic> j) => CartItem(
    id:        _i(j['id']),
    productId: _i(j['product_id']),
    name:      j['name']  ?? '',
    image:     j['image'] ?? '',
    price:     _d(j['price']),
    salePrice: j['sale_price'] != null && j['sale_price'].toString() != '0' ? _d(j['sale_price']) : null,
    quantity:  _i(j['quantity']),
    size:      j['size']  ?? '',
    color:     j['color'] ?? '',
    stock:     _i(j['stock']),
  );

  double get unitPrice => salePrice ?? price;
  double get lineTotal => unitPrice * quantity;
}

class Order {
  final int    id;
  final String orderNumber;
  final double total;
  final double subtotal;
  final double shipping;
  final double discount;
  final String status;
  final String paymentMethod;
  final String fullName;
  final String phone;
  final String address;
  final String city;
  final String createdAt;
  final List<OrderItem> items;

  Order({required this.id, required this.orderNumber, required this.total, required this.subtotal,
    required this.shipping, required this.discount, required this.status, required this.paymentMethod,
    required this.fullName, required this.phone, required this.address, required this.city,
    required this.createdAt, required this.items});

  factory Order.fromJson(Map<String, dynamic> j) => Order(
    id:            _i(j['id']),
    orderNumber:   j['order_number']    ?? '',
    total:         _d(j['total']),
    subtotal:      _d(j['subtotal']),
    shipping:      _d(j['shipping']),
    discount:      _d(j['discount']),
    status:        j['status']          ?? '',
    paymentMethod: j['payment_method']  ?? '',
    fullName:      j['full_name']        ?? '',
    phone:         j['phone']            ?? '',
    address:       j['address']          ?? '',
    city:          j['city']             ?? '',
    createdAt:     j['created_at']       ?? '',
    items: j['items'] != null ? (j['items'] as List).map((i) => OrderItem.fromJson(i)).toList() : [],
  );
}

class OrderItem {
  final int    id;
  final String productName;
  final int    quantity;
  final double price;
  final String size;
  final String color;

  OrderItem({required this.id, required this.productName, required this.quantity,
    required this.price, required this.size, required this.color});

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
    id:          _i(j['id']),
    productName: j['product_name'] ?? '',
    quantity:    _i(j['quantity']),
    price:       _d(j['price']),
    size:        j['size']  ?? '',
    color:       j['color'] ?? '',
  );
}

class User {
  final int    id;
  final String fullName;
  final String email;
  final String? phone;
  final String? address;
  final String? city;
  final String role;

  User({required this.id, required this.fullName, required this.email,
    this.phone, this.address, this.city, required this.role});

  factory User.fromJson(Map<String, dynamic> j) => User(
    id:       _i(j['id']),
    fullName: j['full_name'] ?? j['name'] ?? '',
    email:    j['email']     ?? '',
    phone:    j['phone'],
    address:  j['address'],
    city:     j['city'],
    role:     j['role']      ?? 'customer',
  );

  String get initials {
    final p = fullName.trim().split(' ');
    if (p.length >= 2) return '${p[0][0]}${p[1][0]}'.toUpperCase();
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }
}

class Review {
  final int    id;
  final String fullName;
  final int    rating;
  final String comment;
  final String createdAt;

  Review({required this.id, required this.fullName, required this.rating,
    required this.comment, required this.createdAt});

  factory Review.fromJson(Map<String, dynamic> j) => Review(
    id:        _i(j['id']),
    fullName:  j['full_name']  ?? 'Customer',
    rating:    _i(j['rating']),
    comment:   j['comment']    ?? '',
    createdAt: j['created_at'] ?? '',
  );
}

// ── Helpers ──────────────────────────────────────────────────
int    _i(dynamic v) { if (v == null) return 0; if (v is int) return v; return int.tryParse(v.toString()) ?? 0; }
double _d(dynamic v) { if (v == null) return 0.0; if (v is double) return v; return double.tryParse(v.toString()) ?? 0.0; }
bool   _b(dynamic v) { if (v == null) return false; if (v is bool) return v; return v.toString() == '1' || v.toString() == 'true'; }
