import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      // Wait for 3 seconds (slightly longer to ensure engine is ready)
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;

      final authService = Provider.of<AuthService>(context, listen: false);

      debugPrint('SplashScreen: Checking authentication...');
      bool authenticated = false;
      try {
        authenticated = authService.isAuthenticated;
      } catch (e) {
        debugPrint('SplashScreen: Error checking auth: $e');
      }

      if (!mounted) return;

      if (authenticated) {
        debugPrint('SplashScreen: Authenticated, going to Dashboard');
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        debugPrint('SplashScreen: Not authenticated, going to Login');
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      debugPrint('SplashScreen: Critical navigation error: $e');
      // If everything fails, try to at least get to the login screen
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long, size: 100, color: AppColors.white),
            const SizedBox(height: AppConstants.paddingL),
            Text(
              'FBR',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'DIGITAL INVOICING',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: AppConstants.paddingXL * 2),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
            ),
          ],
        ),
      ),
    );
  }
}
