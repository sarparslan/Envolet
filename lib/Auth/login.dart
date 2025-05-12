import 'package:envolet_frontend/Auth/register.dart';
import 'package:envolet_frontend/Screens/HomePage.dart';
import 'package:envolet_frontend/Services/api.dart';
import 'package:envolet_frontend/Util/Helper/helper.dart';
import 'package:envolet_frontend/Util/alart.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

final TextEditingController _emailController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();

class _LoginPageState extends State<LoginPage> {
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.03,
            bottom: MediaQuery.of(context).size.height * 0.03,
            left: MediaQuery.of(context).size.width * 0.04,
            right: MediaQuery.of(context).size.width * 0.04,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Center(
                  child: Image.asset(
                    'images/loginOnboarding.png',
                    height: Helper().getDeviceHeight(context) / 2,
                  ),
                ),
              ),
              Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: Helper().getDeviceHeight(context) / 60,
              ),
              Text(
                'Please login to your account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(
                height: Helper().getDeviceHeight(context) / 30,
              ),
              _buildTextField(
                  hintText: 'Email',
                  icon: Icons.email,
                  obscureText: false,
                  controller: _emailController),
              SizedBox(
                height: Helper().getDeviceHeight(context) / 60,
              ),
              _buildTextField(
                  hintText: 'Password',
                  icon: Icons.lock,
                  obscureText: true,
                  controller: _passwordController),
              SizedBox(
                height: Helper().getDeviceHeight(context) / 30,
              ),
              _buildLoginButton(context),
              SizedBox(
                height: Helper().getDeviceHeight(context) / 60,
              ),
              dontHaveAccount(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required String hintText,
      required IconData icon,
      required bool obscureText,
      required TextEditingController controller}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
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

  Widget _buildLoginButton(BuildContext context) {
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

            Util.navigateWithFade(context, HomePage());
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
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'Login',
          style: TextStyle(
            fontSize: 18,
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
