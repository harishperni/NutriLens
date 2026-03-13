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

  Future<MealLogDayData> getMealLogDay(String date) async {
    final response = await http.get(
      Uri.parse('$baseUrl/meal-logs?date=$date'),
      headers: _headers(),
    );
    if (response.statusCode != 200) {
      throw Exception(_errorFromResponse(response, fallback: 'Meal logs load failed'));
    }
    return MealLogDayData.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> updateMealLogItem({
    required int itemId,
    required String mealType,
    required double grams,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/meal-logs/items/$itemId'),
      headers: _headers(jsonBody: true),
      body: jsonEncode({
        'meal_type': mealType,
        'grams': grams,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception(_errorFromResponse(response, fallback: 'Meal update failed'));
    }
  }

  Future<void> deleteMealLogItem(int itemId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/meal-logs/items/$itemId'),
      headers: _headers(),
    );
    if (response.statusCode != 204) {
      throw Exception(_errorFromResponse(response, fallback: 'Meal delete failed'));
    }
  }

  Future<List<FavoriteFoodData>> getRecentFoods() async {
    final response = await http.get(
      Uri.parse('$baseUrl/foods/recent'),
      headers: _headers(),
    );
    if (response.statusCode != 200) {
      throw Exception(_errorFromResponse(response, fallback: 'Recent foods load failed'));
    }
    final body = jsonDecode(response.body) as List<dynamic>;
    return body.map((e) => FavoriteFoodData.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<FavoriteFoodData>> getFavorites() async {
    final response = await http.get(
      Uri.parse('$baseUrl/favorites'),
      headers: _headers(),
    );
    if (response.statusCode != 200) {
      throw Exception(_errorFromResponse(response, fallback: 'Favorites load failed'));
    }
    final body = jsonDecode(response.body) as List<dynamic>;
    return body.map((e) => FavoriteFoodData.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> addFavorite(int foodId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/favorites'),
      headers: _headers(jsonBody: true),
      body: jsonEncode({'food_id': foodId}),
    );
    if (response.statusCode != 201) {
      throw Exception(_errorFromResponse(response, fallback: 'Add favorite failed'));
    }
  }

  Future<void> removeFavorite(int favoriteId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/favorites/$favoriteId'),
      headers: _headers(),
    );
    if (response.statusCode != 204) {
      throw Exception(_errorFromResponse(response, fallback: 'Remove favorite failed'));
    }
  }

  Future<List<SavedMealData>> getSavedMeals() async {
    final response = await http.get(
      Uri.parse('$baseUrl/saved-meals'),
      headers: _headers(),
    );
    if (response.statusCode != 200) {
      throw Exception(_errorFromResponse(response, fallback: 'Saved meals load failed'));
    }
    final body = jsonDecode(response.body) as List<dynamic>;
    return body.map((e) => SavedMealData.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> createSavedMeal({
    required String name,
    required List<MealLogItemData> items,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/saved-meals'),
      headers: _headers(jsonBody: true),
      body: jsonEncode({
        'name': name,
        'items': items
            .map((item) => {
                  'meal_type': item.mealType,
                  'food_id': item.foodId,
                  'food_name': item.foodName,
                  'grams': item.grams,
                  'calories': item.calories,
                  'protein_g': item.proteinG,
                  'carbs_g': item.carbsG,
                  'fat_g': item.fatG,
                })
            .toList(),
      }),
    );
    if (response.statusCode != 201) {
      throw Exception(_errorFromResponse(response, fallback: 'Save meal failed'));
    }
  }

  Future<void> logSavedMeal({
    required int savedMealId,
    required String date,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/saved-meals/$savedMealId/log'),
      headers: _headers(jsonBody: true),
      body: jsonEncode({'date': date}),
    );
    if (response.statusCode != 201) {
      throw Exception(_errorFromResponse(response, fallback: 'Log saved meal failed'));
    }
  }

  Future<WeeklySummaryData> getWeeklySummary(String endDate) async {
    final response = await http.get(
      Uri.parse('$baseUrl/analytics/weekly?end_date=$endDate'),
      headers: _headers(),
    );
    if (response.statusCode != 200) {
      throw Exception(_errorFromResponse(response, fallback: 'Weekly summary failed'));
    }
    return WeeklySummaryData.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<NotificationPreferenceData> getNotificationPreferences() async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/preferences'),
      headers: _headers(),
    );
    if (response.statusCode != 200) {
      throw Exception(_errorFromResponse(response, fallback: 'Notification preferences failed'));
    }
    return NotificationPreferenceData.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<NotificationPreferenceData> updateNotificationPreferences(
    NotificationPreferenceData prefs,
  ) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/notifications/preferences'),
      headers: _headers(jsonBody: true),
      body: jsonEncode({
        'breakfast_enabled': prefs.breakfastEnabled,
        'lunch_enabled': prefs.lunchEnabled,
        'dinner_enabled': prefs.dinnerEnabled,
        'snacks_enabled': prefs.snacksEnabled,
        'water_enabled': prefs.waterEnabled,
        'breakfast_time': prefs.breakfastTime,
        'lunch_time': prefs.lunchTime,
        'dinner_time': prefs.dinnerTime,
        'water_interval_minutes': prefs.waterIntervalMinutes,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception(_errorFromResponse(response, fallback: 'Save notifications failed'));
    }
    return NotificationPreferenceData.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<GoalData> getGoals() async {
    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: _headers(),
    );
    if (response.statusCode != 200) {
      throw Exception(_errorFromResponse(response, fallback: 'Goal load failed'));
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return GoalData.fromJson(body['goal'] as Map<String, dynamic>);
  }

  Future<GoalData> updateGoals(GoalData goal) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/me/goals'),
      headers: _headers(jsonBody: true),
      body: jsonEncode({
        'calorie_target': goal.calorieTarget,
        'protein_target_g': goal.proteinTargetG,
        'carbs_target_g': goal.carbsTargetG,
        'fat_target_g': goal.fatTargetG,
        'water_target_ml': goal.waterTargetMl,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception(_errorFromResponse(response, fallback: 'Goal update failed'));
    }
    return GoalData.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<FoodItem> lookupBarcode(String barcode) async {
    final response = await http.get(
      Uri.parse('$baseUrl/foods/barcode/${Uri.encodeComponent(barcode)}'),
      headers: _headers(),
    );
    if (response.statusCode != 200) {
      throw Exception(_errorFromResponse(response, fallback: 'Barcode lookup failed'));
    }
    return FoodItem.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
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
