import 'package:envolet_frontend/Auth/login.dart';
import 'package:envolet_frontend/Screens/HomePage.dart';
import 'package:envolet_frontend/Services/api.dart';
import 'package:envolet_frontend/Util/alart.dart';
import 'package:envolet_frontend/Util/Helper/helper.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _verifypasswordController =
      TextEditingController();

  bool _obscureText = true;
  bool _verifyObscureText = true;
  bool _passwordsMatch = true;
  bool _verifyFieldTouched = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = "";
    _passwordController.text = "";
    _verifypasswordController.text = "";
  }

  void _validatePasswords() {
    setState(() {
      _passwordsMatch =
          _passwordController.text == _verifypasswordController.text;
    });
  }

  void _onVerifyFieldTouched() {
    if (!_verifyFieldTouched) {
      setState(() {
        _verifyFieldTouched = true;
      });
    }
    _validatePasswords();
  }

  bool _isEmailValid(String email) {
    final RegExp regex = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+$");
    return regex.hasMatch(email);
  }

  bool get _isFormValid {
    return _passwordsMatch &&
        _verifyFieldTouched &&
        _isEmailValid(_emailController.text) &&
        _emailController.text.trim().isNotEmpty &&
        _passwordController.text.trim().isNotEmpty &&
        _verifypasswordController.text.trim().isNotEmpty &&
        _fullNameController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final height = Helper().getDeviceHeight(context);
    final width = Helper().getDeviceWidth(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            top: height * 0.03,
            bottom: height * 0.03,
            left: width * 0.04,
            right: width * 0.04,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: height / 3.1,
                child: Center(
                  child: Image.asset(
                    'images/registerOnboardingView.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Text(
                'Create an Account',
                style: TextStyle(
                  fontSize: height / 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: height / 65),
              Text(
                'Please fill in the details below to create a new account.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: height / 55,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: height / 30),
              _buildTextField(
                currentController: _fullNameController,
                hintText: 'Full Name',
                icon: Icons.person,
                obscureText: false,
              ),
              SizedBox(height: height / 60),
              _buildTextField(
                currentController: _emailController,
                hintText: 'Email',
                icon: Icons.email,
                obscureText: false,
              ),
              SizedBox(height: height / 60),
              _buildTextFieldPassword(
                currentController: _passwordController,
                hintText: 'Password',
                icon: Icons.lock,
                obscureText: _obscureText,
                onToggle: () => setState(() => _obscureText = !_obscureText),
                onChanged: _validatePasswords,
              ),
              SizedBox(height: height / 60),
              _buildTextFieldPassword(
                currentController: _verifypasswordController,
                hintText: 'Verify Password',
                icon: Icons.lock,
                obscureText: _verifyObscureText,
                onToggle: () => setState(() {
                  _verifyObscureText = !_verifyObscureText;
                  _validatePasswords();
                }),
                onChanged: _onVerifyFieldTouched,
              ),
              if (!_passwordsMatch && _verifyFieldTouched)
                Padding(
                  padding: EdgeInsets.only(top: height / 100),
                  child: Text(
                    'Passwords do not match',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: height / 30),
              _buildRegisterButton(context, height),
              SizedBox(height: height / 60),
              _buildLoginText(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    required bool obscureText,
    required TextEditingController currentController,
  }) {
    return TextField(
      controller: currentController,
      obscureText: obscureText,
      onChanged: (_) => setState(() {}),
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.white70,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  Widget _buildTextFieldPassword({
    required String hintText,
    required IconData icon,
    required bool obscureText,
    required TextEditingController currentController,
    required VoidCallback onToggle,
    required VoidCallback onChanged,
  }) {
    return TextField(
      controller: currentController,
      obscureText: obscureText,
      style: TextStyle(color: Colors.black),
      onChanged: (value) {
        onChanged();
        setState(() {});
      },
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: Colors.white70,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context, double height) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isFormValid
            ? () async {
                final email = _emailController.text.trim();
                final password = _passwordController.text.trim();
                final fullName = _fullNameController.text.trim();
                final nameParts = fullName.split(' ');
                final surname = nameParts.length > 1 ? nameParts.last : '';
                final name = nameParts.length > 1
                    ? nameParts.sublist(0, nameParts.length - 1).join(' ')
                    : fullName;

                final result = await Api.registerCall(
                  email: email,
                  password: password,
                  name: name,
                  surname: surname,
                );

                if (result != null) {
                  _fullNameController.clear();
                  _emailController.clear();
                  _passwordController.clear();
                  _verifypasswordController.clear();

                  Util.successAlertAndGoToPage(
                    context,
                    "Your account has been created successfully!",
                    HomePage(),
                  );
                } else {
                  Util.errorAlertAndNavigate(
                    context,
                    "Registration failed. Please try again.",
                    "Register Error",
                  );
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isFormValid ? Colors.blue : Colors.grey,
          padding: EdgeInsets.symmetric(vertical: height / 45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'Register',
          style: TextStyle(fontSize: height / 45, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLoginText(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => LoginPage()));
      },
      child: Text(
        'Already have an account? Login',
        style: TextStyle(color: Colors.blue),
      ),
    );
  }
}
