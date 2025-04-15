import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ThousandsFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,##0', 'en_US');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.replaceAll(',', '');
    int? number = int.tryParse(text);
    if (number == null) {
      return oldValue;
    }
    //120000 => 120,000
    final newText = _formatter.format(number);
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
