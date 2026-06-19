import 'package:flutter/material.dart';
import 'package:nutrilens_mobile/src/api_client.dart';
import 'package:nutrilens_mobile/src/models.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.api});

  final ApiClient api;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late DateTime _date;
  bool _loading = true;
  String? _error;
  MealLogDayData? _day;
  List<SavedMealData> _savedMeals = [];

  @override
  void initState() {
    super.initState();
    _date = DateTime.now();
    _load();
  }

  String get _dateStr => _date.toIso8601String().split('T').first;

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final day = await widget.api.getMealLogDay(_dateStr);
      final saved = await widget.api.getSavedMeals();
      setState(() {
        _day = day;
        _savedMeals = saved;
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

  Future<void> _editItem(MealLogItemData item) async {
    final ctrl = TextEditingController(text: item.grams.toStringAsFixed(0));
    String mealType = item.mealType;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit ${item.foodName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Grams'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: mealType,
                items: const ['breakfast', 'lunch', 'dinner', 'snacks']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  mealType = value ?? mealType;
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
          ],
        );
      },
    );
    if (result != true) return;

    final grams = double.tryParse(ctrl.text) ?? item.grams;
    await widget.api.updateMealLogItem(itemId: item.id, mealType: mealType, grams: grams);
    _load();
  }

  Future<void> _deleteItem(int id) async {
    await widget.api.deleteMealLogItem(id);
    _load();
  }

  Future<void> _saveCurrentAsTemplate() async {
    final items = _day?.items ?? [];
    if (items.isEmpty) return;
    final ctrl = TextEditingController(text: 'My meal $_dateStr');
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save meal template'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Template name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok != true) return;
    await widget.api.createSavedMeal(name: ctrl.text.trim(), items: items);
    _load();
  }

  Future<void> _logSavedMeal(int id) async {
    await widget.api.logSavedMeal(savedMealId: id, date: _dateStr);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History & Saved Meals'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _date = _date.subtract(const Duration(days: 1));
              });
              _load();
            },
            icon: const Icon(Icons.chevron_left),
          ),
          Center(child: Text(_dateStr)),
          IconButton(
            onPressed: () {
              setState(() {
                _date = _date.add(const Duration(days: 1));
              });
              _load();
            },
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      children: [
                        const Text('Meal Log', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        OutlinedButton.icon(
                          onPressed: (_day?.items.isEmpty ?? true) ? null : _saveCurrentAsTemplate,
                          icon: const Icon(Icons.bookmark_add),
                          label: const Text('Save as meal'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...(_day?.items ?? []).map(
                      (item) => Card(
                        child: ListTile(
                          title: Text(item.foodName),
                          subtitle: Text(
                            '${item.mealType} • ${item.grams.toStringAsFixed(0)}g • ${item.calories.toStringAsFixed(0)} kcal',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(onPressed: () => _editItem(item), icon: const Icon(Icons.edit)),
                              IconButton(onPressed: () => _deleteItem(item.id), icon: const Icon(Icons.delete_outline)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if ((_day?.items.isEmpty ?? true))
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('No meal items on this date.'),
                      ),
                    const SizedBox(height: 18),
                    const Text('Saved Meals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ..._savedMeals.map(
                      (saved) => Card(
                        child: ListTile(
                          title: Text(saved.name),
                          subtitle: Text('${saved.items.length} items'),
                          trailing: FilledButton(
                            onPressed: () => _logSavedMeal(saved.id),
                            child: const Text('Log'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
