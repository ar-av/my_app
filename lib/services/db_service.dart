import 'dart:convert';
import 'dart:async';

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

  // 1. AUTHENTICATION (Multi-User + Secure)
  

  Future<bool> createAccount(String enteredEmail, String enteredPassword) async {
    final cleanEmail = enteredEmail.trim().toLowerCase();
    final userPassKey = _passwordKeyForEmail(cleanEmail);
    final savedPassword = _box.get(userPassKey);

    if (savedPassword != null) {
      debugPrint("⚠️ Account already exists for $cleanEmail");
      return false;
    }

    await _box.put(userPassKey, _hashPassword(enteredPassword));
    await _box.put('currentUserEmail', cleanEmail);
    await _box.put('isLoggedIn', true);
    await _box.flush();
    debugPrint("🆕 New Account Created for $cleanEmail");
    return true;
  }

  Future<bool> login(String enteredEmail, String enteredPassword) async {
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
      await _box.put(userPassKey, hashedPassword);
      debugPrint("🔐 Migrated legacy password storage for $cleanEmail");
    }

    await _box.put('currentUserEmail', cleanEmail);
    await _box.put('isLoggedIn', true);
    await _box.flush();
    debugPrint("✅ Welcome back, $cleanEmail");
    return true;
  }

  bool accountExists(String enteredEmail) {
    final cleanEmail = enteredEmail.trim().toLowerCase();
    return _box.containsKey(_passwordKeyForEmail(cleanEmail));
  }

  Future<void> logout() async {
    await _box.put('isLoggedIn', false);
    await _box.delete('currentUserEmail'); //  Kills the "Ghost" session
    await _box.flush();
    debugPrint("🕵️ VAULT CONTENTS AFTER LOGOUT: ${_box.keys.toList()}");
    debugPrint(" Logged out and session cleared.");
  }

  bool get isLoggedIn => _box.get('isLoggedIn', defaultValue: false);

  // ---------------- PRIVATE KEY HELPER ----------------
  String _getUserKey(String baseKey) {
    String email = _box.get('currentUserEmail', defaultValue: 'guest');
    return "${email}_$baseKey";
  }

  
  // 2. BODY STATS & WORKOUT DATA (Private to User)
  

  Future<void> saveBodyStat(String key, double value) async {
    await _box.put(_getUserKey(key), value);
    await _box.flush();
    debugPrint("💾 Saved $key: $value");
  }

  // --- REST TIMER MEMORY ---
  Future<void> saveRestTimer(int seconds) async {
    await _box.put(_getUserKey('rest_timer'), seconds);
    await _box.flush();
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

  Future<void> saveWeight(String exerciseKey, double weightToSave) async {
    if (weightToSave < 0) return;

    await _box.put(_getUserKey(exerciseKey), weightToSave);
    await _box.flush();
    debugPrint("✅ SAVED: $weightToSave to ${_getUserKey(exerciseKey)}");
  }

  // =========================================================
  // 3. WEEKLY STAR LOGIC (Private to User)
  // =========================================================

  int getWeeklyWorkouts() {
    return _box.get(_getUserKey('weeklyWorkouts'), defaultValue: 0);
  }

  Future<void> autoLogWorkout() async {
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
      await _box.put(_getUserKey('weeklyWorkouts'), current + 1);
      debugPrint("⭐ Auto-Log: Added star! Total: ${current + 1}");
    }
    
    await _box.put(_getUserKey('lastStarDate'), today.toIso8601String());
    await _box.flush();
  }

  Future<void> resetWeek() async {
    await _box.put(_getUserKey('weeklyWorkouts'), 0);
    await _box.delete(_getUserKey('lastStarDate')); 
    await _box.flush();
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
  Future<void> saveUserSplit(List<String> newSplit) async {
    await _box.put(_getUserKey('user_split'), newSplit);
    await _box.flush();
    debugPrint("📋 Split Updated: $newSplit");
  }

  // =========================================================
  // 5. DEV TOOLS & EXERCISE LISTS
  // =========================================================

  Future<void> nukeDatabase() async {
    await _box.clear();
    await _box.flush();
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
      unawaited(_box.put(userKey, migrated));
      return migrated;
    }

    return List<String>.from(defaultList);
  }

  Future<void> saveExerciseList(String category, List<String> exercises) async {
    await _box.put(_getUserKey('${category}_list'), exercises);
    await _box.flush();
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
