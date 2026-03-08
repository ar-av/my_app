import 'package:flutter/material.dart';

class WeeklyStreakCard extends StatelessWidget {
  final int count;              // Current stars (0 to 5)
  final VoidCallback onReset;   // Function when "Reset" is pressed
  // Note: onLog is removed because it happens automatically now.

  const WeeklyStreakCard({
    super.key,
    required this.count,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 20, 30, 80),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. TITLE
          const Text(
            "Your Weekly Streak",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          
          // 2. SUBTITLE
          Text(
            "Workouts this week: $count",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 30),

          // 3. ⭐️ STAR ROW ⭐️
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              bool isFilled = index < count;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Icon(
                  isFilled ? Icons.star : Icons.star_border,
                  color: isFilled ? Colors.amberAccent : Colors.white24,
                  size: 40,
                ),
              );
            }),
          ),

          const SizedBox(height: 40),

          // 4. RESET BUTTON (Centered)
          // We removed the Log button, so we just have this one.
          SizedBox(
            width: double.infinity, // Make it wide
            child: ElevatedButton(
              onPressed: onReset,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: const StadiumBorder(),
              ),
              child: const Text("Reset Week"),
            ),
          ),
        ],
      ),
    );
  }
}