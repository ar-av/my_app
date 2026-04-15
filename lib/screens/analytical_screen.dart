import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/db_service.dart';

class AnalyticalScreen extends StatefulWidget {
  const AnalyticalScreen({super.key});

  @override
  State<AnalyticalScreen> createState() => _AnalyticalScreenState();
}

class _AnalyticalScreenState extends State<AnalyticalScreen> {
  final DBService _db = DBService();

  // ONLY track the Big Three compounds. 
  // Ensure these EXACTLY match the keys in your DBService _benchmarks map.
  final List<String> _trackedLifts = ['Bench Press', 'Squats', 'Deadlift'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D21), // Dark Navy Background
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: Hive.box('userBox').listenable(),
          builder: (context, Box box, _) {
            return ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                const Text(
                  "Compound Analytics",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Normalized scores based on weight-class baselines.",
                  style: TextStyle(fontSize: 14, color: Colors.white54),
                ),
                const SizedBox(height: 30),

                // THE CHART CARD
                Container(
                  height: 350,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C2033),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Strength Profile (0 - 100+)",
                        style: TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 30),
                      Expanded(
                        // 🌊 Non-Linear Chart
                        child: LineChart(
                          _buildChartData(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // RAW DATA BREAKDOWN
                const Text(
                  "Raw Data",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 15),
                ..._trackedLifts.map((exercise) {
                  double rawWeight = _db.getExercisePR(exercise);
                  double score = _db.getNormalizedScore(exercise, rawWeight);
                  return _buildDataRow(exercise, rawWeight, score);
                }),

                const SizedBox(height: 30),

                // STRENGTH BALANCE ASSESSMENT
                const Text(
                  "Strength Balance",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 15),
                _buildBalanceAssessment(),
                
                const SizedBox(height: 30), // Bottom padding
              ],
            );
          },
        ),
      ),
    );
  }

  // --- NON-LINEAR CHART LOGIC ---
  LineChartData _buildChartData() {
    List<FlSpot> spots = [];

    // Create the nodes for the curve
    for (int i = 0; i < _trackedLifts.length; i++) {
      String exercise = _trackedLifts[i];
      double rawWeight = _db.getExercisePR(exercise);
      double score = _db.getNormalizedScore(exercise, rawWeight);
      
      // Plot the X (index) and Y (score)
      spots.add(FlSpot(i.toDouble(), score));
    }

    return LineChartData(
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      minY: 0, // Ensure the chart starts at 0
      maxY: 120, // Cap at 120 so the curve doesn't fly off screen
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), // Hide Y-Axis numbers
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            interval: 1, // Forces labels to appear exactly on the exercises
            getTitlesWidget: (double value, TitleMeta meta) {
              int index = value.toInt();
              
              // Only draw a label if it matches an exercise index
              if (index >= 0 && index < _trackedLifts.length && value == index) {
                String label = _trackedLifts[index].split(' ')[0]; // Gets "Bench" instead of "Bench Press"
                
                // 🛠️ Wrapped in SideTitleWidget to prevent layout crashes
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8,
                  child: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                );
              }
              return SideTitleWidget(axisSide: meta.axisSide, child: const Text(''));
            },
          ),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true, // 🌊 Creates the non-linear curve
          curveSmoothness: 0.35, // Adjust for more/less bending
          color: Colors.cyanAccent,
          barWidth: 4,
          isStrokeCapRound: true,
          // Draw hollow circles on the actual exercise nodes
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 6,
                color: const Color(0xFF1C2033),
                strokeWidth: 3,
                strokeColor: Colors.cyanAccent,
              );
            },
          ),
          // Fill the area under the curve with a glowing gradient
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.cyanAccent.withValues(alpha:0.4),
                Colors.cyanAccent.withValues(alpha:0.0), // Fades out at the bottom
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  // --- UI HELPER: DATA ROW ---
  Widget _buildDataRow(String name, double rawWeight, double score) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2033),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 16)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("${rawWeight}kg", style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 16)),
              Text("Score: ${score.toStringAsFixed(1)}", style: const TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  // --- STRENGTH BALANCE LOGIC ---
  Widget _buildBalanceAssessment() {
    double benchPR = _db.getExercisePR('Bench Press');

    // If they haven't benched yet, we can't calculate ratios!
    if (benchPR <= 0) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFF1C2033), borderRadius: BorderRadius.circular(24)),
        child: const Text("Log a Bench Press PR to unlock your strength balance assessment.", style: TextStyle(color: Colors.white54)),
      );
    }

    // targets based on app's 1.5x and 2x baseline multipliers
    double targetSquat = benchPR * 1.5;
    double targetDeadlift = benchPR * 2.0;
    
    // Matched the exact key from your _trackedLifts array
    double actualSquat = _db.getExercisePR('Squats');
    double actualDeadlift = _db.getExercisePR('Deadlift');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2033),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Target goals based on strength ratio rule:", 
            style: TextStyle(color: Colors.white54, fontSize: 14)
          ),
          const SizedBox(height: 25),
          _buildBalanceBar("Squats", actualSquat, targetSquat),
          const SizedBox(height: 25),
          _buildBalanceBar("Deadlift", actualDeadlift, targetDeadlift),
        ],
      ),
    );
  }

  Widget _buildBalanceBar(String label, double actual, double target) {
    // Calculate how close they are to the target (capped at 100%)
    double progress = target > 0 ? (actual / target).clamp(0.0, 1.0) : 0.0;
    
    // If they are at 95% or above, we consider them perfectly balanced
    bool isBalanced = progress >= 0.95; 

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            Text(
              isBalanced ? "Balanced " : "${actual.toStringAsFixed(1)} / ${target.toStringAsFixed(1)} kg",
              style: TextStyle(
                color: isBalanced ? Colors.greenAccent : Colors.cyanAccent, 
                fontWeight: FontWeight.bold,
                fontSize: 14
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white10,
            color: isBalanced ? Colors.greenAccent : Colors.cyanAccent,
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}