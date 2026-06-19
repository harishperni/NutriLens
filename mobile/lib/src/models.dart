double _doubleValue(dynamic value, {double fallback = 0}) {
  if (value is num) return value.toDouble();
  return fallback;
}

int _intValue(dynamic value, {int fallback = 0}) {
  if (value is num) return value.toInt();
  return fallback;
}

String _stringValue(dynamic value, {String fallback = ''}) {
  if (value is String && value.trim().isNotEmpty) return value;
  return fallback;
}

String? _nullableStringValue(dynamic value) {
  if (value is String && value.trim().isNotEmpty) return value;
  return null;
}

class FoodItem {
  final int id;
  final String name;
  final String? brand;
  final String? barcode;
  final String source;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double fiberPer100g;
  final double sugarPer100g;
  final double addedSugarPer100g;
  final double netCarbsPer100g;
  final double saturatedFatPer100g;
  final double transFatPer100g;
  final double monounsaturatedFatPer100g;
  final double polyunsaturatedFatPer100g;
  final double cholesterolMgPer100g;
  final double sodiumMgPer100g;
  final double potassiumMgPer100g;
  final double magnesiumMgPer100g;
  final double phosphorusMgPer100g;
  final double zincMgPer100g;
  final double ironMgPer100g;
  final double calciumMgPer100g;
  final double vitaminAMcgPer100g;
  final double vitaminCMgPer100g;
  final double vitaminDMcgPer100g;
  final double vitaminB12McgPer100g;
  final double folateMcgPer100g;
  final String servingDescription;

  FoodItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.barcode,
    required this.source,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    required this.fiberPer100g,
    required this.sugarPer100g,
    required this.addedSugarPer100g,
    required this.netCarbsPer100g,
    required this.saturatedFatPer100g,
    required this.transFatPer100g,
    required this.monounsaturatedFatPer100g,
    required this.polyunsaturatedFatPer100g,
    required this.cholesterolMgPer100g,
    required this.sodiumMgPer100g,
    required this.potassiumMgPer100g,
    required this.magnesiumMgPer100g,
    required this.phosphorusMgPer100g,
    required this.zincMgPer100g,
    required this.ironMgPer100g,
    required this.calciumMgPer100g,
    required this.vitaminAMcgPer100g,
    required this.vitaminCMgPer100g,
    required this.vitaminDMcgPer100g,
    required this.vitaminB12McgPer100g,
    required this.folateMcgPer100g,
    required this.servingDescription,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: _intValue(json['id']),
      name: _stringValue(json['name'], fallback: 'Unknown food'),
      brand: _nullableStringValue(json['brand']),
      barcode: _nullableStringValue(json['barcode']),
      source: _stringValue(json['source'], fallback: 'UNKNOWN'),
      caloriesPer100g: _doubleValue(json['calories_per_100g']),
      proteinPer100g: _doubleValue(json['protein_g_per_100g']),
      carbsPer100g: _doubleValue(json['carbs_g_per_100g']),
      fatPer100g: _doubleValue(json['fat_g_per_100g']),
      fiberPer100g: _doubleValue(json['fiber_g_per_100g']),
      sugarPer100g: _doubleValue(json['sugar_g_per_100g']),
      addedSugarPer100g: _doubleValue(json['added_sugar_g_per_100g']),
      netCarbsPer100g: _doubleValue(json['net_carbs_g_per_100g']),
      saturatedFatPer100g: _doubleValue(json['saturated_fat_g_per_100g']),
      transFatPer100g: _doubleValue(json['trans_fat_g_per_100g']),
      monounsaturatedFatPer100g: _doubleValue(json['monounsaturated_fat_g_per_100g']),
      polyunsaturatedFatPer100g: _doubleValue(json['polyunsaturated_fat_g_per_100g']),
      cholesterolMgPer100g: _doubleValue(json['cholesterol_mg_per_100g']),
      sodiumMgPer100g: _doubleValue(json['sodium_mg_per_100g']),
      potassiumMgPer100g: _doubleValue(json['potassium_mg_per_100g']),
      magnesiumMgPer100g: _doubleValue(json['magnesium_mg_per_100g']),
      phosphorusMgPer100g: _doubleValue(json['phosphorus_mg_per_100g']),
      zincMgPer100g: _doubleValue(json['zinc_mg_per_100g']),
      ironMgPer100g: _doubleValue(json['iron_mg_per_100g']),
      calciumMgPer100g: _doubleValue(json['calcium_mg_per_100g']),
      vitaminAMcgPer100g: _doubleValue(json['vitamin_a_mcg_per_100g']),
      vitaminCMgPer100g: _doubleValue(json['vitamin_c_mg_per_100g']),
      vitaminDMcgPer100g: _doubleValue(json['vitamin_d_mcg_per_100g']),
      vitaminB12McgPer100g: _doubleValue(json['vitamin_b12_mcg_per_100g']),
      folateMcgPer100g: _doubleValue(json['folate_mcg_per_100g']),
      servingDescription: _stringValue(json['serving_description'], fallback: '100 g'),
    );
  }

  String get displayName {
    final safeName = name.trim().isEmpty ? 'Unknown food' : name.trim();
    final safeBrand = brand?.trim();
    return safeBrand == null || safeBrand.isEmpty ? safeName : '$safeBrand $safeName';
  }
}

