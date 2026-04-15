import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  final box = await Hive.openBox('userBox');
  if (kDebugMode) {
    final directory = await getApplicationDocumentsDirectory();
    debugPrint("DATABASE FOLDER: ${directory.path}");
  }

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
     // 👇 Keeps the logic clean
      initialRoute: isLoggedIn ? '/home' : '/login',

      routes: {
        '/home' : (context) => const DashboardScreen(), // The Building
        '/login': (context) => const LoginScreen(),     // The Front Door
        
        // 🗑️ REMOVE THESE:
        // '/workout': (context) => const WorkoutScreen(), 
        // '/progress': (context) => const ProgressScreen(),
      },
    );
  }
}
