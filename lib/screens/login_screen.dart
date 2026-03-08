import 'package:flutter/material.dart';
import '../widgets/login_widget.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. THE LAYOUT & BACKGROUND
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
             Color(0xFF020617),
            Color.fromARGB(255, 9, 18, 64),
            ],
          ),
        ),
        // 2. THE APP BAR (Optional, overlaying the background)
        child: SafeArea(
          child: Column(
            children: [
               AppBar(
                title: const Text(
                  "H i   u s e r",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.transparent, // Transparent to show gradient
                elevation: 0,
                centerTitle: true,
              ),
              
              // 3. THE WIDGET (Expanded to fill the rest of the screen)
              const Expanded(
                child: Center(
                  child: LoginWidget(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}