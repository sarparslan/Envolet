import 'package:envolet_frontend/providers/session_provider.dart';
import 'package:envolet_frontend/providers/settings_provider.dart';
import 'package:envolet_frontend/screens/auth/login_page.dart';
import 'package:envolet_frontend/screens/home_page.dart';
import 'package:envolet_frontend/services/api_service.dart';
import 'package:envolet_frontend/services/token_storage.dart';
import 'package:envolet_frontend/widgets/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final api = ApiService(tokenStorage: SecureTokenStorage());

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>.value(value: api),
        ChangeNotifierProvider(create: (_) => SessionProvider(api)),
        ChangeNotifierProvider(create: (_) => SettingsProvider(prefs)),
      ],
      child: const EnvoletApp(),
    ),
  );
}

class EnvoletApp extends StatelessWidget {
  const EnvoletApp({super.key});

  static const routeSplash = '/';
  static const routeAuth = '/auth';
  static const routeHome = '/home';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Envolet',
      debugShowCheckedModeBanner: false,
      initialRoute: routeSplash,
      routes: {
        routeSplash: (_) => const SplashScreen(),
        routeAuth: (_) => const LoginPage(),
        routeHome: (_) => const HomePage(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
            .copyWith(secondary: Colors.blue),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.blue,
          selectionColor: Colors.blue.shade200,
          selectionHandleColor: Colors.blue,
        ),
        splashColor: Colors.blue.withValues(alpha: 0.2),
        highlightColor: Colors.blue.withValues(alpha: 0.1),
        hoverColor: Colors.blue.withValues(alpha: 0.05),
        focusColor: Colors.blue.shade100,
        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
