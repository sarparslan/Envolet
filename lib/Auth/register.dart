import 'package:envolet_frontend/Auth/login.dart';
import 'package:envolet_frontend/Util/alart.dart';
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
  var util_object = Util();
  void initState() {
    super.initState();
    _emailController.text = ""; // You can set an initial value here if needed
    _passwordController.text =
        ""; // You can set an initial value here if needed
    _verifypasswordController.text = "";
  }

  bool _obscureText = true;
  bool _verifyObscureText = true;
  bool _passwordsMatch = true;
  bool _verifyFieldTouched = false;

/*
  Future<void> createUserWithEmailAndPassword() async {
    print("BUTTON IS PRESSED");
    print(_emailController.text.trim());
    print(_passwordController.text.trim());
    setState(() {});
    try {
      await Auth().createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());
    } on FirebaseAuthException catch (e) {
      setState(() {
        print(e.message);
      });
    }
  }
*/
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
    final RegExp regex = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return regex.hasMatch(email);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Center(
                  child: Image.asset(
                    'images/registerOnboarding.png',
                    height: 250,
                  ),
                ),
              ),
              Text(
                'Create an Account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Please fill in the details below to create a new account.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 32),
              _buildTextField(
                currentController: _fullNameController,
                hintText: 'Full Name',
                icon: Icons.person,
                obscureText: false,
              ),
              SizedBox(height: 16),
              _buildTextField(
                currentController: _emailController,
                hintText: 'Email',
                icon: Icons.email,
                obscureText: false,
              ),
              SizedBox(height: 16),
              _buildTextFieldPassword(
                currentController: _passwordController,
                hintText: 'Password',
                icon: Icons.lock,
                obscureText: _obscureText,
                onToggle: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                onChanged: _validatePasswords,
              ),
              SizedBox(height: 16),
              _buildTextFieldPassword(
                currentController: _verifypasswordController,
                hintText: 'Verify Password',
                icon: Icons.lock,
                obscureText: _verifyObscureText,
                onToggle: () {
                  setState(() {
                    _verifyObscureText = !_verifyObscureText;
                    _passwordsMatch = _passwordController.text ==
                        _verifypasswordController.text;
                  });
                },
                onChanged: _onVerifyFieldTouched,
              ),
              if (!_passwordsMatch && _verifyFieldTouched)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Passwords do not match',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: 32),
              _buildRegisterButton(context),
              SizedBox(height: 16),
              _buildLoginText(context),
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
      required TextEditingController currentController}) {
    return TextField(
      controller: currentController,
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
      onChanged: (value) => onChanged(),
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

  Widget _buildRegisterButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _passwordsMatch &&
                _verifyFieldTouched &&
                _isEmailValid(_emailController.text)
            ? () {
                if (!_isEmailValid(_emailController.text)) {
                  Util.errorAlertAndNavigate(
                      context,
                      "Please enter a valid email address.",
                      "Failed to Register");
                  return; // Don't proceed if email is invalid.
                } else {
                  // createUserWithEmailAndPassword();
                  // Navigator.of(context).push(
                  //     MaterialPageRoute(builder: (context) => FirstPage()));
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _passwordsMatch && _verifyFieldTouched
              ? Colors.blue
              : Colors.grey,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'Register',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
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
        style: TextStyle(
          color: Colors.blue,
        ),
      ),
    );
  }
}
