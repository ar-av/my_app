import 'package:flutter/material.dart';
import '../widgets/beginner_widget.dart';
import '../widgets/section_header.dart';

class BeginnerScreen extends StatelessWidget {
  const BeginnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 9, 18, 64),
      appBar: AppBar(
        title: const Text('Beginner'),
        titleTextStyle: const TextStyle(
          color: Color.fromARGB(206, 188, 188, 234),
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: const Color.fromARGB(255, 90, 118, 245),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: "Push"),
              BeginnerWidget(label: "Bench Press", startingValue: 0.0),
              const SizedBox(height: 15),
              BeginnerWidget(label: "Chest Flies", startingValue: 0.0),
              const SizedBox(height: 15),
              BeginnerWidget(label: "Inclined Press", startingValue: 0.0),
              const SizedBox(height: 25),

              SectionHeader(title: "Pull"),
              BeginnerWidget(label: "Lat Pull Downs", startingValue: 0.0),
              const SizedBox(height: 15),
              BeginnerWidget(label: "Seated Rows", startingValue: 0.0),
              const SizedBox(height: 15),
              BeginnerWidget(label: "Deadlift", startingValue: 0.0),
              const SizedBox(height: 25),

              SectionHeader(title: "Legs"),
              BeginnerWidget(label: "Squats", startingValue: 0.0),
              const SizedBox(height: 15),
              BeginnerWidget(label: "Leg Extension", startingValue: 0.0),
              const SizedBox(height: 15),
              BeginnerWidget(label: "Leg Curls", startingValue: 0.0),
              const SizedBox(height: 15),
              BeginnerWidget(label: "Calf Raises", startingValue: 0.0),
              const SizedBox(height: 25),

              Center(
                child: ElevatedButton(
                  onPressed: null, // implement later
                  child: const Text('Update All'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
