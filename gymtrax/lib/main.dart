import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/workout_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/beginner_screen.dart';
import 'screens/intermediate_screen.dart';
import 'screens/streak_screen.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
      routes: {
        '/workout': (context) => const WorkoutScreen(),
        '/progress': (context) => const ProgressScreen(),
        '/beginner': (context) => const BeginnerScreen(),
        '/intermediate': (context) => const IntermediateScreen(),
        '/streak': (context) => const StreakScreen(),
      },
    ),
  );
}
