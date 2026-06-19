import 'package:flutter/material.dart';
import 'package:nutrilens_mobile/src/api_client.dart';
import 'package:nutrilens_mobile/src/models.dart';

class BarcodeLookupScreen extends StatefulWidget {
  const BarcodeLookupScreen({super.key, required this.api});

  final ApiClient api;

  @override
  State<BarcodeLookupScreen> createState() => _BarcodeLookupScreenState();
}

class _BarcodeLookupScreenState extends State<BarcodeLookupScreen> {
  final _barcodeCtrl = TextEditingController();
  final _gramsCtrl = TextEditingController(text: '100');
  FoodItem? _food;
  String? _error;
  bool _loading = false;
  String _mealType = 'snacks';

  @override
  void dispose() {
    _barcodeCtrl.dispose();
    _gramsCtrl.dispose();
    super.dispose();
  }

  String get _today => DateTime.now().toIso8601String().split('T').first;

  Future<void> _lookup() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final food = await widget.api.lookupBarcode(_barcodeCtrl.text.trim());
      setState(() => _food = food);
    } catch (e) {
      setState(() {
        _food = null;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _log() async {
    if (_food == null) return;
    final grams = double.tryParse(_gramsCtrl.text) ?? 100;
    await widget.api.addMealItem(
      date: _today,
      mealType: _mealType,
      foodId: _food!.id,
      grams: grams,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged from barcode')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barcode Lookup')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _barcodeCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Enter barcode',
              hintText: 'e.g. 1234567890123',
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: _loading ? null : _lookup,
            icon: const Icon(Icons.qr_code),
            label: Text(_loading ? 'Looking up...' : 'Lookup'),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          if (_food != null) ...[
            const SizedBox(height: 14),
            Card(
              child: ListTile(
                title: Text(_food!.displayName),
                subtitle: Text(
                  '${_food!.caloriesPer100g.toStringAsFixed(0)} kcal/100g • ${_food!.source}',
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _mealType,
                    items: const ['breakfast', 'lunch', 'dinner', 'snacks']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) => setState(() => _mealType = value ?? _mealType),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _gramsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Grams'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FilledButton(onPressed: _log, child: const Text('Log This Food')),
          ],
        ],
      ),
    );
  }
}
