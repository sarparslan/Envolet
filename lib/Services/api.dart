import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:envolet_frontend/Model/login_model.dart';
import 'package:envolet_frontend/Model/register_model.dart';

class Api {
  static const String baseUrl = "http://localhost:5001";

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
      final result = LoginModel.fromJson(jsonDecode(response.body));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", result.token);
      return result;
    } else {
      print("Login failed: ${response.body}");
      return null;
    }
  }

  static Future<RegisterModel?> registerCall({
    required String email,
    required String password,
  }) async {
    final body = {"email": email, "password": password};
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
      final result = RegisterModel.fromJson(jsonDecode(response.body));
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
}
