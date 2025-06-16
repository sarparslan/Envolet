import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final NumberFormat _amountFormat = NumberFormat('#,##0.##', 'en_US');

/// Formats an amount with thousands separators and at most two decimals.
String formatAmount(num amount) => _amountFormat.format(amount);

/// Parses `#RRGGBB` or `#AARRGGBB` into a [Color].
Color colorFromHex(String hex, {Color fallback = Colors.black87}) {
  var value = hex.replaceAll('#', '');
  if (value.length == 6) value = 'FF$value';
  final parsed = int.tryParse(value, radix: 16);
  return parsed == null ? fallback : Color(parsed);
}

/// Serializes a [Color] as `#RRGGBB`.
String colorToHex(Color color) =>
    '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
