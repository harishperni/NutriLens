import 'package:flutter/material.dart';
import 'package:nutrilens_mobile/src/api_client.dart';
import 'package:nutrilens_mobile/src/models.dart';

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({super.key, required this.api});

  final ApiClient api;

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final _searchCtrl = TextEditingController();
  final _gramsCtrl = TextEditingController(text: '100');
  String _mealType = 'breakfast';
  String _provider = 'all';
  List<FoodItem> _results = [];
  Set<int> _favoriteFoodIds = {};
  String? _error;
  bool _loading = false;
  final List<String> _quickSearch = [
    'chicken',
    'rice',
    'egg',
    'apple',
    'salmon',
    'milk',
  ];
  final List<Map<String, String>> _providers = const [
    {'value': 'all', 'label': 'All Sources'},
    {'value': 'spoonacular', 'label': 'Spoon Only'},
    {'value': 'spoon_recipe', 'label': 'Spoon Recipes'},
    {'value': 'usda', 'label': 'USDA Only'},
    {'value': 'open_food_facts', 'label': 'OFF Only'},
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    _gramsCtrl.dispose();
    super.dispose();
  }

  String get _today => DateTime.now().toIso8601String().split('T').first;

  Future<void> _search() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final favorites = await widget.api.getFavorites();
      final providerParam = _provider == 'all' ? null : _provider;
      final results = await widget.api.searchFoods(
        _searchCtrl.text.trim(),
        provider: providerParam,
      );
      setState(() {
        _favoriteFoodIds = favorites.map((e) => e.foodId).where((id) => id > 0).toSet();
        _results = results;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _toggleFavorite(FoodItem item) async {
    if (_favoriteFoodIds.contains(item.id)) return;
    try {
      await widget.api.addFavorite(item.id);
      setState(() => _favoriteFoodIds.add(item.id));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to favorites')));
    } catch (_) {}
  }

  Future<void> _logFood(FoodItem item) async {
    final grams = double.tryParse(_gramsCtrl.text) ?? 100;
    try {
      await widget.api.addMealItem(
        date: _today,
        mealType: _mealType,
        foodId: item.id,
        grams: grams,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logged ${item.displayName} ($grams g)')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F7),
      appBar: AppBar(
        title: const Text('Food Search'),
        backgroundColor: const Color(0xFFF4F8F7),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Search food',
                              hintText: 'oats, banana, yogurt...',
                              prefixIcon: Icon(Icons.search),
                            ),
                            onSubmitted: (_) => _search(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 90,
                          child: TextField(
                            controller: _gramsCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Grams'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        FilledButton(
                          onPressed: _loading ? null : _search,
                          child: const Text('Find'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _quickSearch
                          .map(
                            (term) => ActionChip(
                              label: Text(term),
                              onPressed: () {
                                _searchCtrl.text = term;
                                _search();
                              },
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['breakfast', 'lunch', 'dinner', 'snacks']
                          .map(
                            (type) => ChoiceChip(
                              label: Text(type),
                              selected: _mealType == type,
                              onSelected: (_) {
                                setState(() {
                                  _mealType = type;
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _providers.map((entry) {
                        final value = entry['value']!;
                        final label = entry['label']!;
                        return ChoiceChip(
                          label: Text(label),
                          selected: _provider == value,
                          onSelected: (_) {
                            setState(() {
                              _provider = value;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: scheme.error),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _results.isEmpty
                      ? const Center(
                          child: Text(
                            'No foods yet. Try searching: chicken, rice, egg, apple.',
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          itemCount: _results.length,
                          itemBuilder: (context, index) {
                            final item = _results[index];
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  title: Text(
                                    item.displayName,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        '${item.caloriesPer100g.toStringAsFixed(0)} kcal/100g '
                                        'P ${item.proteinPer100g.toStringAsFixed(1)} '
                                        'C ${item.carbsPer100g.toStringAsFixed(1)} '
                                        'F ${item.fatPer100g.toStringAsFixed(1)}',
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: item.source == 'USDA'
                                              ? const Color(0xFFD8F3DC)
                                              : const Color(0xFFDDEBFF),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          item.source,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ],
                  ),
                                  trailing: SizedBox(
                                    width: 124,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          tooltip: 'Favorite',
                                          onPressed: () => _toggleFavorite(item),
                                          icon: Icon(
                                            _favoriteFoodIds.contains(item.id)
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: _favoriteFoodIds.contains(item.id)
                                                ? Colors.red
                                                : null,
                                          ),
                                        ),
                                        FilledButton.tonal(
                                          onPressed: () => _logFood(item),
                                          child: const Text('Log'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
