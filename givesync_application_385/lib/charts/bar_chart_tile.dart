import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Chart for showing a bar chart of donation trends information.
/// Displays donation values per category using FL Chart's BarChart widget.
class DonationBarChart extends StatelessWidget {
  final List<double> values;
  // Start Eunjung
  final List<String> labels; // Category labels for each bar
  // End Eunjung

  const DonationBarChart({
    super.key,
    required this.values,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    // Start Eunjung
    // Compute the maximum value from the list to dynamically adjust the chart height.
    final double maxValue =
    values.reduce((a, b) => a > b ? a : b);

    // Add a small headroom above the tallest bar for a cleaner look.
    final double niceMaxY = _calculateNiceMax(maxValue);
    final double interval = niceMaxY / 5;

    //final double maxY = maxValue * 1.2;

    // Dynamically calculate interval for Y-axis ticks based on data size.
    //final double interval = _calculateInterval(maxValue);
    // End Eunjung

    return BarChart(
      BarChartData(
        // Start Eunjung
        minY: 0,      // Y-axis starts at zero
        maxY: niceMaxY,   // Slightly above max value

        // Enable tooltip when tapping on bars
        barTouchData: BarTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            tooltipRoundedRadius: 6,

            // Tooltip text when hovering/tapping a bar
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                rod.toY.toString(),
                const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),

        // Configure axis titles and labels
        titlesData: FlTitlesData(
          // Hide numbers above bars
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),

          // Hide right-side Y-axis
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),

          // Left Y-axis numbers (0, 5, 10, 15 ...)
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,        // Ensures enough space for numbers
              interval: interval,       // Dynamic tick spacing

              getTitlesWidget: (value, meta) {
                return Text(
                  value.round().toString(), // Show whole numbers
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                );
              },
            ),
          ),

          // Bottom X-axis category labels
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42, // Space for category names

              getTitlesWidget: (value, meta) {
                final index = value.toInt();

                // Avoid overflow when index is out of range
                if (index < 0 || index >= labels.length) {
                  return const SizedBox.shrink();
                }

                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    labels[index],       // Category name
                    style: const TextStyle(fontSize: 10),
                    overflow: TextOverflow.ellipsis, // Prevent long text overflow
                  ),
                );
              },
            ),
          ),
        ),

        borderData: FlBorderData(show: false), // Remove border
        gridData: FlGridData(show: false),     // Hide grid lines

        // End Eunjung

        // Create one bar per category/value
        barGroups: List.generate(
          values.length,
              (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: values[i],     // Height of each bar
                color: Colors.blue, // Bar color
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Eunjung : For flexible interval generation based on max value
  // This function returns different spacing depending on how large the max Y value is.
  // This prevents the Y-axis numbers from appearing too crowded.
  double _calculateNiceMax(double maxValue) {
    if (maxValue <= 10) return 10;
    if (maxValue <= 20) return 20;
    if (maxValue <= 50) return 50;
    if (maxValue <= 100) return 100;
    return (maxValue / 10).ceil() * 10;
  }
}
