import 'package:envolet_frontend/utils/formatters.dart';
import 'package:envolet_frontend/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatAmount', () {
    test('adds separators and trims trailing zeros', () {
      expect(formatAmount(1234567), '1,234,567');
      expect(formatAmount(12.0), '12');
      expect(formatAmount(12.345), '12.35');
    });
  });

  group('color helpers', () {
    test('parse and serialize hex colors', () {
      expect(colorFromHex('#2196F3').toARGB32(), 0xFF2196F3);
      expect(colorToHex(const Color(0xFF2196F3)), '#2196F3');
    });

    test('fall back on invalid input', () {
      expect(colorFromHex('not-a-color', fallback: Colors.red), Colors.red);
    });
  });

  group('validators', () {
    test('accept common email formats', () {
      expect(isValidEmail('jane.doe+tag@mail.example.com'), isTrue);
      expect(isValidEmail('jane@localhost'), isFalse);
      expect(isValidEmail('jane'), isFalse);
    });

    test('require a minimum password length', () {
      expect(isValidPassword('12345'), isFalse);
      expect(isValidPassword('123456'), isTrue);
    });
  });
}
