import 'package:envolet_frontend/providers/session_provider.dart';
import 'package:envolet_frontend/screens/auth/register_page.dart';
import 'package:envolet_frontend/screens/home_page.dart';
import 'package:envolet_frontend/services/api_service.dart';
import 'package:envolet_frontend/utils/dialogs.dart';
import 'package:envolet_frontend/utils/navigation.dart';
import 'package:envolet_frontend/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await context
          .read<SessionProvider>()
          .login(email: email, password: password);
      if (!mounted) return;
      resetTo(context, const HomePage());
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppDialogs.showError(
        context,
        e.isUnauthorized
            ? 'Login failed. Please check your credentials and try again.'
            : e.message,
        title: 'Login Error',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              children: [
                Image.asset(
                  'images/loginOnboardingView.png',
                  height: height * 0.4,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Welcome Back!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please login to your account',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 28),
                AuthTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                AuthTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  icon: Icons.lock,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: 'Login',
                  isLoading: _isLoading,
                  onPressed: _login,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  ),
                  child: const Text("Don't have an account? Register"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
