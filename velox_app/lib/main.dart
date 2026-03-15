import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'config/api_config.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'utils/theme.dart';
import 'models/models.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/products_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/auth_screens.dart';
import 'screens/checkout_screen.dart';
import 'screens/order_success_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/search_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
        title: 'VELOX',
        debugShowCheckedModeBanner: false,
        theme: VeloxTheme.dark,
        initialRoute: '/splash',
        onGenerateRoute: _route,
      ),
    );
  }

  Route<dynamic> _route(RouteSettings s) {
    Widget page;
    switch (s.name) {
      case '/splash':
        page = const SplashScreen(); break;
      case '/home':
        page = const MainShell(); break;
      case '/products':
        final a = s.arguments as Map<String, dynamic>?;
        page = ProductsScreen(
          categoryId: a?['categoryId'] as int?,
          filter: a?['filter'] as String?,
          title: a?['title'] as String? ?? 'All Products');
        break;
      case '/product':
        page = ProductDetailScreen(product: s.arguments as Product); break;
      case '/cart':
        page = const CartScreen(); break;
      case '/checkout':
        page = const CheckoutScreen(); break;
      case '/order-success':
        page = OrderSuccessScreen(orderNumber: s.arguments as String? ?? ''); break;
      case '/orders':
        page = const OrdersScreen(); break;
      case '/search':
        page = const SearchScreen(); break;
      case '/login':
        page = const LoginScreen(); break;
      case '/register':
        page = const RegisterScreen(); break;
      default:
        page = const MainShell();
    }
    return MaterialPageRoute(builder: (_) => page);
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _idx = 0;
  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().count;
    final pages = [
      const HomeScreen(),
      const ProductsScreen(),
      const CartScreen(),
      const OrdersScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _idx, children: pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(AppColors.primary),
          border: Border(top: BorderSide(color: Color(0xFF22222e)))),
        child: BottomNavigationBar(
          currentIndex: _idx,
          onTap: (i) => setState(() => _idx = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(AppColors.accent),
          unselectedItemColor: const Color(AppColors.textMuted),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home'),
            const BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view),
              label: 'Shop'),
            BottomNavigationBarItem(
              label: 'Cart',
              icon: Stack(clipBehavior: Clip.none, children: [
                const Icon(Icons.shopping_bag_outlined),
                if (cartCount > 0) Positioned(right: -6, top: -4,
                  child: Container(width: 16, height: 16,
                    decoration: const BoxDecoration(
                      color: Color(AppColors.accent), shape: BoxShape.circle),
                    child: Center(child: Text('$cartCount',
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white))))),
              ]),
              activeIcon: const Icon(Icons.shopping_bag)),
            const BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Orders'),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
