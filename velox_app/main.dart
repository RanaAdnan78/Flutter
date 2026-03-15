// lib/main.dart
// ============================================================
// VELOX Flutter App — Entry Point
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'config/api_config.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'utils/theme.dart';

import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/products_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/auth_screens.dart';
import 'screens/other_screens.dart';
import 'models/models.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor:       Colors.transparent,
    statusBarBrightness:  Brightness.dark,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const VeloxApp());
}

class VeloxApp extends StatelessWidget {
  const VeloxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title:           'VELOX',
        debugShowCheckedModeBanner: false,
        theme:           VeloxTheme.dark,
        initialRoute:    '/splash',
        onGenerateRoute: _generateRoute,
      ),
    );
  }

  Route<dynamic> _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Splash
      case '/splash':
        return _route(const SplashScreen());

      // Main shell with bottom nav
      case '/home':
        return _route(const MainShell());

      // Products with optional filters
      case '/products':
        final args = settings.arguments as Map<String, dynamic>?;
        return _route(ProductsScreen(
          categoryId: args?['categoryId'],
          filter:     args?['filter'],
          title:      args?['title'] ?? 'All Products',
        ));

      // Product detail
      case '/product':
        final product = settings.arguments as Product;
        return _route(ProductDetailScreen(product: product));

      // Cart
      case '/cart':
        return _route(const CartScreen());

      // Checkout
      case '/checkout':
        return _route(const CheckoutScreen());

      // Order success
      case '/order-success':
        final orderNum = settings.arguments as String? ?? '';
        return _route(OrderSuccessScreen(orderNumber: orderNum));

      // Orders list
      case '/orders':
        return _route(const OrdersScreen());

      // Search
      case '/search':
        return _route(const SearchScreen());

      // Auth
      case '/login':
        return _route(const LoginScreen());
      case '/register':
        return _route(const RegisterScreen());

      default:
        return _route(const MainShell());
    }
  }

  static PageRoute _route(Widget page) =>
      MaterialPageRoute(builder: (_) => page);
}

// ═══════════════════════════════════════
// MAIN SHELL — Bottom Navigation
// ═══════════════════════════════════════
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _idx = 0;

  final _pages = const [
    HomeScreen(),
    _ProductsTab(),
    CartScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().count;

    return Scaffold(
      body:            _pages[_idx],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color:  Color(AppColors.primary),
          border: Border(top: BorderSide(color: Color(0xFF22222e))),
        ),
        child: BottomNavigationBar(
          currentIndex: _idx,
          onTap:        (i) => setState(() => _idx = i),
          type:         BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation:    0,
          selectedItemColor:   const Color(AppColors.accent),
          unselectedItemColor: const Color(AppColors.textMuted),
          selectedLabelStyle:  const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle:const TextStyle(fontSize: 11),
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            const BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), activeIcon: Icon(Icons.grid_view), label: 'Shop'),
            BottomNavigationBarItem(
              label: 'Cart',
              icon:  Stack(clipBehavior: Clip.none, children: [
                const Icon(Icons.shopping_bag_outlined),
                if (cartCount > 0) Positioned(
                  right: -6, top: -4,
                  child: Container(
                    width: 16, height: 16,
                    decoration: const BoxDecoration(color: Color(AppColors.accent), shape: BoxShape.circle),
                    child: Center(child: Text('$cartCount', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white))),
                  ),
                ),
              ]),
              activeIcon: const Icon(Icons.shopping_bag),
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Orders'),
            const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class _ProductsTab extends StatelessWidget {
  const _ProductsTab();
  @override
  Widget build(BuildContext context) => const ProductsScreen();
}
