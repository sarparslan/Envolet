import 'package:envolet_frontend/providers/session_provider.dart';
import 'package:envolet_frontend/screens/home_page.dart';
import 'package:envolet_frontend/services/api_service.dart';
import 'package:envolet_frontend/utils/dialogs.dart';
import 'package:envolet_frontend/utils/navigation.dart';
import 'package:envolet_frontend/utils/validators.dart';
import 'package:envolet_frontend/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _passwordsMatch =>
      _passwordController.text == _confirmPasswordController.text;

  String? get _validationError {
    if (_emailController.text.isNotEmpty &&
        !isValidEmail(_emailController.text)) {
      return 'Please enter a valid email address';
    }
    if (_passwordController.text.isNotEmpty &&
        !isValidPassword(_passwordController.text)) {
      return 'Password must be at least $minPasswordLength characters';
    }
    if (_confirmPasswordController.text.isNotEmpty && !_passwordsMatch) {
      return 'Passwords do not match';
    }
    return null;
  }

  bool get _isFormValid =>
      _fullNameController.text.trim().isNotEmpty &&
      isValidEmail(_emailController.text) &&
      isValidPassword(_passwordController.text) &&
      _passwordsMatch;

  Future<void> _register() async {
    setState(() => _isLoading = true);
    try {
      await context.read<SessionProvider>().register(
            fullName: _fullNameController.text,
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      if (!mounted) return;
      await AppDialogs.showSuccess(
        context,
        'Your account has been created successfully!',
        title: 'Success',
        confirmText: 'Ok',
      );
      if (mounted) resetTo(context, const HomePage());
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppDialogs.showError(
        context,
        e.statusCode == 409
            ? 'An account with this email already exists.'
            : 'Registration failed. Please try again.',
        title: 'Register Error',
      );
    }
  }

  void _onFieldChanged(String _) => setState(() {});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final error = _validationError;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              Image.asset(
                'images/registerOnboardingView.png',
                height: height * 0.3,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              const Text(
                'Create an Account',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please fill in the details below to create a new account.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 28),
              AuthTextField(
                controller: _fullNameController,
                hintText: 'Full Name',
                icon: Icons.person,
                textInputAction: TextInputAction.next,
                onChanged: _onFieldChanged,
              ),
              const SizedBox(height: 12),
              AuthTextField(
                controller: _emailController,
                hintText: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onChanged: _onFieldChanged,
              ),
              const SizedBox(height: 12),
              AuthTextField(
                controller: _passwordController,
                hintText: 'Password',
                icon: Icons.lock,
                isPassword: true,
                textInputAction: TextInputAction.next,
                onChanged: _onFieldChanged,
              ),
              const SizedBox(height: 12),
              AuthTextField(
                controller: _confirmPasswordController,
                hintText: 'Verify Password',
                icon: Icons.lock,
                isPassword: true,
                textInputAction: TextInputAction.done,
                onChanged: _onFieldChanged,
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(error, style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 28),
              PrimaryButton(
                label: 'Register',
                isLoading: _isLoading,
                onPressed: _isFormValid ? _register : null,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