class DashboardData {
  final String date;
  final double totalCalories;
  final double totalProteinG;
  final double totalCarbsG;
  final double totalFatG;
  final int waterMl;
  final int calorieTarget;
  final int proteinTargetG;
  final int carbsTargetG;
  final int fatTargetG;
  final int waterTargetMl;

  DashboardData({
    required this.date,
    required this.totalCalories,
    required this.totalProteinG,
    required this.totalCarbsG,
    required this.totalFatG,
    required this.waterMl,
    required this.calorieTarget,
    required this.proteinTargetG,
    required this.carbsTargetG,
    required this.fatTargetG,
    required this.waterTargetMl,
  });

  DashboardData copyWith({
    String? date,
    double? totalCalories,
    double? totalProteinG,
    double? totalCarbsG,
    double? totalFatG,
    int? waterMl,
    int? calorieTarget,
    int? proteinTargetG,
    int? carbsTargetG,
    int? fatTargetG,
    int? waterTargetMl,
  }) {
    return DashboardData(
      date: date ?? this.date,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProteinG: totalProteinG ?? this.totalProteinG,
      totalCarbsG: totalCarbsG ?? this.totalCarbsG,
      totalFatG: totalFatG ?? this.totalFatG,
      waterMl: waterMl ?? this.waterMl,
      calorieTarget: calorieTarget ?? this.calorieTarget,
      proteinTargetG: proteinTargetG ?? this.proteinTargetG,
      carbsTargetG: carbsTargetG ?? this.carbsTargetG,
      fatTargetG: fatTargetG ?? this.fatTargetG,
      waterTargetMl: waterTargetMl ?? this.waterTargetMl,
    );
  }

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final targets = (json['targets'] as Map<String, dynamic>?) ?? {};
    return DashboardData(
      date: _stringValue(json['date']),
      totalCalories: _doubleValue(json['total_calories']),
      totalProteinG: _doubleValue(json['total_protein_g']),
      totalCarbsG: _doubleValue(json['total_carbs_g']),
      totalFatG: _doubleValue(json['total_fat_g']),
      waterMl: _intValue(json['water_ml']),
      calorieTarget: _intValue(targets['calorie_target'], fallback: 2000),
      proteinTargetG: _intValue(targets['protein_target_g'], fallback: 120),
      carbsTargetG: _intValue(targets['carbs_target_g'], fallback: 220),
      fatTargetG: _intValue(targets['fat_target_g'], fallback: 70),
      waterTargetMl: _intValue(targets['water_target_ml'], fallback: 2500),
    );
  }
}

class GoalData {
  final int calorieTarget;
  final int proteinTargetG;
  final int carbsTargetG;
  final int fatTargetG;
  final int waterTargetMl;

  GoalData({
    required this.calorieTarget,
    required this.proteinTargetG,
    required this.carbsTargetG,
    required this.fatTargetG,
    required this.waterTargetMl,
  });

  factory GoalData.fromJson(Map<String, dynamic> json) {
    return GoalData(
      calorieTarget: _intValue(json['calorie_target'], fallback: 2000),
      proteinTargetG: _intValue(json['protein_target_g'], fallback: 120),
      carbsTargetG: _intValue(json['carbs_target_g'], fallback: 220),
      fatTargetG: _intValue(json['fat_target_g'], fallback: 70),
      waterTargetMl: _intValue(json['water_target_ml'], fallback: 2500),
    );
  }
}

