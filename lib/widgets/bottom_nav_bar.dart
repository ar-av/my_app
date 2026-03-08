import 'package:flutter/material.dart';
import '../screens/workout_screen.dart';
import '../screens/progress_screen.dart';
import '../screens/streak_screen.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;

  const BottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      // FLOATING DESIGN
      margin: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 20, 30, 80), // Deep Blue Card
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          
          // COLORS
          selectedItemColor: Colors.cyan,
          unselectedItemColor: Colors.white38,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          
          // LOGIC
          currentIndex: currentIndex,
          onTap: (index) {
            if (index == currentIndex) return; // Don't reload current page

            // NAVIGATION LOGIC (Swaps screens instantly)
            Widget nextPage;
            if (index == 0) {
              nextPage = const WorkoutScreen();
            } else if (index == 1) {
              nextPage = const ProgressScreen();
            } else {
              nextPage = const StreakScreen();
            }

            // This creates a smooth "Fade" transition instead of a "Slide"
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, anim1, anim2) => nextPage,
                transitionDuration: Duration.zero, // Instant swap (like a Tab Bar)
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },
          
          // ICONS
          items: const [
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.home_rounded)), 
              label: 'Home'
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.bar_chart_rounded)), 
              label: 'Progress'
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.local_fire_department_rounded)), 
              label: 'Streak'
            ),
          ],
        ),
      ),
    );
  }
}