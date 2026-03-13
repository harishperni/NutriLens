import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:nutrilens_mobile/src/models.dart';

class ApiClient {
  ApiClient({required this.token});

  final String? token;

  // Android emulator needs 10.0.2.2, iOS simulator can use localhost.
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  Map<String, String> _headers({bool jsonBody = false}) {
    final headers = <String, String>{};
    if (jsonBody) {
      headers['Content-Type'] = 'application/json';
    }
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<String> login({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers(jsonBody: true),
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception(_errorFromResponse(response, fallback: 'Login failed'));
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['access_token'] as String;
  }

  Future<String> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers(jsonBody: true),
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception(_errorFromResponse(response, fallback: 'Register failed'));
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['access_token'] as String;
  }

  Future<List<FoodItem>> searchFoods(String query, {String? provider}) async {
    final providerPart = provider == null || provider.isEmpty
        ? ''
        : '&provider=${Uri.encodeQueryComponent(provider)}';
    final response = await http.get(
      Uri.parse('$baseUrl/foods/search?q=${Uri.encodeQueryComponent(query)}$providerPart'),
      headers: _headers(),
    );
    if (response.statusCode != 200) {
      throw Exception(_errorFromResponse(response, fallback: 'Food search failed'));
    }
    final body = jsonDecode(response.body) as List<dynamic>;
    return body
        .map((item) => FoodItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> addMealItem({
    required String date,
    required String mealType,
    required int foodId,
    required double grams,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/meal-logs/items'),
      headers: _headers(jsonBody: true),
      body: jsonEncode({
        'date': date,
        'meal_type': mealType,
        'food_id': foodId,
        'quantity': 1,
        'unit': 'grams',
        'grams': grams,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception(_errorFromResponse(response, fallback: 'Add meal failed'));
    }
  }

  Future<void> addWater({
    required String date,
    required int amountMl,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/hydration/logs'),
      headers: _headers(jsonBody: true),
      body: jsonEncode({
        'date': date,
        'amount_ml': amountMl,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception(_errorFromResponse(response, fallback: 'Hydration update failed'));
    }
  }

  Future<DashboardData> getDashboard(String date) async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard?date=$date'),
      headers: _headers(),
    );
    if (response.statusCode != 200) {
      throw Exception(_errorFromResponse(response, fallback: 'Dashboard load failed'));
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return DashboardData.fromJson(body);
  }

  String _errorFromResponse(http.Response response, {required String fallback}) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final detail = body['detail'];
      if (detail is String && detail.isNotEmpty) {
        return detail;
      }
    } catch (_) {
      // ignore parse failures
    }
    return '$fallback (status: ${response.statusCode})';
  }
}
