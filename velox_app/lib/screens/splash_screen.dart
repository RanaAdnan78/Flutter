// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/api_config.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _fade;
  late Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fade  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.7)));
    _scale = Tween<double>(begin: 0.6, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.7, curve: Curves.elasticOut)));
    _ctrl.forward();
    _go();
  }

  Future<void> _go() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    await context.read<AuthProvider>().init();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppColors.primary),
      body: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => FadeTransition(
            opacity: _fade,
            child:   ScaleTransition(
              scale: _scale,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 88, height: 88,
                  decoration: BoxDecoration(
                    gradient:     const LinearGradient(colors: [Color(0xFFe94560), Color(0xFFc73652)]),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: const Color(0xFFe94560).withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 12))],
                  ),
                  child: const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 44),
                ),
                const SizedBox(height: 22),
                const Text('VELOX',
                  style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 8)),
                const SizedBox(height: 6),
                Container(width: 40, height: 3, color: const Color(0xFFe94560)),
                const SizedBox(height: 8),
                const Text('Walk the Future',
                  style: TextStyle(color: Color(AppColors.textMuted), fontSize: 13, letterSpacing: 3)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
