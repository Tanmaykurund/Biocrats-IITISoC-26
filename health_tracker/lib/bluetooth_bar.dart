import 'package:flutter/material.dart';

class Bluetoothstatusbar extends StatelessWidget {
  const Bluetoothstatusbar({super.key, required this.isConnected});

  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: isConnected
            ? const Color.fromARGB(151, 95, 219, 99)
            : const Color.fromARGB(149, 244, 120, 111),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Icon(
            isConnected ? Icons.bluetooth : Icons.bluetooth_disabled,
            color: isConnected
                ? const Color.fromARGB(233, 106, 239, 110)
                : const Color.fromARGB(227, 250, 124, 115),
          ),
          Text(
            'Bluetooth: ${isConnected ? 'Connected' : 'Disconnected'}',
            style: TextStyle(
              color: isConnected
                  ? const Color.fromARGB(255, 147, 216, 149)
                  : const Color.fromARGB(255, 214, 135, 130),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
