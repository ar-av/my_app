import 'package:flutter/material.dart';
import '../widgets/progress_widget.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 9, 18, 64),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 90, 118, 245),
        title: const Text('Beginner'),
        titleTextStyle: const TextStyle(
          color: Color.fromARGB(206, 188, 188, 234),
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),

      body: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ProgressWidget(
            options: ['Beginner', 'Intermediate'],
            initialValue: 'Beginner',
            onChanged: (value) {
              if (value == 'Beginner') {
                Navigator.pushNamed(context, '/beginner');
              } else if (value == 'Intermediate') {
                Navigator.pushNamed(context, '/intermediate');
              }
            },
          ),
        ),
      ),
    );
  }
}
