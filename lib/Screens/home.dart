import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:health_tracker/services/ble_controller.dart';
import 'package:health_tracker/bluetooth_bar.dart';
import 'package:health_tracker/card.dart';

class CustomHomeScreen extends StatelessWidget {
  const CustomHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF050827),
      body: SafeArea(
        child:GetBuilder<BleController>(
          builder: (mycontroller) {
            return Column(
              children: [
                Bluetoothstatusbar(isConnected: mycontroller.isConnected),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: CustomCard(
                        title: 'Heart Rate',
                        value: mycontroller.bpm ?? 0,
                        unit: 'bpm',
                        icon: Icons.favorite,
                        iconColor: const Color.fromARGB(157, 244, 54, 105),
                      ),
                    ),
                    Expanded(
                      child: CustomCard(
                        title: 'SpO2',
                        value: mycontroller.spo2percent ?? 0,
                        unit: '%',
                        icon: Icons.bloodtype,
                        iconColor: const Color.fromARGB(148, 111, 169, 214),
                      ),
                    ),
                  ],
                ),
                CustomCard(
                  title: 'Temperature',
                  value: mycontroller.temp ?? 0,
                  unit: '°C',
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  icon: Icons.thermostat,
                  iconColor: const Color.fromARGB(157, 241, 228, 102),
                ),
              ],
            );
          }
         ),
      ),
    );
  }
}
