import 'package:flutter/material.dart';
import 'package:my_app/utils/colors.dart';
import 'package:fl_chart/fl_chart.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({Key? key}) : super(key: key);

  // --- MODIFIED: Data is now in a map for better organization ---
  final Map<String, double> categoryScores = const {
    "Itinerary Adherence & Zone Safety": 80,
    "Behavioral Pattern Analysis": 75,
    "Digital Connectivity & Device Health": 90,
    "Group Cohesion": 65,
    "Trip Profile & Engagement": 85,
  };

  // The getter now calculates the average from the map
  double get averageScore =>
      categoryScores.values.reduce((a, b) => a + b) / categoryScores.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // New Gauge Chart
          _buildSectionHeader("Overall Safety Score"),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: ScoreGaugeChart(score: averageScore),
          ),
          const SizedBox(height: 40),

          // Score Breakdown Section
          _buildSectionHeader("Score Breakdown"),
          const SizedBox(height: 10),
          
          // --- MODIFIED: Widgets are now generated from the map ---
          ...categoryScores.entries.map((entry) {
            return _buildCategoryScore(entry.key, entry.value);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.text,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCategoryScore(String category, double score) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                category,
                style: const TextStyle(color: AppColors.text, fontSize: 16),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              "${score.toInt()}/100",
              style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// The ScoreGaugeChart widget remains the same
class ScoreGaugeChart extends StatelessWidget {
  final double score;
  const ScoreGaugeChart({Key? key, required this.score}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            startDegreeOffset: -90,
            sectionsSpace: 0,
            centerSpaceRadius: 100,
            sections: [
              PieChartSectionData(
                value: score,
                color: AppColors.primary,
                radius: 15,
                showTitle: false,
              ),
              PieChartSectionData(
                value: 100 - score,
                color: AppColors.surface,
                radius: 15,
                showTitle: false,
              ),
            ],
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              score.toInt().toString(),
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const Text(
              "out of 100",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        )
      ],
    );
  }
}