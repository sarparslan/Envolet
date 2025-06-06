// globals.dart
library globals;

import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

String? userEmail;
String? userName;
String? userSurname;

final String apiKey = "API_KEY";

final Map<String, IconData> categoryIcons = {
  "Food & Drinks": FontAwesomeIcons.utensils,
  "Transportation": FontAwesomeIcons.bus,
  "Housing": FontAwesomeIcons.house,
  "Bills": FontAwesomeIcons.fileInvoiceDollar,
  "Health": FontAwesomeIcons.heartbeat,
  "Entertainment": FontAwesomeIcons.film,
  "Shopping": FontAwesomeIcons.shoppingBag,
  "Education": FontAwesomeIcons.book,
  "Travel": FontAwesomeIcons.plane,
};

final List<String> categories = [
  "Food & Drinks",
  "Transportation",
  "Housing",
  "Bills",
  "Health",
  "Entertainment",
  "Shopping",
  "Education",
  "Travel",
];

final List<String> categoriesForAnalysis = [
  "General",
  "Food & Drinks",
  "Transportation",
  "Housing",
  "Bills",
  "Health",
  "Entertainment",
  "Shopping",
  "Education",
  "Travel",
];

Map<String, String> currencySymbolMap = {
  'USD': '\$',
  'EUR': '€',
  'GBP': '£',
  'TL': '₺',
  'JPY': '¥',
  'CHF': 'CHF',
};

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
