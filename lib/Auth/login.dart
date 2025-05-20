import 'package:envolet_frontend/Auth/register.dart';
import 'package:envolet_frontend/Screens/AssetsPage.dart';
import 'package:envolet_frontend/Services/api.dart';
import 'package:envolet_frontend/Util/Helper/helper.dart';
import 'package:envolet_frontend/Util/alart.dart';

import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

final TextEditingController _emailController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();

void clearLoginControllers() {
  _emailController.clear();
  _passwordController.clear();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final height = Helper().getDeviceHeight(context);
    final width = Helper().getDeviceWidth(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
              Expanded(
                child: Center(
                  child: Image.asset(
                    'images/loginOnboarding.png',
                    height: height / 2,
                  ),
                ),
              ),
              Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: height / 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: height / 60),
              Text(
                'Please login to your account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: height / 45,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: height / 30),
              _buildTextField(
                hintText: 'Email',
                icon: Icons.email,
                obscureText: false,
                controller: _emailController,
              ),
              SizedBox(height: height / 60),
              _buildTextField(
                hintText: 'Password',
                icon: Icons.lock,
                obscureText: _obscurePassword,
                controller: _passwordController,
              ),
              SizedBox(height: height / 30),
              _buildLoginButton(context, height),
              SizedBox(height: height / 60),
              dontHaveAccount(),
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
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: hintText == "Password"
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
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

  Widget _buildLoginButton(BuildContext context, double height) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          final email = _emailController.text.trim();
          final password = _passwordController.text.trim();

          if (email.isEmpty || password.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Please enter both email and password")),
            );
            return;
          }

          final result = await Api.loginCall(email: email, password: password);
          if (result != null) {
            print("✅ Login successful. Token: ${result.token}");

            clearLoginControllers();
            Util.navigateWithFade(context, AssetsPage());
          } else {
            print("❌ Login failed for email: $email");
            Util.errorAlertAndNavigate(
              context,
              "Login failed. Please check your credentials and try again.",
              "Login Error",
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: EdgeInsets.symmetric(vertical: height / 45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'Login',
          style: TextStyle(
            fontSize: height / 45,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget dontHaveAccount() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => RegisterPage()));
      },
      child: Text(
        'Do not have an account? Register',
        style: TextStyle(
          color: Colors.blue,
        ),
      ),
    );
  }
}
