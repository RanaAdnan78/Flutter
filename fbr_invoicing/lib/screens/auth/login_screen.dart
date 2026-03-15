import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isPhoneLogin = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      final authService = Provider.of<AuthService>(context, listen: false);

      if (_isPhoneLogin) {
        _sendOtp();
      } else {
        authService.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
          (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error), backgroundColor: AppColors.error),
            );
          },
          () {
            Navigator.pushReplacementNamed(context, '/dashboard');
          },
        );
      }
    }
  }

  void _sendOtp() {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    // Format number to e.g., +923001234567
    String phone = _phoneController.text.replaceAll(' ', '');
    if (phone.startsWith('0')) {
      phone = '+92${phone.substring(1)}';
    } else if (!phone.startsWith('+')) {
      phone = '+$phone';
    }

    authService.sendOTP(
      phone,
      (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error),
        );
      },
      () {
        // Navigate to OTP Screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(phoneNumber: phone),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Icon(
                  Icons.account_balance,
                  size: 80,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppConstants.paddingL),
                Text(
                  'FBR Invoicing',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.paddingS),
                Text(
                  _isPhoneLogin 
                    ? 'Login with your mobile number'
                    : 'Login with your email and password',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                if (_isPhoneLogin)
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Mobile Number',
                      hintText: 'e.g. 03001234567',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    validator: ValidationHelpers.validatePhone,
                  )
                else ...[
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) => 
                      value == null || !value.contains('@') ? 'Enter a valid email' : null,
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (value) => 
                      value == null || value.isEmpty ? 'Enter your password' : null,
                  ),
                ],

                const SizedBox(height: AppConstants.paddingXL),
                Consumer<AuthService>(
                  builder: (context, auth, _) {
                    return ElevatedButton(
                      onPressed: auth.isLoading ? null : _handleLogin,
                      child: auth.isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                          : Text(_isPhoneLogin ? 'GET OTP' : 'LOGIN'),
                    );
                  },
                ),
                
                const SizedBox(height: AppConstants.paddingM),
                TextButton(
                  onPressed: () => setState(() => _isPhoneLogin = !_isPhoneLogin),
                  child: Text(_isPhoneLogin ? 'Use Email instead' : 'Use Phone Number instead'),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),

                const Divider(height: 40),
                TextButton(
                  onPressed: () {
                    Provider.of<AuthService>(context, listen: false).enableDemoMode();
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  },
                  child: const Text('Skip to Dashboard (Demo Mode)', style: TextStyle(color: AppColors.textSecondary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
