import 'package:flutter/material.dart';
import 'package:nutrilens_mobile/src/api_client.dart';
import 'package:nutrilens_mobile/src/models.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.api});

  final ApiClient api;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _loading = true;
  String? _error;
  GoalData? _goal;
  NotificationPreferenceData? _prefs;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final goal = await widget.api.getGoals();
      final prefs = await widget.api.getNotificationPreferences();
      setState(() {
        _goal = goal;
        _prefs = prefs;
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
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null) return Scaffold(body: Center(child: Text(_error!)));
    if (_goal == null || _prefs == null) return const Scaffold(body: Center(child: Text('No settings')));

    final goal = _goal!;
    final prefs = _prefs!;
    return Scaffold(
      appBar: AppBar(title: const Text('Goals & Reminders')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Daily Goals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _goalCard(
            'Calories',
            goal.calorieTarget.toDouble(),
            1200,
            4500,
            (v) => setState(() => _goal = GoalData(
                  calorieTarget: v.toInt(),
                  proteinTargetG: goal.proteinTargetG,
                  carbsTargetG: goal.carbsTargetG,
                  fatTargetG: goal.fatTargetG,
                  waterTargetMl: goal.waterTargetMl,
                )),
          ),
          _goalCard(
            'Protein (g)',
            goal.proteinTargetG.toDouble(),
            30,
            260,
            (v) => setState(() => _goal = GoalData(
                  calorieTarget: goal.calorieTarget,
                  proteinTargetG: v.toInt(),
                  carbsTargetG: goal.carbsTargetG,
                  fatTargetG: goal.fatTargetG,
                  waterTargetMl: goal.waterTargetMl,
                )),
          ),
          _goalCard(
            'Carbs (g)',
            goal.carbsTargetG.toDouble(),
            40,
            500,
            (v) => setState(() => _goal = GoalData(
                  calorieTarget: goal.calorieTarget,
                  proteinTargetG: goal.proteinTargetG,
                  carbsTargetG: v.toInt(),
                  fatTargetG: goal.fatTargetG,
                  waterTargetMl: goal.waterTargetMl,
                )),
          ),
          _goalCard(
            'Fat (g)',
            goal.fatTargetG.toDouble(),
            20,
            180,
            (v) => setState(() => _goal = GoalData(
                  calorieTarget: goal.calorieTarget,
                  proteinTargetG: goal.proteinTargetG,
                  carbsTargetG: goal.carbsTargetG,
                  fatTargetG: v.toInt(),
                  waterTargetMl: goal.waterTargetMl,
                )),
          ),
          _goalCard(
            'Water (ml)',
            goal.waterTargetMl.toDouble(),
            500,
            6000,
            (v) => setState(() => _goal = GoalData(
                  calorieTarget: goal.calorieTarget,
                  proteinTargetG: goal.proteinTargetG,
                  carbsTargetG: goal.carbsTargetG,
                  fatTargetG: goal.fatTargetG,
                  waterTargetMl: v.toInt(),
                )),
          ),
          FilledButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              await widget.api.updateGoals(_goal!);
              if (!mounted) return;
              messenger.showSnackBar(const SnackBar(content: Text('Goals saved')));
            },
            child: const Text('Save Goals'),
          ),
          const SizedBox(height: 18),
          const Text('Reminders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text('Breakfast reminder'),
            value: prefs.breakfastEnabled == 1,
            onChanged: (v) => setState(() => _prefs = _copyPrefs(prefs, breakfastEnabled: v ? 1 : 0)),
          ),
          SwitchListTile(
            title: const Text('Lunch reminder'),
            value: prefs.lunchEnabled == 1,
            onChanged: (v) => setState(() => _prefs = _copyPrefs(prefs, lunchEnabled: v ? 1 : 0)),
          ),
          SwitchListTile(
            title: const Text('Dinner reminder'),
            value: prefs.dinnerEnabled == 1,
            onChanged: (v) => setState(() => _prefs = _copyPrefs(prefs, dinnerEnabled: v ? 1 : 0)),
          ),
          SwitchListTile(
            title: const Text('Snacks reminder'),
            value: prefs.snacksEnabled == 1,
            onChanged: (v) => setState(() => _prefs = _copyPrefs(prefs, snacksEnabled: v ? 1 : 0)),
          ),
          SwitchListTile(
            title: const Text('Water reminders'),
            value: prefs.waterEnabled == 1,
            onChanged: (v) => setState(() => _prefs = _copyPrefs(prefs, waterEnabled: v ? 1 : 0)),
          ),
          ListTile(
            title: const Text('Water interval (minutes)'),
            subtitle: Slider(
              value: prefs.waterIntervalMinutes.toDouble(),
              min: 15,
              max: 240,
              divisions: 15,
              label: prefs.waterIntervalMinutes.toString(),
              onChanged: (v) => setState(() => _prefs = _copyPrefs(prefs, waterIntervalMinutes: v.toInt())),
            ),
            trailing: Text('${prefs.waterIntervalMinutes}m'),
          ),
          FilledButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              await widget.api.updateNotificationPreferences(_prefs!);
              if (!mounted) return;
              messenger.showSnackBar(const SnackBar(content: Text('Reminder settings saved')));
            },
            child: const Text('Save Reminders'),
          ),
        ],
      ),
    );
  }

  Widget _goalCard(String title, double value, double min, double max, ValueChanged<double> onChanged) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: 20,
          label: value.toStringAsFixed(0),
          onChanged: onChanged,
        ),
        trailing: Text(value.toStringAsFixed(0)),
      ),
    );
  }

  NotificationPreferenceData _copyPrefs(
    NotificationPreferenceData current, {
    int? breakfastEnabled,
    int? lunchEnabled,
    int? dinnerEnabled,
    int? snacksEnabled,
    int? waterEnabled,
    int? waterIntervalMinutes,
  }) {
    return NotificationPreferenceData(
      breakfastEnabled: breakfastEnabled ?? current.breakfastEnabled,
      lunchEnabled: lunchEnabled ?? current.lunchEnabled,
      dinnerEnabled: dinnerEnabled ?? current.dinnerEnabled,
      snacksEnabled: snacksEnabled ?? current.snacksEnabled,
      waterEnabled: waterEnabled ?? current.waterEnabled,
      breakfastTime: current.breakfastTime,
      lunchTime: current.lunchTime,
      dinnerTime: current.dinnerTime,
      waterIntervalMinutes: waterIntervalMinutes ?? current.waterIntervalMinutes,
    );
  }
}
