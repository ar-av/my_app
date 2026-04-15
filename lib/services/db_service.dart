import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';


class DBService {
  // Singleton Pattern: Ensures only one instance of the database exists
  static final DBService _instance = DBService._internal();
  factory DBService() => _instance;
  
  DBService._internal();

  final _box = Hive.box('userBox');

  String _passwordKeyForEmail(String email) => "${email}_password";

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  // =========================================================
  // 1. AUTHENTICATION (Multi-User + Secure)
  // =========================================================

  bool createAccount(String enteredEmail, String enteredPassword) {
    final cleanEmail = enteredEmail.trim().toLowerCase();
    final userPassKey = _passwordKeyForEmail(cleanEmail);
    final savedPassword = _box.get(userPassKey);

    if (savedPassword != null) {
      debugPrint("⚠️ Account already exists for $cleanEmail");
      return false;
    }

    _box.put(userPassKey, _hashPassword(enteredPassword));
    _box.put('currentUserEmail', cleanEmail);
    _box.put('isLoggedIn', true);
    debugPrint("🆕 New Account Created for $cleanEmail");
    return true;
  }

  bool login(String enteredEmail, String enteredPassword) {
    final cleanEmail = enteredEmail.trim().toLowerCase();
    final userPassKey = _passwordKeyForEmail(cleanEmail);
    final savedPassword = _box.get(userPassKey);

    if (savedPassword == null) {
      debugPrint("❌ No account found for $cleanEmail");
      return false;
    }

    final hashedPassword = _hashPassword(enteredPassword);
    final passwordMatches =
        savedPassword == hashedPassword || savedPassword == enteredPassword;

    if (!passwordMatches) {
      debugPrint("❌ Wrong password for $cleanEmail");
      return false;
    }

    if (savedPassword == enteredPassword) {
      _box.put(userPassKey, hashedPassword);
      debugPrint("🔐 Migrated legacy password storage for $cleanEmail");
    }

    _box.put('currentUserEmail', cleanEmail);
    _box.put('isLoggedIn', true);
    debugPrint("✅ Welcome back, $cleanEmail");
    return true;
  }

  bool accountExists(String enteredEmail) {
    final cleanEmail = enteredEmail.trim().toLowerCase();
    return _box.containsKey(_passwordKeyForEmail(cleanEmail));
  }

  void logout() {
    _box.put('isLoggedIn', false);
    _box.delete('currentUserEmail'); // 👈 Kills the "Ghost" session
    debugPrint("🔒 Logged out and session cleared.");
  }

  bool get isLoggedIn => _box.get('isLoggedIn', defaultValue: false);

  // ---------------- PRIVATE KEY HELPER ----------------
  String _getUserKey(String baseKey) {
    String email = _box.get('currentUserEmail', defaultValue: 'guest');
    return "${email}_$baseKey";
  }

  // =========================================================
  // 2. BODY STATS & WORKOUT DATA (Private to User)
  // =========================================================

  void saveBodyStat(String key, double value) {
    _box.put(_getUserKey(key), value);
    debugPrint("💾 Saved $key: $value");
  }

  // --- REST TIMER MEMORY ---
  void saveRestTimer(int seconds) {
    _box.put(_getUserKey('rest_timer'), seconds);
    debugPrint("⏱️ Timer Default Saved: $seconds sec");
  }

  int getRestTimer() {
    // Defaults to 90 seconds if you've never changed it
    return _box.get(_getUserKey('rest_timer'), defaultValue: 90);
  }

  double getBodyStat(String key, double defaultValue) {
    return _box.get(_getUserKey(key), defaultValue: defaultValue);
  }

  double getPR(String exerciseKey, {double defaultValue = 0.0}) {
    return _box.get(_getUserKey(exerciseKey), defaultValue: defaultValue);
  }

