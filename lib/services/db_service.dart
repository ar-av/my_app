import 'package:flutter/foundation.dart'; // Needed for debugPrint
import 'package:hive_flutter/hive_flutter.dart';

class DBService {
  // Singleton Pattern: Ensures only one instance of the database exists
  static final DBService _instance = DBService._internal();
  factory DBService() => _instance;
  
  DBService._internal();

  final _box = Hive.box('userBox');

  // =========================================================
  // 1. AUTHENTICATION (Multi-User + Secure)
  // =========================================================

  bool handleAuth(String enteredEmail, String enteredPassword) {
    // 1. Clean the input (Fixes "John " vs "john")
    final cleanEmail = enteredEmail.trim().toLowerCase();
    
    // 2. Construct the specific password key for THIS user
    // e.g. "arav@gmail.com_password"
    String userPassKey = "${cleanEmail}_password";
    
    String? savedPassword = _box.get(userPassKey);

    // CASE A: New User (We have never seen this email before)
    // -> Register them immediately.
    if (savedPassword == null) {
      _box.put(userPassKey, enteredPassword); // Save their specific password
      _box.put('currentUserEmail', cleanEmail); // Set them as active
      _box.put('isLoggedIn', true);
      debugPrint("🆕 New Account Created for $cleanEmail");
      return true;
    }

    // CASE B: Existing User (We found a password for this email)
    // -> Check if the password matches.
    if (savedPassword == enteredPassword) {
      _box.put('currentUserEmail', cleanEmail); // Set them as active
      _box.put('isLoggedIn', true);
      debugPrint("✅ Welcome back, $cleanEmail");
      return true;
    } 
    else {
      // CASE C: Wrong Password
      debugPrint("❌ Wrong password for $cleanEmail");
      return false;
    }
  }

  void logout() {
    _box.put('isLoggedIn', false);
    // We do NOT clear data or the current email here. 
    // We just mark the session as ended.
    debugPrint("🔒 Logged out.");
  }

  bool get isLoggedIn => _box.get('isLoggedIn', defaultValue: false);

  // ---------------- PRIVATE KEY HELPER ----------------
  // The Magic: Turns "bench_press" -> "arav@gmail.com_bench_press"
  // This ensures User A never sees User B's data.
  String _getUserKey(String baseKey) {
    String email = _box.get('currentUserEmail', defaultValue: 'guest');
    return "${email}_$baseKey";
  }

  // =========================================================
  // 2. WORKOUT DATA (Private to User)
  // =========================================================

  double getPR(String exerciseKey, {double defaultValue = 0.0}) {
    // FIX: Using private key
    return _box.get(_getUserKey(exerciseKey), defaultValue: defaultValue);
  }

  void saveWeight(String exerciseKey, double weightToSave) {
    if (weightToSave > 0) {
      // FIX: Using private key
      _box.put(_getUserKey(exerciseKey), weightToSave);
      debugPrint("✅ SAVED: $weightToSave to ${_getUserKey(exerciseKey)}"); 
    }
  }

  // =========================================================
  // 3. WEEKLY STAR LOGIC (Private to User)
  // =========================================================

  int getWeeklyWorkouts() {
    return _box.get(_getUserKey('weeklyWorkouts'), defaultValue: 0);
  }

  void autoLogWorkout() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check last log date for THIS user
    final lastLogString = _box.get(_getUserKey('lastStarDate'));
    DateTime? lastLogDate;
    if (lastLogString != null) {
      lastLogDate = DateTime.parse(lastLogString);
    }

    // If already logged today, stop.
    if (lastLogDate != null && lastLogDate.isAtSameMomentAs(today)) {
      debugPrint("🚫 Already logged a star today.");
      return;
    }

    // Add Star
    int current = getWeeklyWorkouts();
    if (current < 5) {
      _box.put(_getUserKey('weeklyWorkouts'), current + 1);
      debugPrint("⭐ Auto-Log: Added star! Total: ${current + 1}");
    }
    
    // Save Date for THIS user
    _box.put(_getUserKey('lastStarDate'), today.toIso8601String());
  }

  void resetWeek() {
    _box.put(_getUserKey('weeklyWorkouts'), 0);
    _box.delete(_getUserKey('lastStarDate')); 
    debugPrint("🔄 Week reset.");
  }

  // Debug Tool: Use cautiously!
  void nukeDatabase() {
    _box.clear();
    debugPrint("🔥 DATABASE WIPED");

 
  }

  // --- DEV TOOL: Get all raw data ---
  Map<dynamic, dynamic> getAllData() {
    var box = Hive.box('userBox'); // Make sure this is your exact box name
    return box.toMap();
  }


  // --- DYNAMIC EXERCISE LISTS ---
  
  // 1. Get the list of exercises for a category (Push, Pull, Legs)
  List<String> getExerciseList(String category, {required List<String> defaultList}) {
    var box = Hive.box('userBox');
    List<dynamic> saved = box.get('${category}_list', defaultValue: defaultList);
    return saved.cast<String>();
  }

  // 2. Save a new list of exercises
  void saveExerciseList(String category, List<String> exercises) {
    var box = Hive.box('userBox');
    box.put('${category}_list', exercises);
  }

 // --- DEV TOOL: RAW UNFILTERED DB DUMP ---
  Map<dynamic, dynamic> dumpEntireDatabase() {
    var box = Hive.box('userBox'); // Ensure this is your actual box name
    return box.toMap();
  }


  
}