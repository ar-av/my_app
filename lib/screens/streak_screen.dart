import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/db_service.dart';
import '../widgets/streak_widget.dart'; 
import '../widgets/bottom_nav_bar.dart';


class StreakScreen extends StatefulWidget {
  const StreakScreen({super.key});

  @override
  State<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen> {
  final _db = DBService();

  // Handle the Reset Button press
  void _handleReset() {
    setState(() {
      _db.resetWeek();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 9, 18, 64),
      
      // 1. CLEAN APP BAR
      appBar: AppBar(
        title: const Text(
          "S T R E A K S", // Added spacing in text string for consistency
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 3.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 9, 18, 64),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white70),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // 2. BODY
      body: ValueListenableBuilder(
        valueListenable: Hive.box('userBox').listenable(),
        builder: (context, box, _) {
          
          // Get the count from DB (defaults to 0 if empty)
          int currentCount = _db.getWeeklyWorkouts();

          return Center(
            child: WeeklyStreakCard(
              count: currentCount,
              onReset: _handleReset,
            ),
          );
        },
      ), 
      bottomNavigationBar: const BottomNav(currentIndex: 2),
     
    ); 
  }
}