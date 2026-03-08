import 'package:flutter/material.dart';
import '../services/db_service.dart';

class ProgressWidget extends StatelessWidget {
  final String exerciseName; // <--- Combines title & key into one!

  const ProgressWidget({
    super.key,
    required this.exerciseName,
  });

  @override
  Widget build(BuildContext context) {
    final db = DBService();
    
    // Get current value directly from DB using the exerciseName
    double currentWeight = db.getPR(exerciseName, defaultValue: 0.0);

    // 1. LOGIC: Handle both + and -
    void updateWeight(double amount) {
      double newTotal = currentWeight + amount;
      
      // Prevent going below zero
      if (newTotal < 0) newTotal = 0;

      // Save using the exerciseName as the key
      db.saveWeight(exerciseName, newTotal);
      
      // Different message for add vs remove
      String msg = amount > 0 
          ? "Gains! Increased to $newTotal kg" 
          : "Weight dropped to $newTotal kg";

      ScaffoldMessenger.of(context).clearSnackBars(); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          duration: const Duration(milliseconds: 500),
          backgroundColor: amount > 0 ? Colors.cyan : Colors.deepOrange,
        ),
      );
    }

    // 2. UI: Helper for a single button
    Widget buildButton(double val, Color bg, Color text) {
      String label = val > 0 ? "+$val" : "$val"; 

      return ElevatedButton(
        onPressed: () => updateWeight(val),
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: text,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          minimumSize: const Size(60, 36), 
          shape: const StadiumBorder(),
        ),
        child: Text(
          label, 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 20, 30, 80), 
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE & WEIGHT
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                exerciseName, // <--- Displays the name here
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 18, 
                  fontWeight: FontWeight.bold
                ),
              ),
              Text(
                "$currentWeight kg",
                style: const TextStyle(
                  color: Colors.cyan, 
                  fontSize: 18, 
                  fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          
          // ROW 1: INCREASE (Green/White)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildButton(1.25, Colors.white, Colors.black),
              buildButton(2.5, Colors.white, Colors.black),
              buildButton(5.0, Colors.white, Colors.black),
            ],
          ),
          
          const SizedBox(height: 8), 

          // ROW 2: DECREASE (Red/White)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildButton(-1.25, Colors.white10, Colors.redAccent),
              buildButton(-2.5, Colors.white10, Colors.redAccent),
              buildButton(-5.0, Colors.white10, Colors.redAccent),
            ],
          )
        ],
      ),
    );
  }
}