import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoAnimation;
  late Animation<double> _textOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );

    _logoAnimation = Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(_controller);

    _textOpacityAnimation = Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(_controller);

    _controller.forward().then((value) async {
      bool userLoggedIn = await isLoggedIn();
      if (userLoggedIn) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/auth');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.2,
              ),
              child: FadeTransition(
                opacity: _logoAnimation,
                child: Image(
                  image: AssetImage("images/logo.png"),
                  width: MediaQuery.of(context).size.width *
                      0.8, // Adjust the width as needed
                  height: MediaQuery.of(context).size.height *
                      0.3, // Adjust the height as needed
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            ), // Add spacing between the logo and text
            FadeTransition(
              opacity: _textOpacityAnimation,
              child: Column(
                children: [
                  Text(
                    "Track. Save. Thrive",
                    style: TextStyle(
                      color: Color(0xFF6998AB), // Text colo
                      // Text color
                      fontSize: 18, // Text size
                      fontWeight: FontWeight.bold,

                      decoration: TextDecoration.none, // Remove underline
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> isLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("token");
  return token != null && token.isNotEmpty;
}
