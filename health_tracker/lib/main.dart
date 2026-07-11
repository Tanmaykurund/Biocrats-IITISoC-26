import 'package:flutter/material.dart';
import 'package:health_tracker/bottom_nav.dart';
import 'package:health_tracker/home.dart';
import 'package:health_tracker/historyScreen.dart';
import 'bluetooth_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: bottomNav());
  }
}