  void saveWeight(String exerciseKey, double weightToSave) {
    if (weightToSave < 0) return;

    _box.put(_getUserKey(exerciseKey), weightToSave);
    debugPrint("✅ SAVED: $weightToSave to ${_getUserKey(exerciseKey)}");
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

    final lastLogString = _box.get(_getUserKey('lastStarDate'));
    DateTime? lastLogDate;
    if (lastLogString != null) {
      lastLogDate = DateTime.parse(lastLogString);
    }

    if (lastLogDate != null && lastLogDate.isAtSameMomentAs(today)) {
      debugPrint("🚫 Already logged a star today.");
      return;
    }

    int current = getWeeklyWorkouts();
    if (current < 5) {
      _box.put(_getUserKey('weeklyWorkouts'), current + 1);
      debugPrint("⭐ Auto-Log: Added star! Total: ${current + 1}");
    }
    
    _box.put(_getUserKey('lastStarDate'), today.toIso8601String());
  }

  void resetWeek() {
    _box.put(_getUserKey('weeklyWorkouts'), 0);
    _box.delete(_getUserKey('lastStarDate')); 
    debugPrint("🔄 Week reset.");
  }

  // =========================================================
  // 4. CUSTOM WORKOUT SPLIT LOGIC 
  // =========================================================

  // Get the split list (e.g., ['Push', 'Pull', 'Legs', 'Rest'])
  List<String> getUserSplit() {
    List<dynamic> defaultSplit = ['Push', 'Pull', 'Legs', 'Rest'];
    List<dynamic> saved = _box.get(_getUserKey('user_split'), defaultValue: defaultSplit);
    return saved.cast<String>();
  }

  // Save the new split list
  void saveUserSplit(List<String> newSplit) {
    _box.put(_getUserKey('user_split'), newSplit);
    debugPrint("📋 Split Updated: $newSplit");
  }

  // =========================================================
  // 5. DEV TOOLS & EXERCISE LISTS
  // =========================================================

  void nukeDatabase() {
    _box.clear();
    debugPrint("🔥 DATABASE WIPED");
  }

  Map<dynamic, dynamic> getAllData() {
    var box = Hive.box('userBox'); 
    return box.toMap();
  }

  List<String> getExerciseList(String category, {required List<String> defaultList}) {
    final userKey = _getUserKey('${category}_list');
    final legacyKey = '${category}_list';
    final saved = _box.get(userKey);

    if (saved != null) {
      return (saved as List).cast<String>();
    }

    final legacySaved = _box.get(legacyKey);
    if (legacySaved != null) {
      final migrated = (legacySaved as List).cast<String>();
      _box.put(userKey, migrated);
      return migrated;
    }

    return List<String>.from(defaultList);
  }

  void saveExerciseList(String category, List<String> exercises) {
    _box.put(_getUserKey('${category}_list'), exercises);
  }

  Map<dynamic, dynamic> dumpEntireDatabase() {
    var box = Hive.box('userBox'); 
    return box.toMap();
  }

  // =========================================================
  // 6. ANALYTICS & NORMALIZATION
  // =========================================================

  // Define the "Level 100" baseline for major lifts (in kg)
  final Map<String, double> _benchmarks = {
    'Bench Press': 100.0,
    'Squat': 150.0,
    
    'Deadlift': 200.0,
  };

  double getNormalizedScore(String exerciseName, double liftedWeight) {
    if (liftedWeight <= 0) return 0.0;
    
    // Find the baseline, or default to 100 if it's an unknown exercise
    double baseline = _benchmarks[exerciseName] ?? 100.0; 
    
    // Calculate score and cap it at 120 
    double score = (liftedWeight / baseline) * 100;
    return score > 120.0 ? 120.0 : score;
  }
  
  // Helper to get raw weight for charting
  double getExercisePR(String exerciseName) {
    // Note: Ensure your save methods use these exact string keys!
    return getPR(exerciseName, defaultValue: 0.0);
  }
}
