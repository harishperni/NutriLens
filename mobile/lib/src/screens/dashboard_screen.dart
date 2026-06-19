import 'package:flutter/material.dart';
import 'package:nutrilens_mobile/src/api_client.dart';
import 'package:nutrilens_mobile/src/models.dart';
import 'package:nutrilens_mobile/src/screens/barcode_lookup_screen.dart';
import 'package:nutrilens_mobile/src/screens/food_search_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.api,
    required this.onLogout,
  });

  final ApiClient api;
  final VoidCallback onLogout;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardData? _data;
  String? _error;
  bool _loading = true;

  String get _today => DateTime.now().toIso8601String().split('T').first;

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
      final data = await widget.api.getDashboard(_today);
      setState(() {
        _data = data;
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

  Future<void> _addWater() async {
    try {
      await widget.api.addWater(date: _today, amountMl: 250);
      await _load();
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
        backgroundColor: const Color(0xFFF4F8F7),
        elevation: 0,
        title: const Text(
          'NutriLens',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF4F8F7), Color(0xFFE7F4EF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('Error: $_error'))
                : _data == null
                    ? const Center(child: Text('No dashboard data'))
                    : _DashboardBody(data: _data!),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'water',
            onPressed: _addWater,
            backgroundColor: scheme.primaryContainer,
            foregroundColor: scheme.onPrimaryContainer,
            icon: const Icon(Icons.water_drop),
            label: const Text('+250ml'),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'barcode',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BarcodeLookupScreen(api: widget.api),
                ),
              );
              if (mounted) _load();
            },
            icon: const Icon(Icons.qr_code),
            label: const Text('Barcode'),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'food',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FoodSearchScreen(api: widget.api),
                ),
              );
              if (mounted) {
                _load();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Log Food'),
          ),
        ],
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final caloriesProgress = (data.totalCalories / data.calorieTarget).clamp(0.0, 1.0);
    final waterProgress = (data.waterMl / data.waterTargetMl).clamp(0.0, 1.0);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF0E7A71), Color(0xFF18A999)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(
                blurRadius: 18,
                offset: Offset(0, 8),
                color: Color(0x33000000),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Today',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 4),
              Text(
                '${data.totalCalories.toStringAsFixed(0)} kcal',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Daily calorie progress',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: caloriesProgress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(6),
                backgroundColor: const Color(0x66FFFFFF),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _metric(
          title: 'Calories',
          value: '${data.totalCalories.toStringAsFixed(0)} / ${data.calorieTarget}',
          icon: Icons.local_fire_department,
          color: const Color(0xFFFF7043),
        ),
        _metric(
          title: 'Protein',
          value: '${data.totalProteinG.toStringAsFixed(1)}g / ${data.proteinTargetG}g',
          icon: Icons.fitness_center,
          color: const Color(0xFF2E7D32),
        ),
        _metric(
          title: 'Carbs',
          value: '${data.totalCarbsG.toStringAsFixed(1)}g / ${data.carbsTargetG}g',
          icon: Icons.grain,
          color: const Color(0xFF1565C0),
        ),
        _metric(
          title: 'Fat',
          value: '${data.totalFatG.toStringAsFixed(1)}g / ${data.fatTargetG}g',
          icon: Icons.opacity,
          color: const Color(0xFF6A1B9A),
        ),
        _metric(
          title: 'Water',
          value: '${data.waterMl}ml / ${data.waterTargetMl}ml',
          icon: Icons.water_drop,
          color: const Color(0xFF00897B),
        ),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hydration',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: waterProgress,
                  minHeight: 9,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 6),
                Text('${(waterProgress * 100).toStringAsFixed(0)}% of daily target'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _metric({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.14),
          foregroundColor: color,
          child: Icon(icon),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Text(value),
      ),
    );
  }
}
