import 'package:flutter/material.dart';
import '../widgets/workout_input.dart';
import '../widgets/section_header.dart';
import 'progress_screen.dart';
import 'streak_screen.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  int _selectedIndex = 0; // Default to WorkoutScreen

  final List<Widget> _screens = [
    const WorkoutScreenContent(), // Workout content
    const ProgressScreen(), // Progress screen
    const StreakScreen(), // Streak screen
  ];

  void _onItemTapped(int index) {
    if (index == 0) {
      setState(() {
        _selectedIndex = 0;
      });
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProgressScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const StreakScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 9, 18, 64),
      appBar: AppBar(
        title: const Text('GYMTRAX'),
        titleTextStyle: const TextStyle(
          color: Color.fromARGB(206, 190, 190, 247),
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: const Color.fromARGB(255, 90, 118, 245),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.vertical(
            bottom: Radius.circular(6)
          ),
        ),
        
      ),
      body: _screens[_selectedIndex], // Display the selected screen
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.whatshot), label: 'Streak'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: const Color.fromARGB(255, 81, 106, 219),
        onTap: _onItemTapped,
      ),
    );
  }
}

class WorkoutScreenContent extends StatelessWidget {
  const WorkoutScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: "Push"),
            WorkoutInput(
              label: "Bench Press",
              controller: TextEditingController(),
            ),
            const SizedBox(height: 15),
            WorkoutInput(
              label: "Inclined Press",
              controller: TextEditingController(),
            ),
            const SizedBox(height: 15),
            WorkoutInput(
              label: "Chest Flies",
              controller: TextEditingController(),
            ),
            const SizedBox(height: 25),

            const SectionHeader(title: "Pull"),
            WorkoutInput(
              label: "Lat Pull Downs",
              controller: TextEditingController(),
            ),
            const SizedBox(height: 15),
            WorkoutInput(
              label: "Seated Rows",
              controller: TextEditingController(),
            ),
            const SizedBox(height: 15),
            WorkoutInput(
              label: "Deadlift",
              controller: TextEditingController(),
            ),
            const SizedBox(height: 25),

            const SectionHeader(title: "Legs"),
            WorkoutInput(label: "Squats", controller: TextEditingController()),
            const SizedBox(height: 15),
            WorkoutInput(
              label: "Leg Extension",
              controller: TextEditingController(),
            ),
            const SizedBox(height: 15),
            WorkoutInput(
              label: "Leg Curls",
              controller: TextEditingController(),
            ),
            const SizedBox(height: 15),
            WorkoutInput(
              label: "Calf Raises",
              controller: TextEditingController(),
            ),
            const SizedBox(height: 25),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Add functionality here if needed
                },
                child: const Text('Update All'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
