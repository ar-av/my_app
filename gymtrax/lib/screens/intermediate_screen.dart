import 'package:flutter/material.dart';
import '../widgets/intermediate_widget.dart';
import '../widgets/section_header.dart';

class IntermediateScreen extends StatefulWidget {
  const IntermediateScreen({super.key});
  @override
  State<IntermediateScreen> createState() => _IntermediateScreenState();
}

class _IntermediateScreenState extends State<IntermediateScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 9, 18, 64),
      appBar: AppBar(
        title: const Text('Intermediate'),
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
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SectionHeader(title: "Push"),
              IntermediateWidget(label: "Bench Press", startingValue: 0.0),
              SizedBox(height: 15),
              IntermediateWidget(label: "Chest Flies", startingValue: 0.0),
              SizedBox(height: 15),
              IntermediateWidget(label: "Inclined Press", startingValue: 0.0),
              SizedBox(height: 25),

              SectionHeader(title: "Pull"),
              IntermediateWidget(label: "Lat Pull Downs", startingValue: 0.0),
              SizedBox(height: 15),
              IntermediateWidget(label: "Seated Rows", startingValue: 0.0),
              SizedBox(height: 15),
              IntermediateWidget(label: "Deadlift", startingValue: 0.0),
              SizedBox(height: 25),

              SectionHeader(title: "Legs"),
              IntermediateWidget(label: "Squats", startingValue: 0.0),
              SizedBox(height: 15),
              IntermediateWidget(label: "Leg Extension", startingValue: 0.0),
              SizedBox(height: 15),
              IntermediateWidget(label: "Leg Curls", startingValue: 0.0),
              SizedBox(height: 15),
              IntermediateWidget(label: "Calf Raises", startingValue: 0.0),
              SizedBox(height: 25),

              Center(
                child: ElevatedButton(
                  onPressed: null, // Implement later
                  child: Text('Update All'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
