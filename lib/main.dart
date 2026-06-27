
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';

/// ============================================================
/// Main — App entry point
/// ============================================================
/// Keeps it simple:
/// 1. Ensure Flutter is initialized
/// 2. Lock orientation to portrait (medical UI is designed for portrait)
/// 3. Set system UI overlay style (dark status bar for our dark theme)
/// 4. Run the app

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Dark status bar to match our theme
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF1D1F33),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const BioVitalsApp());
}
