import 'package:envolet_frontend/main.dart';
import 'package:envolet_frontend/providers/session_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _start();
  }

  Future<void> _start() async {
    final session = context.read<SessionProvider>();
    final results = await Future.wait([
      session.restoreSession(),
      _controller.forward().then((_) => true),
    ]);
    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed(
      results.first ? EnvoletApp.routeHome : EnvoletApp.routeAuth,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final fadeOut = Tween(begin: 1.0, end: 0.0).animate(_controller);

    return ColoredBox(
      color: Colors.white,
      child: FadeTransition(
        opacity: fadeOut,
        child: Column(
          children: [
            SizedBox(height: size.height * 0.2),
            Image.asset(
              'images/logo.png',
              width: size.width * 0.8,
              height: size.height * 0.3,
            ),
            SizedBox(height: size.height * 0.1),
            const Text(
              'Track. Save. Thrive',
              style: TextStyle(
                color: Color(0xFF6998AB),
                fontSize: 18,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
