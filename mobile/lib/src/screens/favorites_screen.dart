import 'package:flutter/material.dart';
import 'package:nutrilens_mobile/src/api_client.dart';
import 'package:nutrilens_mobile/src/models.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key, required this.api});

  final ApiClient api;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _loading = true;
  String? _error;
  List<FavoriteFoodData> _favorites = [];
  List<FavoriteFoodData> _recent = [];

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
      final favorites = await widget.api.getFavorites();
      final recent = await widget.api.getRecentFoods();
      setState(() {
        _favorites = favorites;
        _recent = recent;
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

  Future<void> _favoriteRecent(FavoriteFoodData food) async {
    if (food.foodId <= 0) return;
    await widget.api.addFavorite(food.foodId);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites & Recents')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text('Favorites', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ..._favorites.map(
                      (fav) => Card(
                        child: ListTile(
                          title: Text(fav.foodName),
                          subtitle: Text(fav.source),
                          trailing: IconButton(
                            icon: const Icon(Icons.favorite, color: Colors.red),
                            onPressed: () async {
                              await widget.api.removeFavorite(fav.id);
                              _load();
                            },
                          ),
                        ),
                      ),
                    ),
                    if (_favorites.isEmpty) const Text('No favorites yet.'),
                    const SizedBox(height: 18),
                    const Text('Recent Foods', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ..._recent.map(
                      (item) => Card(
                        child: ListTile(
                          title: Text(item.foodName),
                          subtitle: Text(item.source),
                          trailing: IconButton(
                            icon: const Icon(Icons.favorite_border),
                            onPressed: () => _favoriteRecent(item),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

