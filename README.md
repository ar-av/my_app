# GymTrax 
> A Reactive Cross-Platform Fitness Analytics Application

Traditional fitness apps act as simple digital journals. GymTrax operates as a biomechanical analytics tool, normalizing raw workout data to assess true relative strength and physiological balance.

# Core Features
* **The Normalization Engine:** Compares absolute lifts against intermediate powerlifting baselines (Bench: 100kg, Squat: 140kg, Deadlift: 180kg) to plot a fair, non-linear strength profile.
* **Strength Ratio Assessment:** Uses your current Bench Press PR as a dynamic anchor to actively calculate targeted physical balance for your legs and back.
* **Zero-Latency Reactive UI:** Built with Flutter and Hive NoSQL to recalculate complex analytics instantly without dropping UI frames.

# Dashboard & UI Engineering
* **Reactive Analytics Hub:** Aggregates real-time data from the local Hive cache and pushes targeted UI updates without heavy, main-thread blocking state refreshes.
* **Non-Linear Strength Profile:** Utilizes a customized, curved categorical spline (`fl_chart`) with translucent gradient fills to visually map the user's "Strength Mountain."
* **Raw Data Ledger:** Dynamically maps local data into clean UI rows, concurrently displaying absolute weight and algorithmically normalized scores.
* **Dynamic Balance Indicators:** Conditional UI rendering that tracks the 1.4x (Squat) and 1.8x (Deadlift) ratios, dynamically shifting from a deficit warning to a "Balanced " success state when the 95% symmetry threshold is achieved.

Tech Stack
* **Frontend:** Flutter / Dart
* **Local Storage:** Hive
* **Data Visualization:** fl_chart