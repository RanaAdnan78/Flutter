// lib/screens/auth_screens.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/api_config.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';
import '../widgets/widgets.dart';

// ══════════════ LOGIN ══════════════
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure    = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await context.read<AuthProvider>().login(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (ok) Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: VeloxTheme.bg,
      appBar: const VeloxAppBar(title: 'Login'),
      body: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(children: [
        const SizedBox(height: 20),
        Container(width: 72, height: 72,
          decoration: BoxDecoration(
            gradient:     const LinearGradient(colors: [Color(0xFFe94560), Color(0xFFc73652)]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: const Color(0xFFe94560).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))]),
          child: const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 36)),
        const SizedBox(height: 20),
        const Text('Welcome Back!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        const Text('Login to your VELOX account', style: TextStyle(color: Color(AppColors.textMuted), fontSize: 14)),
        const SizedBox(height: 32),

        if (auth.error.isNotEmpty) Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFF3a1a1a), borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(AppColors.error).withOpacity(0.4))),
          child: Text(auth.error, style: const TextStyle(color: Color(AppColors.error)))),

        Form(key: _formKey, child: Column(children: [
          TextFormField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: 'Email address', prefixIcon: Icon(Icons.email_outlined)),
            validator: (v) => (v?.isEmpty ?? true) ? 'Email required' : null),
          const SizedBox(height: 14),
          TextFormField(controller: _passCtrl, obscureText: _obscure,
            decoration: InputDecoration(hintText: 'Password', prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscure = !_obscure))),
            validator: (v) => (v?.isEmpty ?? true) ? 'Password required' : null),
          const SizedBox(height: 24),
          VeloxButton(label: 'Login', loading: auth.loading, onPressed: _login),
        ])),

        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text("Don't have an account? ", style: TextStyle(color: Color(AppColors.textMuted))),
          GestureDetector(onTap: () { auth.clearError(); Navigator.pushReplacementNamed(context, '/register'); },
            child: const Text('Sign Up', style: TextStyle(color: Color(AppColors.accent), fontWeight: FontWeight.w700))),
        ]),
      ])),
    );
  }

  @override void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }
}

// ══════════════ REGISTER ══════════════
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _confCtrl  = TextEditingController();
  bool _obscure    = true;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passCtrl.text != _confCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match'), backgroundColor: Color(AppColors.error)));
      return;
    }
    final ok = await context.read<AuthProvider>().register(
      _nameCtrl.text.trim(), _emailCtrl.text.trim(), _phoneCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (ok) Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: VeloxTheme.bg,
      appBar: const VeloxAppBar(title: 'Create Account'),
      body: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Form(key: _formKey, child: Column(children: [
        if (auth.error.isNotEmpty) Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFF3a1a1a), borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(AppColors.error).withOpacity(0.4))),
          child: Text(auth.error, style: const TextStyle(color: Color(AppColors.error)))),
        _field(_nameCtrl,  'Full Name',     Icons.person_outline,   required: true),
        const SizedBox(height: 12),
        _field(_emailCtrl, 'Email Address', Icons.email_outlined,   required: true, kb: TextInputType.emailAddress),
        const SizedBox(height: 12),
        _field(_phoneCtrl, 'Phone Number',  Icons.phone_outlined,   kb: TextInputType.phone),
        const SizedBox(height: 12),
        TextFormField(controller: _passCtrl, obscureText: _obscure,
          decoration: InputDecoration(hintText: 'Password (min 6)', prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              onPressed: () => setState(() => _obscure = !_obscure))),
          validator: (v) => (v?.length ?? 0) < 6 ? 'Min 6 characters' : null),
        const SizedBox(height: 12),
        TextFormField(controller: _confCtrl, obscureText: _obscure,
          decoration: const InputDecoration(hintText: 'Confirm Password', prefixIcon: Icon(Icons.lock_outline)),
          validator: (v) => v != _passCtrl.text ? 'Passwords do not match' : null),
        const SizedBox(height: 24),
        VeloxButton(label: 'Create Account', loading: auth.loading, onPressed: _register),
        const SizedBox(height: 18),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('Already have an account? ', style: TextStyle(color: Color(AppColors.textMuted))),
          GestureDetector(onTap: () { auth.clearError(); Navigator.pushReplacementNamed(context, '/login'); },
            child: const Text('Login', style: TextStyle(color: Color(AppColors.accent), fontWeight: FontWeight.w700))),
        ]),
      ]))),
    );
  }

  Widget _field(TextEditingController c, String hint, IconData icon, {bool required = false, TextInputType? kb}) =>
    TextFormField(controller: c, keyboardType: kb,
      decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon)),
      validator: required ? (v) => (v?.isEmpty ?? true) ? '$hint required' : null : null);

  @override void dispose() { _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose(); _passCtrl.dispose(); _confCtrl.dispose(); super.dispose(); }
}
