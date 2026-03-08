import 'package:flutter/material.dart';

class StreakWidget extends StatefulWidget {
  final String label;
  final int target;

  const StreakWidget({super.key, required this.label, this.target = 6});

  @override
  State<StreakWidget> createState() => _StreakWidgetState();
}

class _StreakWidgetState extends State<StreakWidget> {
  int _workoutsThisWeek = 0;
  int _stars = 0;
  String _comment = "";

  void _logWorkout() {
    setState(() {
      if (_workoutsThisWeek < 7) {
        _workoutsThisWeek++;
      }
      _updateStarsAndComment();
    });
  }

  void _resetWeek() {
    setState(() {
      _workoutsThisWeek = 0;
      _stars = 0;
      _comment = "";
    });
  }

  void _updateStarsAndComment() {
    if (_workoutsThisWeek >= 6) {
      _stars = 5;
      _comment = "FUTURE ARNOLD IN MAKING";
    } else if (_workoutsThisWeek == 5) {
      _stars = 4;
      _comment = "YOU DON'T BACK DOWN!";
    } else if (_workoutsThisWeek == 4) {
      _stars = 3;
      _comment = "GRIND MODE!";
    } else if (_workoutsThisWeek == 3) {
      _stars = 2;
      _comment = "CONSISTENCY NEEDED!";
    } else if (_workoutsThisWeek == 2) {
      _stars = 1;
      _comment = "NOT ENOUGH!";
    } else if (_workoutsThisWeek == 1) {
      _stars = 0;
      _comment = "WAKE UP!";
    } else {
      _stars = 0;
      _comment = "NEXT WEEK TRY HARDER!";
    }
  }

  Widget _buildStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        5,
        (index) => Icon(
          index < _stars ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 28,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 9, 18, 64),
      margin: const EdgeInsets.all(14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                color: Color.fromARGB(206, 188, 188, 234),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(padding: const EdgeInsets.all(20)),
            const SizedBox(height: 20),
            Text(
              "Workouts this week: $_workoutsThisWeek",
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 10),
            _buildStars(),
            const SizedBox(height: 8),
            Text(
              _comment,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _logWorkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text("Log Workout"),
                ),
                ElevatedButton(
                  onPressed: _resetWeek,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Reset Week"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
