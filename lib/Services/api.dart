import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:envolet_frontend/Model/login_model.dart';
import 'package:envolet_frontend/Model/register_model.dart';

class Api {
  static const String baseUrl = "http://localhost:5001";
  //static const String baseUrl = 'http://172.20.10.6:5001';
  // static const String baseUrl = 'http://192.168.0.23:5001';

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

// ------------------ Transactions ------------------

  // Add Transaction
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

  // Get all Transactions
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

  // Update Transaction
  static Future<bool> updateTransaction({
    required String id,
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

    final response = await http.put(
      Uri.parse("$baseUrl/transactions/$id"),
      headers: header,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      print("Transaction updated");
      return true;
    } else {
      print("UpdateTransaction failed: ${response.body}");
      return false;
    }
  }

  // Delete Transaction
  static Future<bool> deleteTransaction({
    required String id,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return false;

    final header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.delete(
      Uri.parse("$baseUrl/transactions/$id"),
      headers: header,
    );

    if (response.statusCode == 200) {
      print("Transaction deleted");
      return true;
    } else {
      print("DeleteTransaction failed: ${response.body}");
      return false;
    }
  }

  // ------------------ Assets ------------------

  // Get all assets
  static Future<List<Map<String, dynamic>>> getAssets() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return [];

    final header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(
      Uri.parse("$baseUrl/assets"),
      headers: header,
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body)['data']);
    } else {
      print("getAssets failed: ${response.body}");
      return [];
    }
  }

// Add asset
  static Future<Map<String, dynamic>?> addAsset({
    required String bankName,
    required int amount,
    required String lastFourDigits,
    required String brand,
    required String color,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return null;

    final header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = {
      "bankName": bankName,
      "amount": amount,
      "lastFourDigits": lastFourDigits,
      "brand": brand,
      "color": color,
    };

    final response = await http.post(
      Uri.parse("$baseUrl/assets"),
      headers: header,
      body: jsonEncode(body),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      print("addAsset failed: ${response.body}");
      return null;
    }
  }

// Delete asset
  static Future<bool> deleteAsset(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return false;

    final header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.delete(
      Uri.parse("$baseUrl/assets/$id"),
      headers: header,
    );

    return response.statusCode == 200;
  }

  static Future<bool> updateAsset({
    required String id,
    required String bankName,
    required int amount,
    required String lastFourDigits,
    required String brand,
    required String color,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return false;

    final header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = {
      "bankName": bankName,
      "amount": amount,
      "lastFourDigits": lastFourDigits,
      "brand": brand,
      "color": color,
    };

    final response = await http.put(
      Uri.parse("$baseUrl/assets/$id"),
      headers: header,
      body: jsonEncode(body),
    );

    return response.statusCode == 200;
  }
}
