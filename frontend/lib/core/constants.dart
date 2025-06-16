import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const String generalCategory = 'General';

const Map<String, FaIconData> categoryIcons = {
  'Food & Drinks': FontAwesomeIcons.utensils,
  'Transportation': FontAwesomeIcons.bus,
  'Housing': FontAwesomeIcons.house,
  'Bills': FontAwesomeIcons.fileInvoiceDollar,
  'Health': FontAwesomeIcons.heartPulse,
  'Entertainment': FontAwesomeIcons.film,
  'Shopping': FontAwesomeIcons.bagShopping,
  'Education': FontAwesomeIcons.book,
  'Travel': FontAwesomeIcons.plane,
};

const Map<String, Color> categoryColors = {
  'Food & Drinks': Colors.green,
  'Transportation': Colors.orange,
  'Housing': Colors.blueGrey,
  'Bills': Colors.blue,
  'Health': Colors.redAccent,
  'Entertainment': Colors.purple,
  'Shopping': Colors.teal,
  'Education': Colors.indigo,
  'Travel': Colors.cyan,
};

final List<String> categories = categoryIcons.keys.toList(growable: false);

/// Categories selectable on the analytics screen, including the aggregate.
final List<String> analysisCategories = [generalCategory, ...categories];

const String defaultCurrency = 'USD';

const Map<String, String> currencySymbols = {
  'USD': '\$',
  'EUR': '€',
  'GBP': '£',
  'JPY': '¥',
  'TL': '₺',
  'CHF': 'CHF',
};

const Map<String, FaIconData> currencyIcons = {
  'USD': FontAwesomeIcons.dollarSign,
  'EUR': FontAwesomeIcons.euroSign,
  'GBP': FontAwesomeIcons.sterlingSign,
  'JPY': FontAwesomeIcons.yenSign,
  'TL': FontAwesomeIcons.turkishLiraSign,
  'CHF': FontAwesomeIcons.francSign,
};

final List<String> currencies = currencySymbols.keys.toList(growable: false);

/// Labels for the five day ranges a month is split into on the charts.
const List<String> monthBucketLabels = [
  '1-6',
  '7-12',
  '13-18',
  '19-24',
  '25-31',
];
