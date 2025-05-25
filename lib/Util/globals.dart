// globals.dart
library globals;

import 'dart:async';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

bool _isDarkMode = false;

String globalDiffLevel = 'Def';

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

String _globalCurrency = "USD";
final Map<String, IconData> currencyIcons = {
  "USD": FontAwesomeIcons.dollarSign,
  "EUR": FontAwesomeIcons.euroSign,
  "GBP": FontAwesomeIcons.sterlingSign,
  "JPY": FontAwesomeIcons.yenSign,
  "TL": FontAwesomeIcons.turkishLiraSign,
  "CHF": FontAwesomeIcons.francSign,
};

String get globalCurrency => _globalCurrency;

set globalCurrency(String value) {
  _globalCurrency = value;
  _saveCurrencyToPrefs();
}

Future<void> loadCurrencyPreference() async {
  final prefs = await SharedPreferences.getInstance();
  _globalCurrency = prefs.getString('currency') ?? "USD";
}

Future<void> _saveCurrencyToPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString("currency", _globalCurrency);
}

bool isConnected = true;

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
