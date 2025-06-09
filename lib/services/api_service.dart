import 'dart:convert';

import 'package:envolet_frontend/models/login_model.dart';
import 'package:envolet_frontend/models/register_model.dart';
import 'package:envolet_frontend/utils/globals.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around the Envolet REST backend and the OpenRouter AI API.
class ApiService {
  ApiService._();

  /// Backend base URL. Override at build time with
  /// `--dart-define=API_BASE_URL=https://your-backend`.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5001',
  );

  static const String _openRouterEndpoint =
      'https://openrouter.ai/api/v1/chat/completions';
  static const String _tokenKey = 'token';

  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json;charset=UTF-8',
  };

  static Uri _uri(String path, [Map<String, String>? queryParameters]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: queryParameters);

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Returns JSON headers including the bearer token, or `null` when the user
  /// is not logged in.
  static Future<Map<String, String>?> _authHeaders() async {
    final token = await _getToken();
    if (token == null) return null;
    return {..._jsonHeaders, 'Authorization': 'Bearer $token'};
  }

  static bool _isSuccess(http.Response response) =>
      response.statusCode == 200 || response.statusCode == 201;

  static void _logFailure(String operation, http.Response response) {
    debugPrint('$operation failed (${response.statusCode}): ${response.body}');
  }

  static List<double> _parseBuckets(dynamic buckets) =>
      List<double>.from((buckets as List).map((e) => (e as num).toDouble()));

  // ------------------ Auth ------------------

  static Future<LoginModel?> loginCall({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      _uri('/auth/login'),
      headers: _jsonHeaders,
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode != 200) {
      _logFailure('Login', response);
      return null;
    }

    final result = LoginModel.fromJson(jsonDecode(response.body));
    await _saveToken(result.token);
    return result;
  }

  static Future<RegisterModel?> registerCall({
    required String name,
    required String surname,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      _uri('/auth/register'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'name': name,
        'surname': surname,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 201) {
      _logFailure('Register', response);
      return null;
    }

    final result = RegisterModel.fromJson(jsonDecode(response.body));
    await _saveToken(result.token);
    return result;
  }

  static Future<Map<String, dynamic>?> getMe() async {
    final headers = await _authHeaders();
    if (headers == null) return null;

    final response = await http.get(_uri('/auth/me'), headers: headers);

    if (response.statusCode != 200) {
      _logFailure('GetMe', response);
      return null;
    }
    return jsonDecode(response.body)['user'];
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<bool> deleteAccount() async {
    final headers = await _authHeaders();
    if (headers == null) return false;

    final response = await http.delete(_uri('/auth/delete'), headers: headers);

    if (response.statusCode != 200) {
      _logFailure('DeleteAccount', response);
      return false;
    }
    await logout();
    return true;
  }

  // ------------------ AI suggestions ------------------

  static Future<String?> getOpenRouterResponse(String userInput) async {
    final response = await http.post(
      Uri.parse(_openRouterEndpoint),
      headers: {
        'Authorization': 'Bearer $openRouterApiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'google/gemini-2.0-flash-exp:free',
        'messages': [
          {'role': 'user', 'content': userInput}
        ],
        'max_tokens': 100,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode != 200) {
      _logFailure('OpenRouter', response);
      return null;
    }
    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'];
  }

  // ------------------ Transactions ------------------

  static Future<bool> addTransaction({
    required double amount,
    required String category,
    required String date,
  }) async {
    final headers = await _authHeaders();
    if (headers == null) return false;

    final response = await http.post(
      _uri('/transactions'),
      headers: headers,
      body: jsonEncode({'amount': amount, 'category': category, 'date': date}),
    );

    if (!_isSuccess(response)) {
      _logFailure('AddTransaction', response);
      return false;
    }
    return true;
  }

  static Future<List<Map<String, dynamic>>> getTransactions() async {
    final headers = await _authHeaders();
    if (headers == null) return [];

    final response = await http.get(_uri('/transactions'), headers: headers);

    if (response.statusCode != 200) {
      _logFailure('GetTransactions', response);
      return [];
    }
    return List<Map<String, dynamic>>.from(jsonDecode(response.body)['data']);
  }

  static Future<bool> updateTransaction({
    required String id,
    required double amount,
    required String category,
    required String date,
  }) async {
    final headers = await _authHeaders();
    if (headers == null) return false;

    final response = await http.put(
      _uri('/transactions/$id'),
      headers: headers,
      body: jsonEncode({'amount': amount, 'category': category, 'date': date}),
    );

    if (response.statusCode != 200) {
      _logFailure('UpdateTransaction', response);
      return false;
    }
    return true;
  }

  static Future<bool> deleteTransaction({required String id}) async {
    final headers = await _authHeaders();
    if (headers == null) return false;

    final response =
        await http.delete(_uri('/transactions/$id'), headers: headers);

    if (response.statusCode != 200) {
      _logFailure('DeleteTransaction', response);
      return false;
    }
    return true;
  }

  // ------------------ Analytics ------------------

  static Future<List<double>> _getBuckets(
    String operation,
    String path, [
    Map<String, String>? queryParameters,
  ]) async {
    final headers = await _authHeaders();
    if (headers == null) return [];

    final response =
        await http.get(_uri(path, queryParameters), headers: headers);

    if (response.statusCode != 200) {
      _logFailure(operation, response);
      return [];
    }
    return _parseBuckets(jsonDecode(response.body)['buckets']);
  }

  static Future<List<double>> getGeneralBuckets() =>
      _getBuckets('GetGeneralBuckets', '/transactions/general-buckets');

  static Future<List<double>> getCategoryBuckets(String category) =>
      _getBuckets(
        'GetCategoryBuckets',
        '/transactions/category-buckets',
        {'category': category},
      );

  static Future<List<double>> getGeneralBucketsByMonth(String month) =>
      _getBuckets(
        'GetGeneralBucketsByMonth',
        '/transactions/general-buckets-by-month',
        {'month': month},
      );

  static Future<List<double>> getCategoryBucketsByMonth(
    String category,
    String month,
  ) =>
      _getBuckets(
        'GetCategoryBucketsByMonth',
        '/transactions/category-buckets-by-month',
        {'category': category, 'month': month},
      );

  static Future<List<Map<String, dynamic>>> getMonthlyCategoryPercentages(
    String month,
  ) async {
    final headers = await _authHeaders();
    if (headers == null) return [];

    final response = await http.get(
      _uri('/transactions/monthly-category-percentages', {'month': month}),
      headers: headers,
    );

    if (response.statusCode != 200) {
      _logFailure('GetMonthlyCategoryPercentages', response);
      return [];
    }
    return List<Map<String, dynamic>>.from(jsonDecode(response.body)['data']);
  }

  // ------------------ Assets ------------------

  static Future<List<Map<String, dynamic>>> getAssets() async {
    final headers = await _authHeaders();
    if (headers == null) return [];

    final response = await http.get(_uri('/assets'), headers: headers);

    if (response.statusCode != 200) {
      _logFailure('GetAssets', response);
      return [];
    }
    return List<Map<String, dynamic>>.from(jsonDecode(response.body)['data']);
  }

  static Future<Map<String, dynamic>?> addAsset({
    required String bankName,
    required int amount,
    required String lastFourDigits,
    required String brand,
    required String color,
  }) async {
    final headers = await _authHeaders();
    if (headers == null) return null;

    final response = await http.post(
      _uri('/assets'),
      headers: headers,
      body: jsonEncode({
        'bankName': bankName,
        'amount': amount,
        'lastFourDigits': lastFourDigits,
        'brand': brand,
        'color': color,
      }),
    );

    if (!_isSuccess(response)) {
      _logFailure('AddAsset', response);
      return null;
    }
    return jsonDecode(response.body)['data'];
  }

  static Future<bool> updateAsset({
    required String id,
    required String bankName,
    required int amount,
    required String lastFourDigits,
    required String brand,
    required String color,
  }) async {
    final headers = await _authHeaders();
    if (headers == null) return false;

    final response = await http.put(
      _uri('/assets/$id'),
      headers: headers,
      body: jsonEncode({
        'bankName': bankName,
        'amount': amount,
        'lastFourDigits': lastFourDigits,
        'brand': brand,
        'color': color,
      }),
    );

    if (response.statusCode != 200) {
      _logFailure('UpdateAsset', response);
      return false;
    }
    return true;
  }

  static Future<bool> deleteAsset(String id) async {
    final headers = await _authHeaders();
    if (headers == null) return false;

    final response = await http.delete(_uri('/assets/$id'), headers: headers);

    if (response.statusCode != 200) {
      _logFailure('DeleteAsset', response);
      return false;
    }
    return true;
  }
}
