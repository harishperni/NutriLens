import 'package:flutter/material.dart';
import 'package:nutrilens_mobile/src/api_client.dart';
import 'package:nutrilens_mobile/src/models.dart';

class WeeklyProgressScreen extends StatefulWidget {
  const WeeklyProgressScreen({
    super.key,
    required this.api,
    this.refreshToken = 0,
  });

  final ApiClient api;
  final int refreshToken;

  @override
  State<WeeklyProgressScreen> createState() => _WeeklyProgressScreenState();
}

class _WeeklyProgressScreenState extends State<WeeklyProgressScreen> {
  bool _loading = true;
  String? _error;
  WeeklySummaryData? _summary;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant WeeklyProgressScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshToken != oldWidget.refreshToken) {
      _load(showSpinner: _summary == null);
    }
  }

  Future<void> _load({bool showSpinner = true}) async {
    if (showSpinner) {
      setState(() {
        _loading = true;
        _error = null;
      });
    } else {
      setState(() {
        _error = null;
      });
    }
    final today = DateTime.now().toIso8601String().split('T').first;
    try {
      final summary = await widget.api.getWeeklySummary(today);
      setState(() {
        _summary = summary;
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

  @override
  Widget build(BuildContext context) {
    final summary = _summary;
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Progress')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : summary == null
                  ? const Center(child: Text('No summary'))
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Avg calories: ${summary.averageCalories.toStringAsFixed(0)} kcal'),
                                Text('Avg protein: ${summary.averageProteinG.toStringAsFixed(1)} g'),
                                Text('Avg carbs: ${summary.averageCarbsG.toStringAsFixed(1)} g'),
                                Text('Avg fat: ${summary.averageFatG.toStringAsFixed(1)} g'),
                                Text('Avg water: ${summary.averageWaterMl.toStringAsFixed(0)} ml'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...summary.days.map(
                          (day) => Card(
                            child: ListTile(
                              title: Text(day.date),
                              subtitle: Text(
                                'kcal ${day.calories.toStringAsFixed(0)} • '
                                'P ${day.proteinG.toStringAsFixed(1)} • '
                                'C ${day.carbsG.toStringAsFixed(1)} • '
                                'F ${day.fatG.toStringAsFixed(1)}',
                              ),
                              trailing: Text('${day.waterMl} ml'),
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }
}
