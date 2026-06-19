import 'package:flutter/material.dart';
import 'package:nutrilens_mobile/src/api_client.dart';
import 'package:nutrilens_mobile/src/screens/dashboard_screen.dart';
import 'package:nutrilens_mobile/src/screens/food_search_screen.dart';
import 'package:nutrilens_mobile/src/screens/history_screen.dart';
import 'package:nutrilens_mobile/src/screens/settings_screen.dart';
import 'package:nutrilens_mobile/src/screens/weekly_progress_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.api});

  final ApiClient api;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  int _mealLogVersion = 0;

  void _onMealLogChanged() {
    setState(() {
      _mealLogVersion += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(
        api: widget.api,
        onLogout: () {},
        refreshToken: _mealLogVersion,
      ),
      FoodSearchScreen(api: widget.api, onMealLogChanged: _onMealLogChanged),
      HistoryScreen(api: widget.api, onMealLogChanged: _onMealLogChanged),
      WeeklyProgressScreen(api: widget.api, refreshToken: _mealLogVersion),
      SettingsScreen(api: widget.api),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) {
          setState(() {
            _index = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.manage_search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Meals',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
