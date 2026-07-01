import 'package:flutter/material.dart';
import 'package:health_tracker/bluetooth_bar.dart';
import 'package:health_tracker/card.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CustomHomeScreen(),
    );
  }
}

class CustomHomeScreen extends StatelessWidget {
  const CustomHomeScreen({super.key});
  final int heartRateValue = 72;
  final int spo2Value = 98;
  final int temperatureValue = 37;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF050827),
      body: SafeArea(
        child: Column(
          children: [
            Bluetoothstatusbar(isConnected: true),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomCard(
                  title: 'Heart Rate',
                  value: heartRateValue,
                  unit: 'bpm',
                  icon: Icons.favorite,
                  iconColor: const Color.fromARGB(157, 244, 54, 105),
                  width: 200,
                ),
                CustomCard(
                  title: 'SpO2',
                  value: spo2Value,
                  unit: '%',
                  width: 200,
                  icon: Icons.bloodtype,
                  iconColor: const Color.fromARGB(148, 111, 169, 214),
                ),
              ],
            ),
            SizedBox(height: 5),
            CustomCard(
              title: 'Temperature',
              value: temperatureValue,
              unit: '°C',
              width: 404,
              icon: Icons.thermostat,
              iconColor: const Color.fromARGB(157, 241, 228, 102),
            ),
          ],
        ),
      ),
    );
  }
}
