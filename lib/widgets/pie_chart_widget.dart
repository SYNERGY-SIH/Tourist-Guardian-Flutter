import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:my_app/utils/colors.dart';

class PieChartWidget extends StatefulWidget {
  final double score;
  final List<double> categories;

  const PieChartWidget({Key? key, required this.score, required this.categories})
      : super(key: key);

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    // Calculate the total sum of categories to determine percentages
    final double totalValue = widget.categories.fold(0, (prev, element) => prev + element);

    return AspectRatio(
      aspectRatio: 1.3,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2, // Adds a small space between sections
              centerSpaceRadius: 80,
              sections: showingSections(totalValue),
            ),
          ),
          // Improved center text with context
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.score.toInt().toString(),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const Text(
                "Overall Score",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections(double totalValue) {
    // A robust list of colors for the chart sections
    final List<Color> pieColors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.success,
      const Color(0xFFFACC15), // Yellow
      const Color(0xFFFB923C), // Orange
    ];

    return List.generate(widget.categories.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 20.0 : 14.0;
      final radius = isTouched ? 70.0 : 60.0;
      final double percentage = (widget.categories[i] / totalValue) * 100;

      return PieChartSectionData(
        // Use modulo operator (%) for safe color selection to prevent crashes
        color: pieColors[i % pieColors.length],
        value: widget.categories[i],
        title: '${percentage.toStringAsFixed(0)}%', // Show percentage
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      );
    });
  }
}