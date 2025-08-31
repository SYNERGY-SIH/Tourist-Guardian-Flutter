import 'package:flutter/material.dart';
import 'package:my_app/utils/colors.dart';
import 'package:fl_chart/fl_chart.dart'; // You will still need fl_chart

class StatsPage extends StatelessWidget {
  const StatsPage({Key? key}) : super(key: key);

  // Placeholder data
  final double cat1 = 80;
  final double cat2 = 75;
  final double cat3 = 90;
  final double cat4 = 65;
  final double cat5 = 85;

  double get averageScore => (cat1 + cat2 + cat3 + cat4 + cat5) / 5;

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
          _buildCategoryScore("Category 1", cat1),
          _buildCategoryScore("Category 2", cat2),
          _buildCategoryScore("Category 3", cat3),
          _buildCategoryScore("Category 4", cat4),
          _buildCategoryScore("Category 5", cat5),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(category, style: const TextStyle(color: AppColors.text, fontSize: 16)),
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

// A new widget for the "Speed Test" style gauge
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
              // This section represents the score
              PieChartSectionData(
                value: score,
                color: AppColors.primary,
                radius: 15,
                showTitle: false,
              ),
              // This section represents the empty remainder
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