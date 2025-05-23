import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:envolet_frontend/Model/login_model.dart';
import 'package:envolet_frontend/Model/register_model.dart';

class Api {
  static const String baseUrl = "http://localhost:5001";
//  static const String baseUrl = 'http://172.20.10.6:5001';

  static Future<LoginModel?> loginCall({
    required String email,
    required String password,
  }) async {
    final body = {"email": email, "password": password};
    final header = {
      'Content-Type': 'application/json',
      'Accept': 'application/json;charset=UTF-8',
    };

    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      body: jsonEncode(body),
      headers: header,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final result = LoginModel.fromJson(data);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", result.token);
      return result;
    } else {
      print("Login failed: ${response.body}");
      return null;
    }
  }

  static Future<RegisterModel?> registerCall({
    required String name,
    required String surname,
    required String email,
    required String password,
  }) async {
    final body = {
      "name": name,
      "surname": surname,
      "email": email,
      "password": password,
    };

    final header = {
      'Content-Type': 'application/json',
      'Accept': 'application/json;charset=UTF-8',
    };

    final response = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      body: jsonEncode(body),
      headers: header,
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final result = RegisterModel.fromJson(data);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", result.token);
      return result;
    } else {
      print("Register failed: ${response.body}");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getMe() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) return null;

    final header = {
      'Content-Type': 'application/json',
      'Accept': 'application/json;charset=UTF-8',
      'Authorization': 'Bearer $token',
    };

    final response =
        await http.get(Uri.parse("$baseUrl/auth/me"), headers: header);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['user'];
    } else {
      print("GetMe failed: ${response.body}");
      return null;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }

  static Future<bool> deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) return false;

    final header = {
      'Content-Type': 'application/json',
      'Accept': 'application/json;charset=UTF-8',
      'Authorization': 'Bearer $token',
    };

    final response =
        await http.delete(Uri.parse("$baseUrl/auth/delete"), headers: header);

    if (response.statusCode == 200) {
      await prefs.remove("token");
      return true;
    } else {
      print("DeleteAccount failed: ${response.body}");
      return false;
    }
  }
  // ------------------ Budgets ------------------

  static Future<bool> addBudget({
    required String category,
    required double amount,
    required String startDate,
    required String endDate,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return false;

    final header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = {
      "category": category,
      "amount": amount,
      "startDate": startDate,
      "endDate": endDate,
    };

    final response = await http.post(
      Uri.parse("$baseUrl/budgets"),
      headers: header,
      body: jsonEncode(body),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      print("Budget created");
      return true;
    } else {
      print("AddBudget failed: ${response.body}");
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return [];

    final header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response =
        await http.get(Uri.parse("$baseUrl/budgets"), headers: header);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return List<Map<String, dynamic>>.from(data);
    } else {
      print("GetBudgets failed: ${response.body}");
      return [];
    }
  }

// ------------------ Transactions ------------------

  static Future<bool> addTransaction({
    required double amount,
    required String category,
    required String date,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return false;

    final header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = {
      "amount": amount,
      "category": category,
      "date": date,
    };

    final response = await http.post(
      Uri.parse("$baseUrl/transactions"),
      headers: header,
      body: jsonEncode(body),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      print("Transaction added");
      return true;
    } else {
      print("AddTransaction failed: ${response.body}");
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return [];

    final header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response =
        await http.get(Uri.parse("$baseUrl/transactions"), headers: header);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return List<Map<String, dynamic>>.from(data);
    } else {
      print("GetTransactions failed: ${response.body}");
      return [];
    }
  }
}
