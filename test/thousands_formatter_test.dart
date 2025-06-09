import 'package:envolet_frontend/utils/thousands_formatter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final formatter = ThousandsFormatter();

  TextEditingValue format(String oldText, String newText) =>
      formatter.formatEditUpdate(
        TextEditingValue(text: oldText),
        TextEditingValue(text: newText),
      );

  test('adds thousands separators', () {
    expect(format('12000', '120000').text, '120,000');
  });

  test('re-formats input that already contains separators', () {
    expect(format('1,234', '1,2345').text, '12,345');
  });

  test('keeps the previous value when input is not a number', () {
    expect(format('1,234', '1,234a').text, '1,234');
  });

  test('places the cursor at the end of the formatted text', () {
    final result = format('100', '1000');
    expect(result.selection, const TextSelection.collapsed(offset: 5));
  });
}