class MealLogItemData {
  final int id;
  final String mealType;
  final int? foodId;
  final String foodName;
  final double grams;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  MealLogItemData({
    required this.id,
    required this.mealType,
    required this.foodId,
    required this.foodName,
    required this.grams,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  factory MealLogItemData.fromJson(Map<String, dynamic> json) {
    return MealLogItemData(
      id: _intValue(json['id']),
      mealType: _stringValue(json['meal_type'], fallback: 'snacks'),
      foodId: json['food_id'] == null ? null : _intValue(json['food_id']),
      foodName: _stringValue(json['food_name'], fallback: 'Unknown food'),
      grams: _doubleValue(json['grams']),
      calories: _doubleValue(json['calories']),
      proteinG: _doubleValue(json['protein_g']),
      carbsG: _doubleValue(json['carbs_g']),
      fatG: _doubleValue(json['fat_g']),
    );
  }
}

class MealLogDayData {
  final String date;
  final List<MealLogItemData> items;

  MealLogDayData({required this.date, required this.items});

  factory MealLogDayData.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>?) ?? [];
    return MealLogDayData(
      date: _stringValue(json['date']),
      items: rawItems.map((e) => MealLogItemData.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class FavoriteFoodData {
  final int id;
  final int foodId;
  final String foodName;
  final String source;

  FavoriteFoodData({
    required this.id,
    required this.foodId,
    required this.foodName,
    required this.source,
  });

  factory FavoriteFoodData.fromJson(Map<String, dynamic> json) {
    return FavoriteFoodData(
      id: _intValue(json['id']),
      foodId: _intValue(json['food_id']),
      foodName: _stringValue(json['food_name'], fallback: 'Unknown food'),
      source: _stringValue(json['source'], fallback: 'UNKNOWN'),
    );
  }
}

class SavedMealItemData {
  final int id;
  final String mealType;
  final int? foodId;
  final String foodName;
  final double grams;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  SavedMealItemData({
    required this.id,
    required this.mealType,
    required this.foodId,
    required this.foodName,
    required this.grams,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  factory SavedMealItemData.fromJson(Map<String, dynamic> json) {
    return SavedMealItemData(
      id: _intValue(json['id']),
      mealType: _stringValue(json['meal_type'], fallback: 'snacks'),
      foodId: json['food_id'] == null ? null : _intValue(json['food_id']),
      foodName: _stringValue(json['food_name'], fallback: 'Unknown food'),
      grams: _doubleValue(json['grams']),
      calories: _doubleValue(json['calories']),
      proteinG: _doubleValue(json['protein_g']),
      carbsG: _doubleValue(json['carbs_g']),
      fatG: _doubleValue(json['fat_g']),
    );
  }
}

class SavedMealData {
  final int id;
  final String name;
  final List<SavedMealItemData> items;

  SavedMealData({required this.id, required this.name, required this.items});

  factory SavedMealData.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>?) ?? [];
    return SavedMealData(
      id: _intValue(json['id']),
      name: _stringValue(json['name'], fallback: 'Saved meal'),
      items: rawItems.map((e) => SavedMealItemData.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class WeeklySummaryDayData {
  final String date;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final int waterMl;

  WeeklySummaryDayData({
    required this.date,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.waterMl,
  });

  factory WeeklySummaryDayData.fromJson(Map<String, dynamic> json) {
    return WeeklySummaryDayData(
      date: _stringValue(json['date']),
      calories: _doubleValue(json['calories']),
      proteinG: _doubleValue(json['protein_g']),
      carbsG: _doubleValue(json['carbs_g']),
      fatG: _doubleValue(json['fat_g']),
      waterMl: _intValue(json['water_ml']),
    );
  }
}

class WeeklySummaryData {
  final List<WeeklySummaryDayData> days;
  final double averageCalories;
  final double averageProteinG;
  final double averageCarbsG;
  final double averageFatG;
  final double averageWaterMl;

  WeeklySummaryData({
    required this.days,
    required this.averageCalories,
    required this.averageProteinG,
    required this.averageCarbsG,
    required this.averageFatG,
    required this.averageWaterMl,
  });

  factory WeeklySummaryData.fromJson(Map<String, dynamic> json) {
    final rawDays = (json['days'] as List<dynamic>?) ?? [];
    return WeeklySummaryData(
      days: rawDays.map((e) => WeeklySummaryDayData.fromJson(e as Map<String, dynamic>)).toList(),
      averageCalories: _doubleValue(json['average_calories']),
      averageProteinG: _doubleValue(json['average_protein_g']),
      averageCarbsG: _doubleValue(json['average_carbs_g']),
      averageFatG: _doubleValue(json['average_fat_g']),
      averageWaterMl: _doubleValue(json['average_water_ml']),
    );
  }
}

class NotificationPreferenceData {
  final int breakfastEnabled;
  final int lunchEnabled;
  final int dinnerEnabled;
  final int snacksEnabled;
  final int waterEnabled;
  final String breakfastTime;
  final String lunchTime;
  final String dinnerTime;
  final int waterIntervalMinutes;

  NotificationPreferenceData({
    required this.breakfastEnabled,
    required this.lunchEnabled,
    required this.dinnerEnabled,
    required this.snacksEnabled,
    required this.waterEnabled,
    required this.breakfastTime,
    required this.lunchTime,
    required this.dinnerTime,
    required this.waterIntervalMinutes,
  });

  factory NotificationPreferenceData.fromJson(Map<String, dynamic> json) {
    return NotificationPreferenceData(
      breakfastEnabled: _intValue(json['breakfast_enabled'], fallback: 1),
      lunchEnabled: _intValue(json['lunch_enabled'], fallback: 1),
      dinnerEnabled: _intValue(json['dinner_enabled'], fallback: 1),
      snacksEnabled: _intValue(json['snacks_enabled'], fallback: 1),
      waterEnabled: _intValue(json['water_enabled'], fallback: 1),
      breakfastTime: _stringValue(json['breakfast_time'], fallback: '08:00'),
      lunchTime: _stringValue(json['lunch_time'], fallback: '12:30'),
      dinnerTime: _stringValue(json['dinner_time'], fallback: '19:00'),
      waterIntervalMinutes: _intValue(json['water_interval_minutes'], fallback: 120),
    );
  }
}
