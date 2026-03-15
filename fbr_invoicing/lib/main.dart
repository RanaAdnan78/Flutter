import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'utils/theme.dart';
import 'utils/constants.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';

import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home/dashboard_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with better error logging
  try {
    if (kIsWeb) {
      // On Web, Firebase.initializeApp() REQUIRE options. 
      // If none are provided, it throws an assertion error. 
      // For now, we print a warning and allow Demo Mode to take over.
      debugPrint('Web detected. Firebase requires manual options. Please follow the Web Setup in your Firebase Console.');
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('ERROR: Firebase failed to initialize. Error: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
      ],
      child: const FBRInvoicingApp(),
    ),
  );
}

class FBRInvoicingApp extends StatelessWidget {
  const FBRInvoicingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeService.themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
