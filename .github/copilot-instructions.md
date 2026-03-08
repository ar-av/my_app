# GymTrax: AI Coding Agent Instructions

## Project Overview
**GymTrax** is a Flutter fitness tracking application for monitoring workout progress and exercise streaks. The app uses SQLite for local data persistence and follows a screen-based architecture with reusable widgets.

**Tech Stack:** Flutter 3.8.1+ • Dart • SQLite (sqflite 2.4.2) • Material Design

---

## Architecture & Component Breakdown

### Navigation Model
The app uses **named routes** defined in [lib/main.dart](../
lib/main.dart#L10-L16):
- `LoginScreen` → Entry point (auth)
- `/workout` → WorkoutScreen (PR tracking)
- `/progress` → ProgressScreen (statistics)
- `/beginner` → BeginnerScreen (exercises for beginners)
- `/intermediate` → IntermediateScreen (advanced exercises)
- `/streak` → StreakScreen (streak management)

**Key Pattern:** Each route maps to a `StatefulWidget` screen paired with a corresponding widget in `lib/widgets/` (e.g., `workout_screen.dart` → `workout_widget.dart`).



**Critical:** User passwords are hashed with salt before storage. Never store plaintext passwords.

### Screen & Widget Structure
```
Screens (StatefulWidget)          Widgets (UI Components)
├── login_screen.dart             ├── login_widget.dart (text styling)
├── workout_screen.dart           ├── workout_input.dart (text fields)
├── progress_screen.dart          ├── progress_widget.dart
├── beginner_screen.dart          ├── beginner_widget.dart
├── intermediate_screen.dart      ├── intermediate_widget.dart
├── streak_screen.dart            ├── streak_widget.dart
                                  └── section_header.dart
```

**Screens manage state** (TextEditingControllers, PR values). **Widgets handle UI rendering** without state logic.

### State Management Pattern
[WorkoutScreen](../
lib/screens/workout_screen.dart#L20-L35) demonstrates the pattern:
```dart
// Controllers for 10 exercises
final benchController = TextEditingController();
// PR state (Personal Records)
double benchPR = 30;
```
Uses `setState(() { ... })` for updates. **No Provider/Riverpod/GetX** - plain StatefulWidget.

---

## Key Workflows & Commands

### Build & Run
```bash
flutter pub get              # Install dependencies
flutter run                  # Run on connected device/emulator
flutter run -v               # Verbose output for debugging
```

### Code Quality
```bash
flutter analyze              # Lint check (respects analysis_options.yaml)
flutter format lib           # Format code (follows Flutter conventions)
flutter test                 # Run unit tests (if tests/ exists)
```

### Testing Build Artifacts
```bash
flutter build apk            # Android release APK
flutter build ios            # iOS release build
flutter build web            # Web build
```

---

## Project Conventions & Patterns

### Naming Conventions
- **Files:** snake_case (e.g., `workout_screen.dart`, `db_helper.dart`)
- **Classes:** PascalCase (e.g., `WorkoutScreen`, `DatabaseHelper`)
- **Variables:** camelCase (e.g., `benchController`, `benchPR`)
- **Screen files:** Match route name + "_screen" (e.g., `/workout` → `workout_screen.dart`)

### Widget Composition
- **Screen widgets** (in `screens/`) are always `StatefulWidget` and manage user input
- **Reusable components** (in `widgets/`) are `StatelessWidget` for UI-only rendering
- **TextEditingController disposal:** Always call `.dispose()` in `State.dispose()` to prevent memory leaks
- **Material Design:** All scaffolds use `Scaffold` with `Padding` for margins

### Database Operations
- Access database via `DatabaseHelper.instance.database` (lazy-initialized singleton)
- All DB methods return `Future` - use `await` at call sites
- Auth flow: `createUser()` → `getUser()` → `loginUser()` with salt+hash verification
- Migrations: Increment `version` parameter in `openDatabase()` and handle in `onCreate`

### TextController Management (Critical for Memory)
```dart
@override
void dispose() {
  benchController.dispose();
  inclinedController.dispose();
  // ... dispose ALL controllers
  super.dispose();
}
```
**Every screen with controllers must dispose them.** See [WorkoutScreen.dispose()](../
lib/screens/workout_screen.dart#L37-L47).

---

## Critical Integration Points

### Auth Flow
1. LoginScreen initializes test user: `DatabaseHelper.instance.createUser('test@test.com', 'password123')`
2. User submits email/password
3. DatabaseHelper validates via `loginUser()` which:
   - Fetches user record by email
   - Hashes input password with stored salt
   - Compares hash to stored hash
4. On success: Navigate to `/workout` via `Navigator.pushNamed(context, '/workout')`

### Exercise Data Flow
- WorkoutScreen maintains PR (Personal Record) state for 10 exercises
- User inputs weight gains in TextFields (benchController, etc.)
- `_updateAll()` method adds input values to current PR state
- No persistence to database yet (TODO: add workout logs table)

---

## Common Pitfalls & Anti-Patterns

1. **Memory Leaks:** Forgetting to `.dispose()` TextEditingControllers → controller resources held after widget destroyed
2. **Plaintext Passwords:** Never pass raw passwords to DB; always hash with salt first
3. **Hardcoded Routes:** Route names must match keys in `MaterialApp.routes` map
4. **Missing Imports:** Each widget/screen file must import `package:flutter/material.dart`
5. **Unhandled Futures:** All DB calls are `async` - must use `await` or `.then()`

---

## File Organization Summary

| Path | Purpose |
|------|---------|
| `lib/main.dart` | App entry, MaterialApp config, routes |
| `lib/database/local/db_helper.dart` | SQLite singleton, auth, password security |
| `lib/screens/` | StatefulWidget pages (state + navigation logic) |
| `lib/widgets/` | StatelessWidget components (UI rendering only) |
| `lib/models/` | Data classes (currently empty; use for typed models) |
| `analysis_options.yaml` | Lint rules (includes flutter_lints) |
| `pubspec.yaml` | Dependencies: sqflite, path, crypto |

---

## Quick Reference: When Adding Features

- **New Screen?** Create `lib/screens/feature_screen.dart` (StatefulWidget) + route in main.dart
- **New UI Component?** Create `lib/widgets/feature_widget.dart` (StatelessWidget, no state)
- **User Data?** Add table to `_createDB()`, methods to DatabaseHelper
- **Exercise Tracking?** Add table (workouts/logs) with user_id foreign key, populate via workout_screen.dart
- **New Linting Rule?** Add to `analysis_options.yaml` under `linter.rules`
