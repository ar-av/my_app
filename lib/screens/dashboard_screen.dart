import 'package:flutter/material.dart';
import '../widgets/dashboard_widget.dart';
import 'workout_screen.dart';
import 'progress_screen.dart';
import 'analytical_screen.dart';
import '../widgets/bottom_nav_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  // These are the "Rooms" inside your building
  final List<Widget> _screens = [
    const DashboardWidget(), 
    const WorkoutScreen(),
    const ProgressScreen(),
    const AnalyticalScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D21), // Deep Navy
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onItemTapped: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}