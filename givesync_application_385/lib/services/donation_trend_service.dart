import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service dedicated to fetching and summarizing donation trend data.
/// This service handles:
/// 1. Fetching donation documents from Firestore within a date range.
/// 2. Optionally filtering by store.
/// 3. Summarizing totals by category (for charts).
class DonationTrendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  /// Fetch donation documents from Firestore based on a date range.
  ///
  /// startDate: beginning of the range (inclusive)
  /// endDate: end of the range (inclusive)
  /// store: optional store filter. When provided, only documents with
  ///        matching "store" field are returned.
  ///
  /// Returns a List<Map<String, dynamic>> representing Firestore documents.
  Future<List<Map<String, dynamic>>> fetchDonations({
    required DateTime startDate,
    required DateTime endDate,
    String? store,
  }) async {

    // Normalize startDate to start of day
    final normalizedStart = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );

    // Normalize endDate to *next day's start*
    final normalizedEnd = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      23, 59, 59, 999,
    );


    final formatter = DateFormat("yyyy-MM-dd HH:mm:ss.SSS");
    final startString = formatter.format(normalizedStart);
    final endString   = formatter.format(normalizedEnd);

    Query query = _firestore
        .collection("donations")
        .where("date", isGreaterThanOrEqualTo: startString)
        .where("date", isLessThanOrEqualTo: endString);

    if (store != null && store.isNotEmpty  && store != "All") {
      query = query.where("store", isEqualTo: store);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }
  /// Summarize donation documents into total weights per category.
  ///
  /// Each Firestore document is expected to contain a field such as:
  /// "donations": "[{'category':'Canned Goods','weight':'1'}, ...]"
  ///
  /// Returns a Map<String, double> where:
  ///   key   = category name
  ///   value = total weight for that category
  Map<String, double> summarizeByCategory(List<Map<String, dynamic>> docs) {
    final Map<String, double> totals = {};

    for (final doc in docs) {
      // Support both "donations" and "json_text" fields
      final raw = doc["donations"] ?? doc["json_text"];
      if (raw == null) continue;

      List<dynamic> items;
      try {
        items = jsonDecode(raw.toString());
      } catch (_) {
        // Skip invalid JSON
        continue;
      }

      for (final item in items) {
        if (item is! Map) continue;

        final category = (item["category"] ?? "Unknown").toString();
        final weightString = item["weight"]?.toString() ?? "0";
        final weight = double.tryParse(weightString) ?? 0.0;

        totals[category] = (totals[category] ?? 0.0) + weight;
      }
    }

    return totals;
  }

  /// High-level convenience function used by chart widgets.
  /// Fetches donation documents and returns summarized totals by category.
  ///
  /// This is the function your Bar Chart and Pie Chart will call.
  Future<Map<String, double>> getCategoryTotals({
    required DateTime startDate,
    required DateTime endDate,
    String? store,
  }) async {
    final docs = await fetchDonations(
      startDate: startDate,
      endDate: endDate,
      store: store,
    );

    return summarizeByCategory(docs);
  }
  /// Convert Firestore donation documents to CSV string.
  /// Uses the same docs fetched from fetchDonations().
  /// Standardized format: Date,Store,Category,Weight (kg),End Location
  String convertToCsv(List<Map<String, dynamic>> docs) {
    final buffer = StringBuffer();
    final dateFormat = DateFormat('yyyy-MM-dd');

    // CSV header - standardized format
    buffer.writeln("Date,Store,Category,Weight (kg),End Location");

    for (final doc in docs) {
      // Parse date from various possible formats
      String dateStr = "Unknown";
      try {
        if (doc["date"] != null) {
          // Try parsing as DateTime string first
          try {
            final dateValue = doc["date"];
            DateTime parsedDate;
            
            if (dateValue is Timestamp) {
              parsedDate = dateValue.toDate();
            } else if (dateValue is String) {
              parsedDate = DateTime.parse(dateValue);
            } else {
              continue; // Skip if we can't parse date
            }
            
            dateStr = dateFormat.format(parsedDate);
          } catch (e) {
            // If parsing fails, try using createdAt
            if (doc["createdAt"] != null) {
              final createdAt = doc["createdAt"];
              if (createdAt is Timestamp) {
                dateStr = dateFormat.format(createdAt.toDate());
              }
            }
          }
        } else if (doc["createdAt"] != null) {
          final createdAt = doc["createdAt"];
          if (createdAt is Timestamp) {
            dateStr = dateFormat.format(createdAt.toDate());
          }
        }
      } catch (e) {
        // Skip entries with invalid dates
        continue;
      }

      final store = doc["store"]?.toString() ?? "Unknown";
      final raw = doc["donations"] ?? doc["json_text"];

      if (raw == null) continue;

      List<dynamic> items;
      try {
        items = jsonDecode(raw.toString());
      } catch (_) {
        continue;
      }

      for (final item in items) {
        if (item is! Map) continue;
        
        final category = item["category"]?.toString() ?? "Unknown";
        final weight = item["weight"]?.toString() ?? "0";
        final endLocation = item["endLocation"]?.toString() ?? "Unknown";

        // Escape CSV fields
        final escapedStore = _escapeCsvField(store);
        final escapedCategory = _escapeCsvField(category);
        final escapedEndLocation = _escapeCsvField(endLocation);

        buffer.writeln('$dateStr,$escapedStore,$escapedCategory,$weight,$escapedEndLocation');
      }
    }

    return buffer.toString();
  }

  /// Helper method to escape CSV fields that contain commas, quotes, or newlines
  static String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
  /// Fetch donations and directly return the CSV output.
  /// This is used by the Send CSV button.
  Future<String> getCsvForRange({
    required DateTime startDate,
    required DateTime endDate,
    String? store,
  }) async {
    final docs = await fetchDonations(
      startDate: startDate,
      endDate: endDate,
      store: store,
    );

    return convertToCsv(docs);
  }
}
