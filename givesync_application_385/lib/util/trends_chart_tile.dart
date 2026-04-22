// Version History
// v1.0 (2025-11-25) - Eunjung
//   Integrated real Firebase trend data using DonationTrendService.
//   Added support for date range and store filters through widget parameters.
//   Implemented async data loading with loading and error states.
//   Replaced hardcoded dummy values with dynamic category totals.
//   Added didUpdateWidget to reload chart when filters change.
//   Added support for both Bar and Pie charts using dynamic labels and values.
import 'package:flutter/material.dart';
import 'package:givesync_application_385/charts/bar_chart_tile.dart';
import 'package:givesync_application_385/charts/pie_chart_tile.dart';
// Start Eunjung
import 'package:givesync_application_385/services/donation_trend_service.dart';
// End Eunjung
enum ChartType {
  bar,
  pie,
  // Add more types later: line, area, etc.
}

class DonationTrendsChartTile extends StatefulWidget {
  // Start Eunjung
  final DateTime startDate;
  final DateTime endDate;
  final String store;

  const DonationTrendsChartTile({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.store,
  });
  // End Eunjung
  @override
  State<DonationTrendsChartTile> createState() => _DonationTrendsChartTileState();
}

class _DonationTrendsChartTileState extends State<DonationTrendsChartTile> {
  ChartType _selectedChart = ChartType.bar;
  // Start Eunjung
  bool _isLoading = true;
  Map<String, double> _categoryTotals = {};
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant DonationTrendsChartTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.startDate != widget.startDate ||
        oldWidget.endDate != widget.endDate ||
        oldWidget.store != widget.store) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await DonationTrendService().getCategoryTotals(
        startDate: widget.startDate,
        endDate: widget.endDate,
        store: widget.store,
      );

      setState(() {
        _categoryTotals = result;
        _isLoading = false;
      });
    } catch (e) {

      // Start Eunjung
      print("FIREBASE ERROR BELOW");
      print(e.toString());
      // End Eunjung

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
  // End Eunjung
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Title + Dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Donation Trends",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              DropdownButton<ChartType>(
                value: _selectedChart,
                borderRadius: BorderRadius.circular(12),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedChart = value);
                  }
                },
                items: ChartType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(
                      _prettyName(type),
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Chart
          // Start Eunjung
          SizedBox(
            height: 240,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(child: Text("Error: $_errorMessage"))
                : _categoryTotals.isEmpty
                ? const Center(child: Text("No data available for this range."))
                : _buildChart(),
          ),
          // End Eunjung
        ],
      ),
    );
  }

  // Start Eunjung
  Widget _buildChart() {
    final values = _categoryTotals.values.toList();
    final labels = _categoryTotals.keys.toList();

    switch (_selectedChart) {
      case ChartType.bar:
        return DonationBarChart(values: values, labels: labels);
      case ChartType.pie:
        return DonationPieChart(values: values, labels: labels);
    }
  }
  // End Eunjung
  String _prettyName(ChartType type) {
    switch (type) {
      case ChartType.bar:
        return "Bar Chart";
      case ChartType.pie:
        return "Pie Chart";
    }
  }
}
