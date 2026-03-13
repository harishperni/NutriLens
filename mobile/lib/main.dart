import 'package:flutter/material.dart';
import 'package:nutrilens_mobile/src/api_client.dart';
import 'package:nutrilens_mobile/src/screens/dashboard_screen.dart';

void main() {
  runApp(const NutriLensApp());
}

class NutriLensApp extends StatefulWidget {
  const NutriLensApp({super.key});

  @override
  State<NutriLensApp> createState() => _NutriLensAppState();
}

class _NutriLensAppState extends State<NutriLensApp> {
  @override
  Widget build(BuildContext context) {
    final api = ApiClient(token: null);
    return MaterialApp(
      title: 'NutriLens',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF006A6A)),
        useMaterial3: true,
      ),
      home: DashboardScreen(
        api: api,
        onLogout: () {},
      ),
    );
  }
}
