import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/db_service.dart';
import '../widgets/workout_input.dart';
import '../widgets/section_header.dart';


class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final _db = DBService();

  // 1. DYNAMIC DATA STRUCTURES
  // This holds the structure of your workout
 final Map<String, List<String>> _exercises = {
    "Push": [],
    "Pull": [],
    "Legs": []
  };

  // This holds ALL your controllers dynamically
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();

    // Load lists and setup controllers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  // 2. LOAD EVERYTHING FROM DATABASE
  void _initializeData() {
    setState(() {
      // Load the lists from Hive (or use these defaults if brand new)
      _exercises["Push"] = _db.getExerciseList("Push", defaultList: ["Bench Press", "Inclined Press", "Chest Flies"]);
      _exercises["Pull"] = _db.getExerciseList("Pull", defaultList: ["Lat Pulldowns", "Seated Rows", "Deadlift"]);
      _exercises["Legs"] = _db.getExerciseList("Legs", defaultList: ["Squats", "Leg Extension", "Leg Curls", "Calf Raises"]);

      // Generate a controller for every exercise found
      for (var category in _exercises.keys) {
        for (var ex in _exercises[category]!) {
          _controllers[ex] = TextEditingController();
          
          // Fetch saved weight
          double savedValue = _db.getPR(ex, defaultValue: 0.0);
          if (savedValue > 0) {
            _controllers[ex]!.text = savedValue.toString();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    // Dispose all dynamic controllers to prevent memory leaks
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // 3. SAVE ALL GAINS
  void _updateAll() {
    var hasWorkoutData = false;

    for (var ex in _controllers.keys) {
      final val = double.tryParse(_controllers[ex]!.text) ?? 0;
      if (val > 0) {
        hasWorkoutData = true;
      }
      _db.saveWeight(ex, val);
    }

    if (hasWorkoutData) {
      _db.autoLogWorkout();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          hasWorkoutData
              ? "Workout saved and streak updated."
              : "Workout saved. Add a weight to count it toward your streak.",
        ),
        backgroundColor: Colors.cyan,
        duration: Duration(seconds: 1),
      ),
    );
  }

  // 4. THE POPUP TO ADD A NEW EXERCISE
  void _showAddExerciseDialog(String category) {
    TextEditingController newExController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 20, 30, 80), // Deep Blue Card
          title: Text("Add to $category", style: const TextStyle(color: Colors.white)),
          content: TextField(
            controller: newExController,
            style: const TextStyle(color: Colors.cyan),
            cursorColor: Colors.cyan,
            decoration: const InputDecoration(
              hintText: "e.g. Tricep Extensions",
              hintStyle: TextStyle(color: Colors.white38),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyan)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL", style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                String newEx = newExController.text.trim();
                if (newEx.isNotEmpty) {
                  setState(() {
                    // Add to list
                    _exercises[category]!.add(newEx);
                    // Create new controller
                    _controllers[newEx] = TextEditingController();
                  });
                  
                  // Save new layout to DB
                  _db.saveExerciseList(category, _exercises[category]!);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
              child: const Text("ADD", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }


  // 5. THE DELETE FUNCTION
  void _deleteExercise(String category, String exerciseName) {
    setState(() {
      _exercises[category]!.remove(exerciseName);
      _controllers[exerciseName]?.dispose();
      _controllers.remove(exerciseName);
    });

    _db.saveExerciseList(category, _exercises[category]!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$exerciseName removed"), 
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // --- UI HELPER: Build a Category Section ---
  Widget _buildCategorySection(String title, List<String> exercises) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title),
        
        ...exercises.map((ex) {
          return Dismissible(
            key: Key(ex), 
            direction: DismissDirection.endToStart, 
            background: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.only(right: 20),
              alignment: Alignment.centerRight,
              decoration: BoxDecoration(
                color: Colors.redAccent.shade700,
                borderRadius: BorderRadius.circular(20), 
              ),
              child: const Icon(Icons.delete_sweep, color: Colors.white, size: 30),
            ),
            onDismissed: (direction) {
              // The delete function is officially connected right here!
              _deleteExercise(title, ex);
            },
            child: WorkoutInput(
              label: ex,
              controller: _controllers[ex],
            ),
          );
        }),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => _showAddExerciseDialog(title),
            icon: const Icon(Icons.add_circle_outline, color: Colors.cyan, size: 20),
            label: Text("Add $title Exercise", style: const TextStyle(color: Colors.cyan)),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 9, 18, 64),
      appBar: AppBar(
        title: const Text('G Y M T R A X', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 3.0)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 9, 18, 64),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white70),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _db.logout();
              if (context.mounted) Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),
      
      body: ValueListenableBuilder(
        valueListenable: Hive.box('userBox').listenable(),
        builder: (context, box, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // We use our new helper method to build the sections dynamically!
                if (_exercises["Push"]!.isNotEmpty) _buildCategorySection("Push", _exercises["Push"]!),
                if (_exercises["Pull"]!.isNotEmpty) _buildCategorySection("Pull", _exercises["Pull"]!),
                if (_exercises["Legs"]!.isNotEmpty) _buildCategorySection("Legs", _exercises["Legs"]!),

                const SizedBox(height: 30),
                
                // MASTER SAVE BUTTON
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _updateAll,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text("SAVE WORKOUT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          );
        },
      ),
      
    );
  }
}
