import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final int value;
  final String unit;
  final double width;
  final IconData icon;
  final Color iconColor;
  const CustomCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    this.iconColor = const Color.fromARGB(255, 202, 202, 227),
    this.width = 150,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      width: width,
      height: 150,
      decoration: BoxDecoration(
        color: const Color.fromARGB(169, 29, 45, 86),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(209, 4, 4, 7),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.all(10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color.fromARGB(169, 59, 57, 115),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 202, 202, 227),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                child: Text(
                  '$value $unit',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 202, 202, 227),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
