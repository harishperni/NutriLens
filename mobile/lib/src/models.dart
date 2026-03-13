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
