import 'package:flutter/material.dart';

class LoginWidget extends StatelessWidget {
  final String title;
  const LoginWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color.fromARGB(255, 119, 141, 249),
        letterSpacing: 14,
        fontSize: 33,
        fontWeight: FontWeight.normal,
        fontStyle: FontStyle.normal,
        decoration: TextDecoration.none,
        backgroundColor: Color.fromARGB(255, 9, 18, 64),
      ),
      strutStyle: const StrutStyle(height: 15, leading: 7),
    );
    // Inside your LoginWidget or LoginScreen, where you handle the login button:
  }
}
