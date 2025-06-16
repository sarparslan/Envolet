import 'package:envolet_frontend/models/user.dart';
import 'package:envolet_frontend/services/api_service.dart';
import 'package:flutter/foundation.dart';

/// Holds the signed-in user and exposes the authentication flows.
class SessionProvider extends ChangeNotifier {
  SessionProvider(this._api);

  final ApiService _api;

  User? _user;
  User? get user => _user;

  /// Restores a previous session. Returns `true` when the stored token is
  /// still valid.
  Future<bool> restoreSession() async {
    if (!await _api.hasToken()) return false;
    try {
      _user = await _api.getCurrentUser();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      if (e.isUnauthorized) await _api.logout();
      return false;
    }
  }

  Future<void> refreshUser() async {
    _user = await _api.getCurrentUser();
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    final session = await _api.login(email: email, password: password);
    _user = session.user;
    notifyListeners();
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final (name, surname) = splitFullName(fullName);
    final session = await _api.register(
      name: name,
      surname: surname,
      email: email,
      password: password,
    );
    _user = session.user;
    notifyListeners();
  }

  Future<void> logout() async {
    await _api.logout();
    _user = null;
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    await _api.deleteAccount();
    _user = null;
    notifyListeners();
  }

  /// Splits "Jane Mary Doe" into ("Jane Mary", "Doe").
  @visibleForTesting
  static (String, String) splitFullName(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) return (fullName.trim(), '');
    return (parts.sublist(0, parts.length - 1).join(' '), parts.last);
  }
}
