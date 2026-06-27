import 'package:flutter/material.dart';


import 'connection_screen.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';

/// ============================================================
/// Home Screen — Bottom navigation shell
/// ============================================================
/// Contains 3 tabs: Dashboard, History, Connection.
/// Holds the state for which tab is selected.

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _navigateToConnection() {
    setState(() => _currentIndex = 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardScreen(
            onNavigateToConnection: _navigateToConnection,
          ),
          const HistoryScreen(),
          const ConnectionScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bluetooth_rounded),
              label: 'Connect',
            ),
          ],
        ),
      ),
    );
  }
}
