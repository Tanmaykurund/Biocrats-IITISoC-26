import 'package:flutter/material.dart';
import 'package:health_tracker/bluetooth_bar.dart';
import 'package:health_tracker/card.dart';

class CustomHomeScreen extends StatefulWidget {
  const CustomHomeScreen({super.key});

  @override
  State<CustomHomeScreen> createState() => _CustomHomeScreenState();
}

class _CustomHomeScreenState extends State<CustomHomeScreen> {
  int heartRateValue = 72;

  int spo2Value = 98;

  int temperatureValue = 37;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF050827),
      body: SafeArea(
        child: Column(
          children: [
            Bluetoothstatusbar(isConnected: true),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: CustomCard(
                    title: 'Heart Rate',
                    value: heartRateValue,
                    unit: 'bpm',
                    icon: Icons.favorite,
                    iconColor: const Color.fromARGB(157, 244, 54, 105),
                  ),
                ),
                Expanded(
                  child: CustomCard(
                    title: 'SpO2',
                    value: spo2Value,
                    unit: '%',
                    icon: Icons.bloodtype,
                    iconColor: const Color.fromARGB(148, 111, 169, 214),
                  ),
                ),
              ],
            ),
            CustomCard(
              title: 'Temperature',
              value: temperatureValue,
              unit: '°C',
              width: MediaQuery.of(context).size.width,
              icon: Icons.thermostat,
              iconColor: const Color.fromARGB(157, 241, 228, 102),
            ),
          ],
        ),
      ),
    );
  }
}
