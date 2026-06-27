import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants/app_theme.dart';
import 'providers/ble_provider.dart';
import 'providers/vitals_provider.dart';
import 'screens/home_screen.dart';
import 'services/ble_service.dart';
import 'services/database_service.dart';

/// ============================================================
/// BioVitals App — Root widget
/// ============================================================
/// Sets up:
/// 1. Services (BLE, Database) — created once, shared everywhere
/// 2. Providers — wrap the app so all screens can access state
/// 3. Theme — dark medical theme from AppTheme
/// 4. Home screen — entry point for the UI

class BioVitalsApp extends StatefulWidget {
  const BioVitalsApp({super.key});

  @override
  State<BioVitalsApp> createState() => _BioVitalsAppState();
}

class _BioVitalsAppState extends State<BioVitalsApp> {
  // Services are created once and live for the entire app lifetime
  late final BleService _bleService;
  late final DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    _bleService = BleService();
    _databaseService = DatabaseService();
  }

  @override
  void dispose() {
    _bleService.dispose();
    _databaseService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // BLE Provider — manages scanning and connection
        ChangeNotifierProvider(
          create: (_) => BleProvider(_bleService),
        ),
        // Vitals Provider — manages live readings, alerts, sessions
        ChangeNotifierProvider(
          create: (_) => VitalsProvider(_bleService, _databaseService),
        ),
      ],
      child: MaterialApp(
        title: 'BioVitals',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
