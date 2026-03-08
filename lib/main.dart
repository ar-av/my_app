import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/workout_screen.dart';
import 'screens/progress_screen.dart';

import 'screens/streak_screen.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  final box = await Hive.openBox('userBox');
  // ADD THIS SINGLE EXACT LINE:
  debugPrint("🚨 MY DB DATA: ${Hive.box('userBox').toMap()}");

  debugPrint("--- GYMTRAX DATABASE CONTENT ---");
  debugPrint(box.toMap().toString());
  debugPrint("--------------------------------");

  final directory = await getApplicationDocumentsDirectory();
  debugPrint("DATABASE FOLDER: ${directory.path}");

  final bool isLoggedIn = box.get('isLoggedIn', defaultValue: false);

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 👇 Explicit initial route logic
      initialRoute: isLoggedIn ? '/workout' : '/login',

      routes: {
        '/login': (context) => const LoginScreen(),
        '/workout': (context) => const WorkoutScreen(),
        '/progress': (context) => const ProgressScreen(),
       
        
        '/streak': (context) => const StreakScreen(),
      },
    );
  }
}
