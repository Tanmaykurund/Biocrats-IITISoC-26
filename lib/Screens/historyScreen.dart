import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<int> heartRate = [];
  List<int> temperature = [];
  List<int> spO2 = [];
  void updateHeartRate(int heartRateValue, int tempvalue, int O2Value) {
    setState(() {
      heartRate.add(heartRateValue);
      temperature.add(tempvalue);
      spO2.add(O2Value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050827),
      body: SafeArea(
        child: Column(
          children: [
            ListView.builder(
              itemCount: heartRate.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(title: Text('Heart Rate: $heartRate[index]')),
                );
              },
            ), // Add history content here
          ],
        ),
      ),
    );
  }
}
