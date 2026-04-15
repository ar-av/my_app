import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/db_service.dart'; // <--- Added DB Service import
import '../widgets/progress_widget.dart'; 
import '../widgets/section_header.dart';


class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Instantiate DB Service so we can fetch our dynamic lists
    final db = DBService(); 

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 9, 18, 64),
      appBar: AppBar(
        title: const Text("A c t i v e  S e s s i o n",
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
            fontWeight: FontWeight.w900, 
            letterSpacing: 3.0,          
          ),
        ),
        centerTitle: true,      
        backgroundColor: const Color.fromARGB(255, 9, 18, 64), 
        elevation: 0,                    
        iconTheme: const IconThemeData(color: Colors.white70),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box('userBox').listenable(),
        builder: (context, box, _) {
          
          // 1. Fetch the dynamic lists from Hive!
          List<String> pushList = db.getExerciseList("Push", defaultList: ["Bench Press", "Inclined Press", "Chest Flies"]);
          List<String> pullList = db.getExerciseList("Pull", defaultList: ["Lat Pulldowns", "Seated Rows", "Deadlift"]);
          List<String> legsList = db.getExerciseList("Legs", defaultList: ["Squats", "Leg Extension", "Leg Curls", "Calf Raises"]);

          // 2. Build the UI dynamically
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              
              // PUSH SECTION
              if (pushList.isNotEmpty) ...[
                const SectionHeader(title: "PUSH"),
                ...pushList.map((ex) => ProgressWidget(exerciseName: ex)),
                const SizedBox(height: 10),
              ],

              // PULL SECTION
              if (pullList.isNotEmpty) ...[
                const SectionHeader(title: "PULL"),
                ...pullList.map((ex) => ProgressWidget(exerciseName: ex)),
                const SizedBox(height: 10),
              ],

              // LEGS SECTION
              if (legsList.isNotEmpty) ...[
                const SectionHeader(title: "LEGS"),
                ...legsList.map((ex) => ProgressWidget(exerciseName: ex)),
              ],
              
              const SizedBox(height: 40),
            ],
          );
        },
      ),
      
    );
  }
}