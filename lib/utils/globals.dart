import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

String? userEmail;
String? userName;
String? userSurname;

/// OpenRouter API key used for AI suggestions. Provide it at build time with
/// `--dart-define=OPENROUTER_API_KEY=your_key`.
const String openRouterApiKey = String.fromEnvironment('OPENROUTER_API_KEY');

final Map<String, IconData> categoryIcons = {
  "Food & Drinks": FontAwesomeIcons.utensils,
  "Transportation": FontAwesomeIcons.bus,
  "Housing": FontAwesomeIcons.house,
  "Bills": FontAwesomeIcons.fileInvoiceDollar,
  "Health": FontAwesomeIcons.heartPulse,
  "Entertainment": FontAwesomeIcons.film,
  "Shopping": FontAwesomeIcons.bagShopping,
  "Education": FontAwesomeIcons.book,
  "Travel": FontAwesomeIcons.plane,
};

final List<String> categories = categoryIcons.keys.toList();

final List<String> categoriesForAnalysis = ["General", ...categories];

Map<String, String> currencySymbolMap = {
  'USD': '\$',
  'EUR': '€',
  'GBP': '£',
  'TL': '₺',
  'JPY': '¥',
  'CHF': 'CHF',
};

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
