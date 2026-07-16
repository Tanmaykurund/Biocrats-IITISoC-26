import 'package:flutter/material.dart';
import 'package:health_tracker/bluetooth_screen.dart';
import 'package:health_tracker/historyScreen.dart';
import 'package:health_tracker/home.dart';

class bottomNav extends StatefulWidget {
  const bottomNav({super.key});

  @override
  State<bottomNav> createState() => _bottomNavState();
}

class _bottomNavState extends State<bottomNav> {
  int selectedIndex = 0;
  PageController pageController = PageController();
  void onTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
    pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        children: [
          CustomHomeScreen(),
          HistoryScreen(),
          MyHomePage(title: ' '),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF050827),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bluetooth),
            label: 'Bluetooth',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Color.fromARGB(255, 0, 229, 255),
        unselectedItemColor: Color.fromARGB(255, 151, 179, 223),
        onTap: onTapped,
      ),
    );
  }
}
