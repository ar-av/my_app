import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../screens/workout_screen.dart';
import '../widgets/fade_slide.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final _formKey = GlobalKey<FormState>();
  final _db = DBService();
  
  final emailController = TextEditingController();
  final passController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  // --- LOGIC ---
  void _attemptLogin() {
    if (_formKey.currentState!.validate()) {
      String email = emailController.text.trim();
      String password = passController.text;

      bool isSuccess = _db.handleAuth(email, password);
      
      

      if (isSuccess) {
        if (mounted) {
           Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (_) => const WorkoutScreen())
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 10),
                  Text("Invalid Credentials. Try again!"),
                ],
              ),
              backgroundColor: Colors.redAccent.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(20),
            ),
          );
        }
      }
    }
  }

  // Helper: Valid Email Regex
  bool _isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  // --- UI HELPER: Glass Input ---
  Widget _buildGlassInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3), // Dark Glass
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        cursorColor: Colors.cyan,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.cyan.withValues(alpha: 0.7)),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          errorStyle: const TextStyle(color: Colors.redAccent, height: 0.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // REMOVED SCAFFOLD & GRADIENT CONTAINER
    // This widget now returns ONLY the scrollable content form.
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            // 1. LOGO ANIMATION
            FadeSlide(
              index: 0,
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.cyan.withValues(alpha: 0.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyan.withValues(alpha: 0.2),
                      blurRadius: 30,
                      spreadRadius: 10,
                    )
                  ]
                ),
                child: const Icon(Icons.fitness_center, size: 50, color: Colors.cyan),
              ),
            ),
            
            const SizedBox(height: 40),

            FadeSlide(
              index: 1,
              child: const Text(
                "G Y M T R A X",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 5.0,
                ),
              ),
            ),

            const SizedBox(height: 60),

            // 2. INPUTS
            FadeSlide(
              index: 2,
              child: _buildGlassInput(
                controller: emailController,
                hint: "Enter Email",
                icon: Icons.email_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Email is required';
                  if (!_isValidEmail(value)) return 'Enter a valid email';
                  return null;
                },
              ),
            ),

            FadeSlide(
              index: 3,
              child: _buildGlassInput(
                controller: passController,
                hint: "Enter Password",
                icon: Icons.lock_outline,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Password is required';
                  if (value.length < 6) return 'Min 6 characters';
                  return null;
                },
              ),
            ),

            const SizedBox(height: 40),

            // 3. BUTTON
            FadeSlide(
              index: 4,
              child: Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [Colors.cyan, Color(0xFF0055FF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyan.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _attemptLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text(
                    "E n t e r   g y m",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}