import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Chart for showing a pie chart of donation trends information
class DonationPieChart extends StatelessWidget {
  final List<double> values;
  // Start Eunjung
  final List<String> labels;

  const DonationPieChart({super.key, required this.values, required this.labels});
  // End Eunjung
  @override
  Widget build(BuildContext context) {
    final total = values.fold<double>(0, (a, b) => a + b);

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        // Start Eunjung
        sections: values.asMap().entries.map((e) {
          final index = e.key;
          final value = e.value;
          final percent = total == 0 ? 0 : ((value / total) * 100).round();

          return PieChartSectionData(
            value: value,
            // Show label and percentage together
            title: '${labels[index]}  $percent%',
            color: Colors.primaries[index % Colors.primaries.length],
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          );
        }).toList(),
        // End Eunjung
      ),
    );
  }
}
