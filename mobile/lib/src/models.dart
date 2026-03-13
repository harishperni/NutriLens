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
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as int,
      name: json['name'] as String,
      brand: json['brand'] as String?,
      barcode: json['barcode'] as String?,
      source: json['source'] as String,
      caloriesPer100g: (json['calories_per_100g'] as num).toDouble(),
      proteinPer100g: (json['protein_g_per_100g'] as num).toDouble(),
      carbsPer100g: (json['carbs_g_per_100g'] as num).toDouble(),
      fatPer100g: (json['fat_g_per_100g'] as num).toDouble(),
    );
  }

  String get displayName => brand == null ? name : '$brand $name';
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

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final targets = json['targets'] as Map<String, dynamic>;
    return DashboardData(
      date: json['date'] as String,
      totalCalories: (json['total_calories'] as num).toDouble(),
      totalProteinG: (json['total_protein_g'] as num).toDouble(),
      totalCarbsG: (json['total_carbs_g'] as num).toDouble(),
      totalFatG: (json['total_fat_g'] as num).toDouble(),
      waterMl: json['water_ml'] as int,
      calorieTarget: targets['calorie_target'] as int,
      proteinTargetG: targets['protein_target_g'] as int,
      carbsTargetG: targets['carbs_target_g'] as int,
      fatTargetG: targets['fat_target_g'] as int,
      waterTargetMl: targets['water_target_ml'] as int,
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
      calorieTarget: json['calorie_target'] as int,
      proteinTargetG: json['protein_target_g'] as int,
      carbsTargetG: json['carbs_target_g'] as int,
      fatTargetG: json['fat_target_g'] as int,
      waterTargetMl: json['water_target_ml'] as int,
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
      id: json['id'] as int,
      mealType: json['meal_type'] as String,
      foodId: json['food_id'] as int?,
      foodName: json['food_name'] as String,
      grams: (json['grams'] as num).toDouble(),
      calories: (json['calories'] as num).toDouble(),
      proteinG: (json['protein_g'] as num).toDouble(),
      carbsG: (json['carbs_g'] as num).toDouble(),
      fatG: (json['fat_g'] as num).toDouble(),
    );
  }
}

class MealLogDayData {
  final String date;
  final List<MealLogItemData> items;

  MealLogDayData({required this.date, required this.items});

  factory MealLogDayData.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>;
    return MealLogDayData(
      date: json['date'] as String,
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
      id: json['id'] as int,
      foodId: json['food_id'] as int,
      foodName: json['food_name'] as String,
      source: json['source'] as String,
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
      id: json['id'] as int,
      mealType: json['meal_type'] as String,
      foodId: json['food_id'] as int?,
      foodName: json['food_name'] as String,
      grams: (json['grams'] as num).toDouble(),
      calories: (json['calories'] as num).toDouble(),
      proteinG: (json['protein_g'] as num).toDouble(),
      carbsG: (json['carbs_g'] as num).toDouble(),
      fatG: (json['fat_g'] as num).toDouble(),
    );
  }
}

class SavedMealData {
  final int id;
  final String name;
  final List<SavedMealItemData> items;

  SavedMealData({required this.id, required this.name, required this.items});

  factory SavedMealData.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>;
    return SavedMealData(
      id: json['id'] as int,
      name: json['name'] as String,
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
      date: json['date'] as String,
      calories: (json['calories'] as num).toDouble(),
      proteinG: (json['protein_g'] as num).toDouble(),
      carbsG: (json['carbs_g'] as num).toDouble(),
      fatG: (json['fat_g'] as num).toDouble(),
      waterMl: json['water_ml'] as int,
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
    final rawDays = json['days'] as List<dynamic>;
    return WeeklySummaryData(
      days: rawDays.map((e) => WeeklySummaryDayData.fromJson(e as Map<String, dynamic>)).toList(),
      averageCalories: (json['average_calories'] as num).toDouble(),
      averageProteinG: (json['average_protein_g'] as num).toDouble(),
      averageCarbsG: (json['average_carbs_g'] as num).toDouble(),
      averageFatG: (json['average_fat_g'] as num).toDouble(),
      averageWaterMl: (json['average_water_ml'] as num).toDouble(),
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
      breakfastEnabled: json['breakfast_enabled'] as int,
      lunchEnabled: json['lunch_enabled'] as int,
      dinnerEnabled: json['dinner_enabled'] as int,
      snacksEnabled: json['snacks_enabled'] as int,
      waterEnabled: json['water_enabled'] as int,
      breakfastTime: json['breakfast_time'] as String,
      lunchTime: json['lunch_time'] as String,
      dinnerTime: json['dinner_time'] as String,
      waterIntervalMinutes: json['water_interval_minutes'] as int,
    );
  }
}
