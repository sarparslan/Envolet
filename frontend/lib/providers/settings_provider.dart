import 'package:envolet_frontend/core/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User preferences that persist across launches.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._prefs)
      : _currency = _prefs.getString(_currencyKey) ?? defaultCurrency;

  static const _currencyKey = 'currency';

  final SharedPreferences _prefs;

  String _currency;
  String get currency => _currency;
  String get currencySymbol => currencySymbols[_currency] ?? '';

  Future<void> setCurrency(String value) async {
    if (value == _currency) return;
    _currency = value;
    notifyListeners();
    await _prefs.setString(_currencyKey, value);
  }
}
