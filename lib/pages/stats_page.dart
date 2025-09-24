import 'package:flutter/material.dart';
import 'package:my_app/utils/colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:my_app/l10n/app_localizations.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Data is now separate from the keys used for display
    final Map<String, double> categoryScoresData = const {
      "itineraryAdherence": 80,
      "behavioralAnalysis": 75,
      "digitalConnectivity": 90,
      "groupCohesion": 65,
      "tripProfile": 85,
    };
    
    // Helper map to get the correct translated string from a key
    final Map<String, String> keyToDisplayString = {
      "itineraryAdherence": l10n.itineraryAdherence,
      "behavioralAnalysis": l10n.behavioralAnalysis,
      "digitalConnectivity": l10n.digitalConnectivity,
      "groupCohesion": l10n.groupCohesion,
      "tripProfile": l10n.tripProfile,
    };

    final double averageScore =
        categoryScoresData.values.reduce((a, b) => a + b) / categoryScoresData.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildSectionHeader(l10n.overallSafetyScore),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: ScoreGaugeChart(score: averageScore, outOfText: l10n.outOf100),
          ),
          const SizedBox(height: 40),
          _buildSectionHeader(l10n.scoreBreakdown),
          const SizedBox(height: 10),
          ...categoryScoresData.entries.map((entry) {
            // Use the helper map to get the translated category name
            final categoryName = keyToDisplayString[entry.key] ?? entry.key;
            return _buildCategoryScore(categoryName, entry.value);
          }),
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

class ScoreGaugeChart extends StatelessWidget {
  final double score;
  final String outOfText;
  const ScoreGaugeChart({super.key, required this.score, required this.outOfText});

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
            Text(
              outOfText,
              style: const TextStyle(
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