import 'package:flutter/material.dart';
import '../widgets/streak_widget.dart';

class StreakScreen extends StatefulWidget {
  const StreakScreen({super.key});

  @override
  State<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 9, 18, 64),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 90, 118, 245),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              StreakWidget(label: "Your Weekly Streak", target: 6),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
