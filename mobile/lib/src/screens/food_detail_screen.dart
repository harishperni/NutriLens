import 'package:flutter/material.dart';
import 'package:nutrilens_mobile/src/models.dart';

class FoodDetailScreen extends StatefulWidget {
  const FoodDetailScreen({
    super.key,
    required this.food,
    required this.initialGrams,
    required this.mealType,
    required this.onLog,
  });

  final FoodItem food;
  final double initialGrams;
  final String mealType;
  final Future<void> Function(double grams) onLog;

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  late final TextEditingController _gramsCtrl;
  bool _logging = false;

  @override
  void initState() {
    super.initState();
    _gramsCtrl = TextEditingController(text: widget.initialGrams.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _gramsCtrl.dispose();
    super.dispose();
  }

  double get _grams => double.tryParse(_gramsCtrl.text) ?? widget.initialGrams;

  double _scale(double value) => value * (_grams / 100);

  Future<void> _logFood() async {
    setState(() => _logging = true);
    try {
      await widget.onLog(_grams);
      if (!mounted) return;
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _logging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.food;
    final scheme = Theme.of(context).colorScheme;
    final foodName = _safeText(food.displayName, fallback: 'Unknown food');
    final source = _safeText(food.source, fallback: 'Unknown source');
    final serving = _safeText(food.servingDescription, fallback: '100 g');
    final mealType = _safeText(widget.mealType, fallback: 'meal');
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F7),
      appBar: AppBar(
        title: const Text('Food Details'),
        backgroundColor: const Color(0xFFF4F8F7),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                colors: [Color(0xFF0E7A71), Color(0xFF18A999)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 18,
                  offset: Offset(0, 8),
                  color: Color(0x22000000),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  foodName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _heroChip(source),
                    _heroChip(serving),
                    _heroChip('logs to $mealType'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _gramsCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'View nutrition for',
                        suffixText: 'grams',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _logging ? null : _logFood,
                    icon: const Icon(Icons.add),
                    label: Text(_logging ? 'Logging...' : 'Log'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _sectionTitle('Macros'),
          _nutrientGrid([
            _Nutrient('Calories', _scale(food.caloriesPer100g), 'kcal', scheme.primary),
            _Nutrient('Protein', _scale(food.proteinPer100g), 'g', const Color(0xFF2E7D32)),
            _Nutrient('Carbs', _scale(food.carbsPer100g), 'g', const Color(0xFF1565C0)),
            _Nutrient('Fat', _scale(food.fatPer100g), 'g', const Color(0xFF6A1B9A)),
            _Nutrient('Fiber', _scale(food.fiberPer100g), 'g', const Color(0xFF00897B)),
            _Nutrient('Sugar', _scale(food.sugarPer100g), 'g', const Color(0xFFC77700)),
          ]),
          const SizedBox(height: 16),
          _sectionTitle('Fats & Carbs'),
          _nutrientGrid([
            _Nutrient('Net carbs', _scale(food.netCarbsPer100g), 'g', const Color(0xFF1976D2)),
            _Nutrient('Added sugar', _scale(food.addedSugarPer100g), 'g', const Color(0xFFE65100)),
            _Nutrient('Saturated fat', _scale(food.saturatedFatPer100g), 'g', const Color(0xFF8E24AA)),
            _Nutrient('Trans fat', _scale(food.transFatPer100g), 'g', const Color(0xFFC62828)),
            _Nutrient('Mono fat', _scale(food.monounsaturatedFatPer100g), 'g', const Color(0xFF6D4C41)),
            _Nutrient('Poly fat', _scale(food.polyunsaturatedFatPer100g), 'g', const Color(0xFF5D4037)),
            _Nutrient('Cholesterol', _scale(food.cholesterolMgPer100g), 'mg', const Color(0xFFD84315)),
          ]),
          const SizedBox(height: 16),
          _sectionTitle('Minerals'),
          _nutrientGrid([
            _Nutrient('Sodium', _scale(food.sodiumMgPer100g), 'mg', const Color(0xFFD84315)),
            _Nutrient('Potassium', _scale(food.potassiumMgPer100g), 'mg', const Color(0xFF558B2F)),
            _Nutrient('Magnesium', _scale(food.magnesiumMgPer100g), 'mg', const Color(0xFF00897B)),
            _Nutrient('Phosphorus', _scale(food.phosphorusMgPer100g), 'mg', const Color(0xFF00695C)),
            _Nutrient('Zinc', _scale(food.zincMgPer100g), 'mg', const Color(0xFF546E7A)),
            _Nutrient('Iron', _scale(food.ironMgPer100g), 'mg', const Color(0xFF5D4037)),
            _Nutrient('Calcium', _scale(food.calciumMgPer100g), 'mg', const Color(0xFF455A64)),
          ]),
          const SizedBox(height: 16),
          _sectionTitle('Vitamins'),
          _nutrientGrid([
            _Nutrient('Vitamin A', _scale(food.vitaminAMcgPer100g), 'mcg', const Color(0xFFEF6C00)),
            _Nutrient('Vitamin C', _scale(food.vitaminCMgPer100g), 'mg', const Color(0xFF2E7D32)),
            _Nutrient('Vitamin D', _scale(food.vitaminDMcgPer100g), 'mcg', const Color(0xFFF9A825)),
            _Nutrient('Vitamin B12', _scale(food.vitaminB12McgPer100g), 'mcg', const Color(0xFF3949AB)),
            _Nutrient('Folate', _scale(food.folateMcgPer100g), 'mcg', const Color(0xFF7B1FA2)),
          ]),
          const SizedBox(height: 12),
          Text(
            'Values are based on available database data and may be incomplete for some foods.',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _nutrientGrid(List<_Nutrient> nutrients) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: nutrients.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final nutrient = nutrients[index];
        final isEmpty = nutrient.value == 0;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE1E8E5)),
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 36,
                decoration: BoxDecoration(
                  color: nutrient.color,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      nutrient.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      isEmpty ? 'not listed' : '${nutrient.value.toStringAsFixed(1)} ${nutrient.unit}',
                      style: TextStyle(
                        color: isEmpty ? Colors.black45 : Colors.black87,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _safeText(Object? value, {required String fallback}) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return fallback;
  }

  Widget _heroChip(Object? text) {
    final label = _safeText(text, fallback: 'not listed');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x33FFFFFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x55FFFFFF)),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}

class _Nutrient {
  const _Nutrient(this.label, this.value, this.unit, this.color);

  final String label;
  final double value;
  final String unit;
  final Color color;
}
