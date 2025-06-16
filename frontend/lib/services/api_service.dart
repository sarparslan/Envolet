import 'dart:convert';

import 'package:envolet_frontend/models/asset.dart';
import 'package:envolet_frontend/models/category_share.dart';
import 'package:envolet_frontend/models/transaction.dart';
import 'package:envolet_frontend/models/user.dart';
import 'package:envolet_frontend/services/token_storage.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Client for the Envolet backend.
class ApiService {
  ApiService({
    required TokenStorage tokenStorage,
    http.Client? client,
    String? baseUrl,
  })  : _tokenStorage = tokenStorage,
        _client = client ?? http.Client(),
        baseUrl = baseUrl ?? defaultBaseUrl;

  /// Override at build time with `--dart-define=API_BASE_URL=...`.
  static const String defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5001',
  );

  final String baseUrl;
  final TokenStorage _tokenStorage;
  final http.Client _client;

  // ------------------ Auth ------------------

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final json = await _send(
      'POST',
      '/auth/login',
      body: {'email': email, 'password': password},
      authenticated: false,
    );
    return _storeSession(json);
  }

  Future<AuthSession> register({
    required String name,
    required String surname,
    required String email,
    required String password,
  }) async {
    final json = await _send(
      'POST',
      '/auth/register',
      body: {
        'name': name,
        'surname': surname,
        'email': email,
        'password': password,
      },
      authenticated: false,
    );
    return _storeSession(json);
  }

  Future<bool> hasToken() async => (await _tokenStorage.read()) != null;

  Future<User> getCurrentUser() async {
    final json = await _send('GET', '/auth/me');
    return User.fromJson(json['user']);
  }

  Future<void> logout() => _tokenStorage.delete();

  Future<void> deleteAccount() async {
    await _send('DELETE', '/auth/delete');
    await logout();
  }

  // ------------------ Transactions ------------------

  Future<List<Transaction>> getTransactions() async {
    final json = await _send('GET', '/transactions');
    final transactions = (json['data'] as List)
        .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
        .toList();
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  Future<void> addTransaction({
    required double amount,
    required String category,
    required DateTime date,
  }) =>
      _send(
        'POST',
        '/transactions',
        body: Transaction.toRequestJson(
          amount: amount,
          category: category,
          date: date,
        ),
      );

  Future<void> updateTransaction({
    required String id,
    required double amount,
    required String category,
    required DateTime date,
  }) =>
      _send(
        'PUT',
        '/transactions/$id',
        body: Transaction.toRequestJson(
          amount: amount,
          category: category,
          date: date,
        ),
      );

  Future<void> deleteTransaction(String id) =>
      _send('DELETE', '/transactions/$id');

  // ------------------ Analytics ------------------

  /// Spending of [month] (`yyyy-MM`) split into five day ranges.
  /// When [category] is null all categories are included.
  Future<List<double>> getMonthBuckets(String month, {String? category}) {
    return category == null
        ? _getBuckets('/transactions/general-buckets-by-month', {
            'month': month,
          })
        : _getBuckets('/transactions/category-buckets-by-month', {
            'category': category,
            'month': month,
          });
  }

  /// Average spending per day range across all months.
  Future<List<double>> getAverageBuckets({String? category}) {
    return category == null
        ? _getBuckets('/transactions/general-buckets')
        : _getBuckets('/transactions/category-buckets', {
            'category': category,
          });
  }

  Future<List<CategoryShare>> getCategoryShares(String month) async {
    final json = await _send(
      'GET',
      '/transactions/monthly-category-percentages',
      query: {'month': month},
    );
    return (json['data'] as List)
        .map((e) => CategoryShare.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<double>> _getBuckets(
    String path, [
    Map<String, String>? query,
  ]) async {
    final json = await _send('GET', path, query: query);
    return (json['buckets'] as List).map((e) => (e as num).toDouble()).toList();
  }

  // ------------------ Assets ------------------

  Future<List<Asset>> getAssets() async {
    final json = await _send('GET', '/assets');
    return (json['data'] as List)
        .map((e) => Asset.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Asset> addAsset(AssetDraft draft) async {
    final json = await _send('POST', '/assets', body: draft.toJson());
    return Asset.fromJson(json['data']);
  }

  Future<void> updateAsset(String id, AssetDraft draft) =>
      _send('PUT', '/assets/$id', body: draft.toJson());

  Future<void> deleteAsset(String id) => _send('DELETE', '/assets/$id');

  // ------------------ AI ------------------

  /// Asks the backend for a short, personalised spending tip.
  Future<String> getSpendingSuggestion({
    required String category,
    required String month,
    required double monthTotal,
    required double monthlyAverage,
    required String currency,
  }) async {
    final json = await _send('POST', '/ai/suggestion', body: {
      'category': category,
      'month': month,
      'monthTotal': monthTotal,
      'monthlyAverage': monthlyAverage,
      'currency': currency,
    });
    return json['suggestion'] as String;
  }

  // ------------------ Internals ------------------

  Future<AuthSession> _storeSession(Map<String, dynamic> json) async {
    final session = AuthSession.fromJson(json);
    await _tokenStorage.write(session.token);
    return session;
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
    bool authenticated = true,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (authenticated) {
      final token = await _tokenStorage.read();
      if (token == null) {
        throw const ApiException('Not logged in', statusCode: 401);
      }
      headers['Authorization'] = 'Bearer $token';
    }

    final request = http.Request(
      method,
      Uri.parse('$baseUrl$path').replace(queryParameters: query),
    )..headers.addAll(headers);
    if (body != null) request.body = jsonEncode(body);

    final http.Response response;
    try {
      response = await http.Response.fromStream(await _client.send(request));
    } on http.ClientException catch (e) {
      throw ApiException('Could not reach the server: ${e.message}');
    }

    final decoded = response.body.isEmpty ? null : _tryDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        _errorMessage(decoded) ?? 'Request failed',
        statusCode: response.statusCode,
      );
    }
    return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
  }

  static dynamic _tryDecode(String body) {
    try {
      return jsonDecode(body);
    } on FormatException {
      return null;
    }
  }

  static String? _errorMessage(dynamic decoded) {
    if (decoded is! Map<String, dynamic>) return null;
    final detail = decoded['detail'] ?? decoded['message'];
    return detail is String ? detail : null;
  }
}
