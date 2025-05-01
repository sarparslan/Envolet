// globals.dart
library globals;

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

bool _isDarkMode = false;
String globalDiffLevel = 'Def';
bool get isDarkMode => _isDarkMode;

set isDarkMode(bool value) {
  _isDarkMode = value;
  _saveToPrefs();
}

Future<void> loadDarkModePreference() async {
  final prefs = await SharedPreferences.getInstance();
  _isDarkMode = prefs.getBool('isDarkMode') ?? false;
}

Future<void> _saveToPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool('isDarkMode', _isDarkMode);
}

void pushWithFadeTransition(BuildContext context, Widget destinationPage,
    {int durationMillis = 300}) {
  Navigator.of(context).push(PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => destinationPage,
    transitionDuration: Duration(milliseconds: durationMillis),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var tween = Tween(begin: 0.0, end: 1.0)
          .chain(CurveTween(curve: Curves.easeInOut));
      return FadeTransition(opacity: animation.drive(tween), child: child);
    },
  ));
}

bool isConnected = true;

late StreamSubscription<ConnectivityResult> connectivitySubscription;

void initializeConnectivityListener() {
  connectivitySubscription =
      Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
    bool currentStatus = result != ConnectivityResult.none;
    if (isConnected != currentStatus) {
      isConnected = currentStatus;
    }
  });
}

void disposeConnectivityListener() {
  connectivitySubscription.cancel();
}

void popWithFadeTransition(BuildContext context, {int durationMillis = 300}) {
  Navigator.of(context).pop(PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        Container(), // Bu container görünmez bir placeholder'dır.
    transitionDuration: Duration(milliseconds: durationMillis),
    reverseTransitionDuration: Duration(
        milliseconds:
            durationMillis), // Geri animasyon süresini de belirleyebilirsiniz.
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var tween = Tween(begin: 1.0, end: 0.0)
          .chain(CurveTween(curve: Curves.easeInOut));
      return FadeTransition(opacity: animation.drive(tween), child: child);
    },
  ));
}
