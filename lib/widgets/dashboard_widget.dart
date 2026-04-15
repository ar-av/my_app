import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';
import '../services/db_service.dart';

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key});

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  final DBService _db = DBService();

  late int _timeRemaining;
  Timer? _restTimer;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    _timeRemaining = _db.getRestTimer(); 
  }

  void _toggleTimer() {
    if (_isTimerRunning) {
      _restTimer?.cancel();
      setState(() => _isTimerRunning = false);
    } else {
      setState(() => _isTimerRunning = true);
      _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_timeRemaining > 0) {
            _timeRemaining--;
          } else {
            _restTimer?.cancel();
            _isTimerRunning = false;
            Vibration.vibrate(duration: 500);
          }
        });
      });
    }
  }

  void _resetTimer() {
    _restTimer?.cancel();
    setState(() {
      _timeRemaining = _db.getRestTimer();
      _isTimerRunning = false;
    });
  }

  String getTodayWorkout(List<String> split) {
    if (split.isEmpty) return "Rest";
    int daysSinceEpoch = DateTime.now().difference(DateTime(2024, 1, 1)).inDays;
    int index = daysSinceEpoch % split.length;
    return split[index];
  }

  // --- DIALOGS ---
  void _showSplitEditor(List<String> currentSplit) {
    TextEditingController controller = TextEditingController();
    List<String> tempSplit = List.from(currentSplit);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1C2033),
            title: const Text("Edit Workout Split", style: TextStyle(color: Colors.white)),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...tempSplit.asMap().entries.map((entry) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(entry.value, style: const TextStyle(color: Colors.white)),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                        onPressed: () => setDialogState(() => tempSplit.removeAt(entry.key)),
                      ),
                    );
                  }),
                  TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Add new day (e.g. Arms)",
                      hintStyle: TextStyle(color: Colors.white24),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                    ),
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) {
                        setDialogState(() {
                          tempSplit.add(val.trim());
                          controller.clear();
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) tempSplit.add(controller.text.trim());
                  _db.saveUserSplit(tempSplit);
                  Navigator.pop(ctx);
                },
                child: const Text("Save Split"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showBodyStatEditor(String key, String label, double currentVal) {
    final controller = TextEditingController(text: currentVal.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C2033),
        title: Text("Update $label", style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(labelText: "New Value", labelStyle: const TextStyle(color: Colors.cyanAccent)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              double? val = double.tryParse(controller.text);
              if (val != null && val > 0) {
                _db.saveBodyStat(key, val);
                Navigator.pop(ctx);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showTimerEditor() {
    final controller = TextEditingController(text: _db.getRestTimer().toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C2033),
        title: const Text("Edit Rest Timer", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(labelText: "Default Time (in seconds)", labelStyle: TextStyle(color: Colors.cyanAccent)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              int? newTime = int.tryParse(controller.text);
              if (newTime != null && newTime > 0) {
                _db.saveRestTimer(newTime);
                _resetTimer();
                Navigator.pop(ctx);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('userBox').listenable(),
      builder: (context, Box box, _) {
        
        List<String> mySplit = _db.getUserSplit();
        double weight = _db.getBodyStat('weight', 78.5);
        double height = _db.getBodyStat('height', 180.0);
        int workouts = _db.getWeeklyWorkouts();
        double bmi = weight / ((height / 100) * (height / 100));

        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            children: [
              const Text("Overview", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 25),

              // CARD 1: TARGET
              _buildCard(
                title: "Today's Target (Tap to Edit)",
                child: GestureDetector(
                  onTap: () => _showSplitEditor(mySplit),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(getTodayWorkout(mySplit), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
                      const Icon(Icons.bolt, color: Colors.cyanAccent, size: 40),
                    ],
                  ),
                ),
              ),

              // CARD 2: PROGRESS
              _buildCard(
                title: "Weekly Progress",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("$workouts / 7 Days", style: const TextStyle(fontSize: 18, color: Colors.white)),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (workouts / 7).clamp(0.0, 1.0),
                        backgroundColor: Colors.white10,
                        color: Colors.cyanAccent,
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),

              // CARD 3: STATS
              _buildCard(
                title: "Body Stats (Tap numbers to Edit)",
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () => _showBodyStatEditor('weight', 'Weight (kg)', weight),
                      child: _statColumn("Weight", "${weight}kg"),
                    ),
                    GestureDetector(
                      onTap: () => _showBodyStatEditor('height', 'Height (cm)', height),
                      child: _statColumn("Height", "${height}cm"),
                    ),
                    _statColumn("BMI", bmi.toStringAsFixed(1)),
                  ],
                ),
              ),

              // CARD 4: TIMER (Fixed brackets!)
              _buildCard(
                title: "Rest Timer (Tap time to Edit)",
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (!_isTimerRunning) _showTimerEditor(); 
                      },
                      child: Text(
                        "${(_timeRemaining ~/ 60).toString().padLeft(2, '0')}:${(_timeRemaining % 60).toString().padLeft(2, '0')}",
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          iconSize: 50,
                          color: Colors.cyanAccent,
                          icon: Icon(_isTimerRunning ? Icons.pause_circle_filled : Icons.play_circle_fill),
                          onPressed: _toggleTimer,
                        ),
                        IconButton(
                          iconSize: 50,
                          color: Colors.white38,
                          icon: const Icon(Icons.replay_circle_filled),
                          onPressed: _resetTimer,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1C2033), borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  Widget _statColumn(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.white38)),
      ],
    );
  }
}
