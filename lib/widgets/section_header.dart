import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color.fromARGB(255, 119, 141, 249),
        letterSpacing: 7,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.normal,
        decoration: TextDecoration.none,
        backgroundColor: Colors.transparent,
      ),
      strutStyle: const StrutStyle(height: 8, leading: 3.3),
    );
  }
}
