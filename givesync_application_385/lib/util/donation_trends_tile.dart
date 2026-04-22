// Version History
// v1.0 (2025-11-25) - Eunjung
//   Added date and store filter logic inside DonationTrendsTile.
//   Implemented callbacks to receive selected date range and store.
//   Connected these values to DonationTrendsChartTile for real dynamic chart updates.

import 'package:flutter/material.dart';
import 'package:givesync_application_385/util/date_store_filters_tile.dart';
import 'package:givesync_application_385/util/send_csv_tile.dart';
import 'package:givesync_application_385/util/trends_chart_tile.dart';

class DonationTrendsTile extends StatefulWidget {
  const DonationTrendsTile({super.key});

  @override
  State<DonationTrendsTile> createState() => _DonationTrendsTileState();
}

class _DonationTrendsTileState extends State<DonationTrendsTile> {
  // Start Eunjung
  // Default filter values (initial date = past 30 days)
  DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime endDate = DateTime.now();
  String selectedStore = "All";

  // Callback: receive date changes from DateStoreFiltersTile
  void _onDateChanged(DateTime start, DateTime end) {
    setState(() {
      startDate = start;
      endDate = end;
    });
  }
  // Callback: receive store changes
  void _onStoreChanged(String store) {
    setState(() {
      selectedStore = store;
    });
  }
  // End Eunjung
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // TODO: Add functionality for these
          // Start Eunjung
          DateStoreFiltersTile(
            onDateChanged: _onDateChanged,
            onStoreChanged: _onStoreChanged,
          ),
          // End Eunjung
          Padding(
            padding: EdgeInsets.all(5),
            child:
            // Pass filter info to TrendsChartTile
            DonationTrendsChartTile(
              startDate: startDate,
              endDate: endDate,
              store: selectedStore,
            ),
            // End Eunjung
          ),
          SendCSVTile(
            startDate: startDate,
            endDate: endDate,
          ),
        ],
      ),
    );
  }
}