import 'package:flutter/material.dart';
import '../widgets/login_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 9, 18, 64),
      appBar: AppBar(
        title: const Text('Hi, Arav'),
        titleTextStyle: const TextStyle(
          color: Color.fromARGB(206, 188, 188, 234),
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: const Color.fromARGB(255, 90, 118, 245),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 150),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const LoginWidget(title: 'GymTrax'),
                const SizedBox(height: 5),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/workout');
                  },
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
