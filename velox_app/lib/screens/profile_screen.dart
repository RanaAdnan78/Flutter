// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/api_config.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';
import '../widgets/widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: VeloxTheme.bg,
      appBar: const VeloxAppBar(title: 'My Profile', showBack: false),
      body: SingleChildScrollView(child: Column(children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(AppColors.primary), Color(0xFF0f2040)])),
          child: !auth.isLoggedIn
              ? Column(children: [
                  const Icon(Icons.person_outline, size: 60, color: Color(AppColors.textMuted)),
                  const SizedBox(height: 12),
                  const Text('Guest User', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 20),
                  VeloxButton(label: 'Login', onPressed: () => Navigator.pushNamed(context, '/login')),
                  const SizedBox(height: 10),
                  VeloxButton(label: 'Create Account', outlined: true, onPressed: () => Navigator.pushNamed(context, '/register')),
                ])
              : Column(children: [
                  CircleAvatar(radius: 38, backgroundColor: VeloxTheme.accent,
                    child: Text(user!.initials, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white))),
                  const SizedBox(height: 14),
                  Text(user.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(user.email, style: const TextStyle(color: Color(AppColors.textMuted), fontSize: 14)),
                  if (user.role == 'admin') ...[
                    const SizedBox(height: 8),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: VeloxTheme.gold.withOpacity(0.2), borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: VeloxTheme.gold.withOpacity(0.4))),
                      child: const Text('Admin', style: TextStyle(color: Color(AppColors.gold), fontWeight: FontWeight.w700, fontSize: 12))),
                  ],
                ]),
        ),

        const SizedBox(height: 8),
        _tile(context, Icons.shopping_bag_outlined, 'My Orders', onTap: () => Navigator.pushNamed(context, '/orders')),
        _tile(context, Icons.search,                'Search',    onTap: () => Navigator.pushNamed(context, '/search')),
        _tile(context, Icons.shopping_cart_outlined,'My Cart',   onTap: () => Navigator.pushNamed(context, '/cart')),
        _tile(context, Icons.help_outline,          'Help & Support'),
        _tile(context, Icons.info_outline,          'About VELOX'),

        if (auth.isLoggedIn) ...[
          const SizedBox(height: 8),
          const Divider(color: Color(0xFF22222e), indent: 20, endIndent: 20),
          _tile(context, Icons.logout, 'Logout', color: const Color(AppColors.error),
            onTap: () async {
              await auth.logout();
              if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
            }),
        ],
        const SizedBox(height: 40),

        // App info
        Padding(padding: const EdgeInsets.all(20),
          child: Column(children: [
            const Text('VELOX', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 4)),
            const SizedBox(height: 4),
            const Text('Walk the Future • v1.0.0', style: TextStyle(color: Color(AppColors.textMuted), fontSize: 12)),
            const SizedBox(height: 4),
            Text('Powered by Flutter + PHP API', style: TextStyle(color: VeloxTheme.muted.withOpacity(0.5), fontSize: 11)),
          ])),
      ])),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, {Color? color, VoidCallback? onTap}) {
    return ListTile(
      onTap:        onTap,
      leading:      Icon(icon, color: color ?? const Color(AppColors.textMuted)),
      title:        Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: color ?? Colors.white)),
      trailing:     color == null && onTap != null
                    ? const Icon(Icons.arrow_forward_ios, size: 14, color: Color(AppColors.textMuted)) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }
}
