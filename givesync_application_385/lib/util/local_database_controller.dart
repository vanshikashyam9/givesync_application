import 'dart:developer';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:path_provider/path_provider.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:givesync_application_385/util/firebase_controller.dart';
import 'dart:convert';
import 'dart:io';

// NOTE: For Option 3 (third-party email API, e.g., SendGrid).
// Do NOT commit a real API key to git. Keep the real key only in your local copy.
const String _sendGridApiKey = 'YOUR_SENDGRID_API_KEY'; // Replace with your actual API key locally
const String _sendGridApiUrl = 'https://api.sendgrid.com/v3/mail/send';

// A singleton class to handle data export to .json format.
class LocalDatabaseController {
  static late LocalDatabaseController localDatabaseController;

  static const JsonEncoder encoder = JsonEncoder();
  static const JsonDecoder decoder = JsonDecoder();
  static const String filename = "donationData.json";

  // A database with all the entries.
  late List<Map<String, String>> entries;

  // Current values that will be added to the next entry on submit.
  DateTime? currentDate;
  String? currentStore;
  late List<Donation> currentDonations;

  LocalDatabaseController() {
    entries = List.empty(growable: true);
    currentDate = null;
    currentStore = null;
    currentDonations = List.empty(growable: true);

    localDatabaseController = this;
    readEntriesFromFile();
  }

  // Set the current entry's date.
  static void setCurrentDate(DateTime? newDate) {
    localDatabaseController.currentDate = newDate;

    log(
      "[local_database_controller.dart] Set current date to: ${localDatabaseController.currentDate}",
    );
  }

  // Set the current entry's store.
  static void setCurrentStore(String? store) {
    localDatabaseController.currentStore = store;

    log(
      "[local_database_controller.dart] Set current store to: ${localDatabaseController.currentStore}",
    );
  }

  // Add a donation to the list of donation items.
  static void addDonation(String category) {
    log("[local_database_controller.dart] Adding record of type: $category");

    localDatabaseController.currentDonations.add(Donation(category));
  }

  // Edit the details of a given donation item.
  static void editDonation(
    int index,
    String category, {
    double? weight,
    String? endLocation,
  }) {
    // Auto-add a donation if the list isn't big enough.
    if (localDatabaseController.currentDonations.length <= index) {
      addDonation(category);
    }

    log("[local_database_controller.dart] Editing donation at index: $index");

    var targetDonation = localDatabaseController.currentDonations[index];

    if (weight != null) targetDonation.weight = weight;
    if (endLocation != null) targetDonation.endLocation = endLocation;
  }

  // Remove a donation item from the list of donation items.
  static void removeDonation(int index) {
    log("[local_database_controller.dart] Removing donation at index: $index");
    localDatabaseController.currentDonations.removeAt(index);
  }

  // Check if all donations are fully filled out.
  static bool validateDonations() {
    if (localDatabaseController.currentDonations.isEmpty) return false;

    for (var donation in localDatabaseController.currentDonations) {
      if (!donation.isValid()) return false;
    }

    return true;
  }

  // Convert the list of donations to a JSON string that can be more easily
  // stored.
  static String donationsToJson() {
    List<Map<String, String>> convertedDonations = List.empty(growable: true);

    for (var donation in localDatabaseController.currentDonations) {
      var convertedDonation = {
        "category": donation.category,
        "weight": donation.weight?.toString() ?? "0",
        "endLocation": donation.endLocation ?? "Unknown",
      };

      convertedDonations.add(convertedDonation);
    }

    return encoder.convert(convertedDonations);
  }

  // Convert a given donation list to JSON.
  static String donationsToJsonFromList(List<Map<String, String>> donations) {
    return encoder.convert(donations);
  }

  // Convert a given donation string to a list.
  static List<Map<String, String>> jsonToDonations(String donationString) {
    final rawDonationList = decoder.convert(donationString);
    List<Map<String, String>> convertedDonationList = List.empty(
      growable: true,
    );

    for (var rawDonation in rawDonationList) {
      var convertedDonation = <String, String>{
        "category": rawDonation["category"] as String,
        "weight": rawDonation["weight"] as String,
        "endLocation": rawDonation["endLocation"] as String,
      };

      convertedDonationList.add(convertedDonation);
    }

    return convertedDonationList;
  }

  // Convert a given entry list to JSON
  static String entriesToJson(List<Map<String, String>> entries) {
    return encoder.convert(entries);
  }

  // Convert a given entry string to a list
  static List<Map<String, String>> jsonToEntries(String entryString) {
    final rawEntryList = decoder.convert(entryString);
    List<Map<String, String>> convertedEntryList = List.empty(growable: true);

    for (var rawEntry in rawEntryList) {
      var convertedEntry = <String, String>{
        "date": rawEntry["date"] as String,
        "store": rawEntry["store"] as String,
        "donations": rawEntry["donations"] as String,
        "id": rawEntry["id"] as String,
      };

      convertedEntryList.add(convertedEntry);
    }

    return convertedEntryList;
  }

  // Convert entries to a List<Map<String, dynamic>> object
  static List<Map<String, dynamic>> makeEntriesDynamic(
    List<Map<String, String>> entries,
  ) {
    List<Map<String, dynamic>> convertedEntryList = List.empty(growable: true);

    for (var rawEntry in entries) {
      var convertedEntry = <String, dynamic>{
        "date": rawEntry["date"] as String,
        "store": rawEntry["store"] as String,
        "donations": jsonToDonations(rawEntry["donations"] as String),
        "id": rawEntry["id"] as String,
      };

      convertedEntryList.add(convertedEntry);
    }

    return convertedEntryList;
  }

  // Convert entries to a List<Map<String, String>> object
  static List<Map<String, String>> makeEntriesStrings(
    List<Map<String, dynamic>> entries,
  ) {
    List<Map<String, String>> convertedEntryList = List.empty(growable: true);

    for (var rawEntry in entries) {
      var convertedEntry = <String, String>{
        "date": rawEntry["date"] as String,
        "store": rawEntry["store"] as String,
        "donations": donationsToJsonFromList(rawEntry["donations"]),
        "id": rawEntry["id"] as String,
      };

      convertedEntryList.add(convertedEntry);
    }

    return convertedEntryList;
  }

  // Try to add the current entry to the database.
  static bool tryAddEntry() {
    if (localDatabaseController.currentDate == null ||
        localDatabaseController.currentStore == null ||
        !validateDonations()) {
      return false;
    }

    final newEntry = {
      "date": localDatabaseController.currentDate.toString(),
      "store": localDatabaseController.currentStore.toString(),
      "donations": donationsToJson(),
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
    };
    localDatabaseController.entries.add(newEntry);

    log("[local_database_controller.dart] Added new entry: $newEntry");

    return true;
  }

  static void removeEntryByID(String donationID) {
    localDatabaseController.entries.removeWhere((e) => e["id"] == donationID);
  }

  // Returns the local file path for storing data.
  static Future<String> get _localPath async {
    if (kIsWeb) return "";
    final directory = await getApplicationDocumentsDirectory();

    log(
      "[local_database_controller.dart] Local storage path: ${directory.path}",
    );

    return directory.path;
  }

  // Checks whether the local data file exists.
  static Future<bool> get _localFileExists async {
    if (kIsWeb) return false;
    final path = await _localPath;

    final directoryContents = Directory(path).listSync();

    for (var file in directoryContents) {
      if (file is File && file.path.endsWith(filename)) {
        return true;
      }
    }

    return false;
  }

  /// Returns a reference to the local data file.
  static Future<File> get _localFile async {
    final path = await _localPath;

    return File('$path/$filename');
  }

  // Writes the current list of entries to the local file.
  static void writeEntriesToFile() async {
    if (kIsWeb) return;
    final dataToWrite = entriesToJson(localDatabaseController.entries);

    final file = await _localFile;

    if (await _localFileExists) {
      file.delete();
      file.create();
    }

    file.writeAsString(dataToWrite);
  }

  // Reads all entries from the local file and populates the database.
  static void readEntriesFromFile() async {
    if (kIsWeb) return;
    final file = await _localFile;
    if (!await _localFileExists) return;

    var fileContents = await file.readAsString();

    log("[local_database_controller.dart] Read from file: $fileContents");

    localDatabaseController.entries = jsonToEntries(fileContents);
  }

  // Normalize a Firebase entry to match local entry format {date, store, donations, id}
  // Handles different Firebase entry formats (direct fields vs json_text)
  static Map<String, String>? _normalizeFirebaseEntry(Map<String, dynamic> firebaseEntry) {
    try {
      // Try direct format first (date, store, donations, id)
      if (firebaseEntry.containsKey("date") && 
          firebaseEntry.containsKey("donations")) {
        String? date = firebaseEntry["date"]?.toString();
        String? store = firebaseEntry["store"]?.toString() ?? "Unknown";
        String? id = firebaseEntry["id"]?.toString();
        
        // Handle donations - could be String (JSON) or List
        String donationsJson;
        if (firebaseEntry["donations"] is String) {
          donationsJson = firebaseEntry["donations"] as String;
        } else if (firebaseEntry["donations"] is List) {
          donationsJson = encoder.convert(firebaseEntry["donations"]);
        } else {
          log("[local_database_controller.dart] Unknown donations format in Firebase entry");
          return null;
        }
        
        if (date == null || id == null) return null;
        
        return {
          "date": date,
          "store": store,
          "donations": donationsJson,
          "id": id,
        };
      }
      
      // Try json_text format (from DonationService)
      if (firebaseEntry.containsKey("json_text")) {
        String? jsonText = firebaseEntry["json_text"]?.toString();
        String? uniqueId = firebaseEntry["unique_id"]?.toString() ?? 
                          firebaseEntry["id"]?.toString();
        
        if (jsonText == null || uniqueId == null) return null;
        
        // Try to parse json_text to extract date, store, donations
        try {
          Map<String, dynamic> parsed = decoder.convert(jsonText);
          String? date = parsed["date"]?.toString();
          String? store = parsed["store"]?.toString() ?? "Unknown";
          String? donations = parsed["donations"]?.toString();
          
          if (date != null && donations != null) {
            return {
              "date": date,
              "store": store,
              "donations": donations,
              "id": uniqueId,
            };
          }
        } catch (e) {
          log("[local_database_controller.dart] Error parsing json_text: $e");
        }
      }
      
      return null;
    } catch (e) {
      log("[local_database_controller.dart] Error normalizing Firebase entry: $e");
      return null;
    }
  }

  // Fetch all donations from both local storage and Firebase, normalized and merged
  // Returns a unified list of entries in the format {date, store, donations, id}
  static Future<List<Map<String, String>>> _getAllDonations({
    DateTime? start,
    DateTime? end,
  }) async {
    List<Map<String, String>> allEntries = [];
    Set<String> seenIds = {}; // Track IDs to avoid duplicates

    // Add local entries with date filtering
    for (var entry in localDatabaseController.entries) {
      String? id = entry["id"];
      if (id == null || seenIds.contains(id)) continue;
      
      // Apply date filtering if provided
      if (start != null || end != null) {
        try {
          DateTime entryDate = DateTime.parse(entry["date"]!);
          if (start != null && entryDate.isBefore(start)) {
            continue;
          }
          if (end != null && 
              entryDate.isAfter(end.add(const Duration(days: 1)))) {
            continue;
          }
        } catch (e) {
          log("[local_database_controller.dart] Error parsing local entry date: $e");
          continue;
        }
      }
      
      allEntries.add(Map<String, String>.from(entry));
      seenIds.add(id);
    }

    // Fetch from Firebase and normalize
    try {
      final cloudEntries = await FirebaseDatabaseController.getCloudEntryList();
      
      for (var cloudEntry in cloudEntries) {
        Map<String, String>? normalized = _normalizeFirebaseEntry(cloudEntry);
        
        if (normalized != null) {
          String? id = normalized["id"];
          
          // Skip if we already have this entry from local storage
          if (id != null && !seenIds.contains(id)) {
            // Apply date filtering if provided
            if (start != null || end != null) {
              try {
                DateTime entryDate = DateTime.parse(normalized["date"]!);
                if (start != null && entryDate.isBefore(start)) {
                  continue;
                }
                if (end != null && 
                    entryDate.isAfter(end.add(const Duration(days: 1)))) {
                  continue;
                }
              } catch (e) {
                log("[local_database_controller.dart] Error parsing Firebase entry date: $e");
                continue;
              }
            }
            
            allEntries.add(normalized);
            seenIds.add(id);
          }
        }
      }
    } catch (e) {
      log("[local_database_controller.dart] Error fetching Firebase entries: $e");
      // Continue with local entries only if Firebase fails
    }

    return allEntries;
  }

  // Generate a FoodMesh-style summary report from all entries.
  static Future<Map<String, dynamic>> generateSummary({DateTime? start, DateTime? end}) async {
    double totalWeight = 0;
    Map<String, double> categoryTotals = {};
    Map<String, double> endLocationTotals = {};
    Map<String, double> storeTotals = {};
    Map<String, int> storeEntryCounts = {};
    List<DateTime> entryDates = [];
    int totalDonationItems = 0;

    // Fetch all entries from both local and Firebase
    final allEntries = await _getAllDonations(start: start, end: end);

    for (var entry in allEntries) {
      // Parse date
      DateTime entryDate;
      try {
        entryDate = DateTime.parse(entry["date"]!);
      } catch (e) {
        log("[local_database_controller.dart] Error parsing date: $e");
        continue;
      }

      entryDates.add(entryDate);

      String store = entry["store"] ?? "Unknown";
      storeEntryCounts[store] = (storeEntryCounts[store] ?? 0) + 1;

      List<dynamic> donations = decoder.convert(entry["donations"]!);
      double entryWeight = 0;

      for (var donation in donations) {
        double weight = double.tryParse(donation["weight"] ?? "0") ?? 0;
        String endLocation = donation["endLocation"] ?? "Unknown";
        String category = donation["category"] ?? "Unknown";

        totalWeight += weight;
        entryWeight += weight;
        totalDonationItems++;

        // Category weight totals
        categoryTotals[category] = (categoryTotals[category] ?? 0) + weight;

        // End-location totals
        endLocationTotals[endLocation] =
            (endLocationTotals[endLocation] ?? 0) + weight;
      }

      // Store totals
      storeTotals[store] = (storeTotals[store] ?? 0) + entryWeight;
    }

    // Calculate date range
    DateTime? earliestDate;
    DateTime? latestDate;
    if (entryDates.isNotEmpty) {
      entryDates.sort();
      earliestDate = entryDates.first;
      latestDate = entryDates.last;
    }

    return {
      "totalWeight": totalWeight,
      "totalEntries": allEntries.length,
      "totalDonationItems": totalDonationItems,
      "categoryTotals": categoryTotals,
      "endLocationTotals": endLocationTotals,
      "storeTotals": storeTotals,
      "storeEntryCounts": storeEntryCounts,
      "earliestDate": earliestDate?.toIso8601String(),
      "latestDate": latestDate?.toIso8601String(),
    };
  }

  // Generate a CSV string from entries within a date range.
  static Future<String> generateCSV(DateTime? start, DateTime? end) async {
    StringBuffer buffer = StringBuffer();
    
    // CSV Header
    buffer.writeln("Date,Store,Category,Weight (kg),End Location");

    // Fetch all entries from both local and Firebase
    final allEntries = await _getAllDonations(start: start, end: end);

    for (var entry in allEntries) {
      try {
        DateTime entryDate = DateTime.parse(entry["date"]!);

        String dateStr = DateFormat('yyyy-MM-dd').format(entryDate);
        String store = entry["store"] ?? "Unknown";
        
        List<dynamic> donations = decoder.convert(entry["donations"]!);
        
        for (var donation in donations) {
          String category = donation["category"] ?? "Unknown";
          String weight = donation["weight"] ?? "0";
          String endLocation = donation["endLocation"] ?? "Unknown";
          
          // Escape fields for CSV
          String escapedStore = _escapeCsvField(store);
          String escapedCategory = _escapeCsvField(category);
          String escapedEndLocation = _escapeCsvField(endLocation);

          buffer.writeln("$dateStr,$escapedStore,$escapedCategory,$weight,$escapedEndLocation");
        }
      } catch (e) {
        log("[local_database_controller.dart] Error processing entry for CSV: $e");
      }
    }

    return buffer.toString();
  }

  static String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  static String buildEmailSummary(Map<String, dynamic> summary) {
    StringBuffer buffer = StringBuffer();
    final dateFormat = DateFormat('MMMM d, yyyy');

    buffer.writeln("=".padRight(60, '='));
    buffer.writeln("DAILY DONATION SUMMARY REPORT");
    buffer.writeln("GiveSync - FoodLink Donation Management System");
    buffer.writeln("=".padRight(60, '='));
    buffer.writeln();

    // Date Range Information
    if (summary['earliestDate'] != null && summary['latestDate'] != null) {
      try {
        DateTime earliest = DateTime.parse(summary['earliestDate']);
        DateTime latest = DateTime.parse(summary['latestDate']);

        if (earliest.year == latest.year &&
            earliest.month == latest.month &&
            earliest.day == latest.day) {
          buffer.writeln("Report Date: ${dateFormat.format(earliest)}");
        } else {
          buffer.writeln(
            "Report Period: ${dateFormat.format(earliest)} - ${dateFormat.format(latest)}",
          );
        }
      } catch (e) {
        log("[local_database_controller.dart] Error formatting dates: $e");
      }
    }
    buffer.writeln();

    // Overall Statistics
    buffer.writeln("OVERALL STATISTICS");
    buffer.writeln("-".padRight(60, '-'));
    buffer.writeln("Total Donation Entries: ${summary['totalEntries']}");
    buffer.writeln(
      "Total Donation Items: ${summary['totalDonationItems'] ?? 0}",
    );
    buffer.writeln(
      "Total Weight: ${(summary['totalWeight'] as double).toStringAsFixed(2)} kg",
    );
    buffer.writeln(
      "Average Weight per Entry: ${summary['totalEntries'] > 0 ? ((summary['totalWeight'] as double) / (summary['totalEntries'] as int)).toStringAsFixed(2) : '0.00'} kg",
    );
    buffer.writeln();

    // Breakdown by Store
    if (summary['storeTotals'] != null &&
        (summary['storeTotals'] as Map).isNotEmpty) {
      buffer.writeln("BREAKDOWN BY STORE");
      buffer.writeln("-".padRight(60, '-'));
      final storeTotals = summary['storeTotals'] as Map<String, double>;
      final storeCounts = summary['storeEntryCounts'] as Map<String, int>;

      // Sort stores by total weight (descending)
      final sortedStores = storeTotals.keys.toList()
        ..sort((a, b) => storeTotals[b]!.compareTo(storeTotals[a]!));

      for (var store in sortedStores) {
        double weight = storeTotals[store]!;
        int entryCount = storeCounts[store] ?? 0;
        buffer.writeln("$store:");
        buffer.writeln("  - Total Weight: ${weight.toStringAsFixed(2)} kg");
        buffer.writeln("  - Number of Entries: $entryCount");
        buffer.writeln(
          "  - Average per Entry: ${(weight / entryCount).toStringAsFixed(2)} kg",
        );
        buffer.writeln();
      }
    }

    // Breakdown by Category
    if (summary['categoryTotals'] != null &&
        (summary['categoryTotals'] as Map).isNotEmpty) {
      buffer.writeln("BREAKDOWN BY CATEGORY");
      buffer.writeln("-".padRight(60, '-'));
      final categoryTotals = summary['categoryTotals'] as Map<String, double>;

      // Sort categories by weight (descending)
      final sortedCategories = categoryTotals.keys.toList()
        ..sort((a, b) => categoryTotals[b]!.compareTo(categoryTotals[a]!));

      for (var category in sortedCategories) {
        double weight = categoryTotals[category]!;
        double percentage = summary['totalWeight'] > 0
            ? (weight / (summary['totalWeight'] as double)) * 100
            : 0;
        buffer.writeln("$category:");
        buffer.writeln(
          "  - Weight: ${weight.toStringAsFixed(2)} kg (${percentage.toStringAsFixed(1)}%)",
        );
        buffer.writeln();
      }
    }

    // Breakdown by End Location
    if (summary['endLocationTotals'] != null &&
        (summary['endLocationTotals'] as Map).isNotEmpty) {
      buffer.writeln("BREAKDOWN BY END LOCATION");
      buffer.writeln("-".padRight(60, '-'));
      final endLocationTotals =
          summary['endLocationTotals'] as Map<String, double>;

      // Sort locations by weight (descending)
      final sortedLocations = endLocationTotals.keys.toList()
        ..sort(
          (a, b) => endLocationTotals[b]!.compareTo(endLocationTotals[a]!),
        );

      for (var location in sortedLocations) {
        double weight = endLocationTotals[location]!;
        double percentage = summary['totalWeight'] > 0
            ? (weight / (summary['totalWeight'] as double)) * 100
            : 0;
        buffer.writeln("$location:");
        buffer.writeln(
          "  - Weight: ${weight.toStringAsFixed(2)} kg (${percentage.toStringAsFixed(1)}%)",
        );
        buffer.writeln();
      }
    }

    buffer.writeln("=".padRight(60, '='));
    buffer.writeln("Generated by GiveSync Donation Management System");
    buffer.writeln(
      "For questions or support, please contact your system administrator.",
    );
    buffer.writeln("=".padRight(60, '='));

    return buffer.toString();
  }

  static String buildEmailSummaryHTML(Map<String, dynamic> summary) {
    StringBuffer buffer = StringBuffer();
    final dateFormat = DateFormat('MMMM d, yyyy');

    buffer.writeln("<html><body>");
    buffer.writeln(
      "<h2 style='color: #2E7D32;'>Daily Donation Summary Report</h2>",
    );
    buffer.writeln("<p><strong>GiveSync - FoodLink Donation Management System</strong></p>");
    buffer.writeln("<hr>");

    // Date Range
    if (summary['earliestDate'] != null && summary['latestDate'] != null) {
      try {
        DateTime earliest = DateTime.parse(summary['earliestDate']);
        DateTime latest = DateTime.parse(summary['latestDate']);
        String dateStr;
        if (earliest.year == latest.year &&
            earliest.month == latest.month &&
            earliest.day == latest.day) {
          dateStr = dateFormat.format(earliest);
        } else {
          dateStr = "${dateFormat.format(earliest)} - ${dateFormat.format(latest)}";
        }
        buffer.writeln("<p><strong>Report Period:</strong> $dateStr</p>");
      } catch (e) {
        log("[local_database_controller.dart] Error formatting dates: $e");
      }
    }

    // Overall Statistics
    buffer.writeln("<h3 style='color: #1565C0;'>Overall Statistics</h3>");
    buffer.writeln("<ul>");
    buffer.writeln("<li>Total Donation Entries: ${summary['totalEntries']}</li>");
    buffer.writeln(
      "<li>Total Donation Items: ${summary['totalDonationItems'] ?? 0}</li>",
    );
    buffer.writeln(
      "<li>Total Weight: <strong>${(summary['totalWeight'] as double).toStringAsFixed(2)} kg</strong></li>",
    );
    buffer.writeln(
      "<li>Average Weight per Entry: ${summary['totalEntries'] > 0 ? ((summary['totalWeight'] as double) / (summary['totalEntries'] as int)).toStringAsFixed(2) : '0.00'} kg</li>",
    );
    buffer.writeln("</ul>");

    // Helper to generate tables
    void generateTable(String title, Map<String, double> totals, {Map<String, int>? counts}) {
      if (totals.isNotEmpty) {
        buffer.writeln("<h3 style='color: #1565C0;'>$title</h3>");
        buffer.writeln(
          "<table border='1' cellpadding='5' cellspacing='0' style='border-collapse: collapse; width: 100%;'>",
        );
        buffer.writeln(
          "<tr style='background-color: #f2f2f2;'><th>Name</th><th>Weight (kg)</th>${counts != null ? '<th>Entries</th>' : ''}<th>Percentage</th></tr>",
        );

        final sortedKeys = totals.keys.toList()
          ..sort((a, b) => totals[b]!.compareTo(totals[a]!));

        for (var key in sortedKeys) {
          double weight = totals[key]!;
          double percentage = summary['totalWeight'] > 0
              ? (weight / (summary['totalWeight'] as double)) * 100
              : 0;
          
          buffer.writeln("<tr>");
          buffer.writeln("<td>$key</td>");
          buffer.writeln("<td>${weight.toStringAsFixed(2)}</td>");
          if (counts != null) {
            buffer.writeln("<td>${counts[key] ?? 0}</td>");
          }
          buffer.writeln("<td>${percentage.toStringAsFixed(1)}%</td>");
          buffer.writeln("</tr>");
        }
        buffer.writeln("</table>");
      }
    }

    // Breakdown Tables
    if (summary['storeTotals'] != null) {
      generateTable(
        "Breakdown by Store",
        summary['storeTotals'] as Map<String, double>,
        counts: summary['storeEntryCounts'] as Map<String, int>,
      );
    }
    
    if (summary['categoryTotals'] != null) {
      generateTable(
        "Breakdown by Category",
        summary['categoryTotals'] as Map<String, double>,
      );
    }

    if (summary['endLocationTotals'] != null) {
      generateTable(
        "Breakdown by End Location",
        summary['endLocationTotals'] as Map<String, double>,
      );
    }

    buffer.writeln("<hr>");
    buffer.writeln(
      "<p style='font-size: 0.9em; color: #777;'>Generated by GiveSync Donation Management System</p>",
    );
    buffer.writeln("</body></html>");

    return buffer.toString();
  }

  // Get list of staff email addresses from Firestore
  // Users with role "staff" or higher (e.g., "admin", "manager") will receive emails
  static Future<List<String>> _getStaffEmails() async {
    try {
      final usersRef = FirebaseFirestore.instance.collection('user_permission_levels');

      // Query for users with role "staff", "admin", or "manager"
      final staffQuery = usersRef.where(
        'permission_level',
        whereIn: ['staff', 'admin', 'manager', 'volunteer'],
      );

      final snapshot = await staffQuery.get();
      List<String> staffEmails = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final email = data['email'] as String?;
        if (email != null && email.isNotEmpty) {
          staffEmails.add(email);
        }
      }

      log(
        "[local_database_controller.dart] Found ${staffEmails.length} staff emails from Firestore",
      );

      // FALLBACK FOR DEBUGGING: If no emails found, use a default one to test sending
      if (staffEmails.isEmpty) {
        const fallbackEmail = "vanshika.shyam@example.com"; // REPLACE WITH YOUR ACTUAL TESTING EMAIL
        log("[local_database_controller.dart] Using fallback email for debugging: $fallbackEmail");
        staffEmails.add(fallbackEmail);
      }
      
      return staffEmails;
    } catch (e) {
      log("[local_database_controller.dart] Error fetching staff emails: $e");
      // Return fallback even on error for debugging purposes
      return ["vanshika.shyam@example.com"]; 
    }
  }

  // Helper method to format date range for email subject
  static String _formatDateRangeForSubject(DateTime? start, DateTime? end) {
    final dateFormat = DateFormat('MMM d, yyyy');
    
    if (start == null && end == null) {
      return "All Time";
    } else if (start != null && end != null) {
      final startStr = dateFormat.format(start);
      final endStr = dateFormat.format(end);
      
      // Check if same day
      if (start.year == end.year &&
          start.month == end.month &&
          start.day == end.day) {
        return startStr;
      } else {
        return "$startStr - $endStr";
      }
    } else if (start != null) {
      return "From ${dateFormat.format(start)}";
    } else {
      return "Until ${dateFormat.format(end!)}";
    }
  }

  // Helper method to generate CSV filename with date range
  static String _generateCsvFilename(DateTime? start, DateTime? end) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    
    if (start == null && end == null) {
      return "donation_report_all.csv";
    } else if (start != null && end != null) {
      final startStr = dateFormat.format(start);
      final endStr = dateFormat.format(end);
      
      // Check if same day
      if (start.year == end.year &&
          start.month == end.month &&
          start.day == end.day) {
        return "donation_report_$startStr.csv";
      } else {
        return "donation_report_${startStr}_to_$endStr.csv";
      }
    } else if (start != null) {
      return "donation_report_from_${dateFormat.format(start)}.csv";
    } else {
      return "donation_report_until_${dateFormat.format(end!)}.csv";
    }
  }

  static Future<void> sendSummaryEmail({DateTime? start, DateTime? end}) async {
    try {
      // Ensure user is authenticated (so only staff/admin can send reports)
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not authenticated. Please log in to generate and email reports.");
      }

      // Validate that SendGrid is configured locally
      if (_sendGridApiKey == 'YOUR_SENDGRID_API_KEY_HERE') {
        throw Exception(
          "SendGrid API key is not configured.\n\n"
          "To enable emailing CSV reports:\n"
          "1. Create a SendGrid account and API Key (Mail Send, Full Access).\n"
          "2. Set _sendGridApiKey in local_database_controller.dart on YOUR machine only.\n"
          "3. Do NOT commit your real API key to git.",
        );
      }

      final summary = await generateSummary(start: start, end: end);
      
      final emailText = buildEmailSummary(summary);
      final emailHtml = buildEmailSummaryHTML(summary);
      final csvContent = await generateCSV(start, end);

      // Get staff emails from Firestore
      final staffEmails = await _getStaffEmails();

      if (staffEmails.isEmpty) {
        log(
          "[local_database_controller.dart] Warning: No staff emails found. Email not sent.",
        );
        throw Exception("No staff emails found. Please ensure users have 'staff', 'admin', or 'manager' roles.");
      }

      // Format date range for email subject and CSV filename
      final dateRangeStr = _formatDateRangeForSubject(start, end);
      final csvFilename = _generateCsvFilename(start, end);

      // Prepare SendGrid payload
      final attachmentBase64 = base64Encode(utf8.encode(csvContent));

      final personalizations = [
        {
          'to': staffEmails.map((email) => {'email': email}).toList(),
        },
      ];

      final requestBody = {
        'personalizations': personalizations,
        'from': {
          'email': 'vanshika.shyam@mytwu.ca', // You can change this in SendGrid sender settings
          'name': 'GiveSync',
        },
        'subject': '$dateRangeStr Donation Summary',
        'content': [
          {
            'type': 'text/plain',
            'value': emailText,
          },
          {
            'type': 'text/html',
            'value': emailHtml,
          },
        ],
        'attachments': [
          {
            'content': attachmentBase64,
            'type': 'text/csv',
            'filename': csvFilename,
            'disposition': 'attachment',
          },
        ],
      };

      log("[local_database_controller.dart] Sending email via SendGrid to ${staffEmails.length} recipients...");

      final response = await http.post(
        Uri.parse(_sendGridApiUrl),
        headers: {
          'Authorization': 'Bearer $_sendGridApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception("Request timeout: SendGrid took too long to respond.");
        },
      );

      log("[local_database_controller.dart] SendGrid response status: ${response.statusCode}");
      log("[local_database_controller.dart] SendGrid response body: ${response.body}");

      // SendGrid returns 202 Accepted on success
      if (response.statusCode != 202) {
        String errorMessage = response.body;
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['errors']?.toString() ?? response.body;
        } catch (_) {}

        throw Exception("SendGrid returned error (${response.statusCode}): $errorMessage");
      }

      log("[local_database_controller.dart] Summary email sent successfully to ${staffEmails.length} recipients via SendGrid.");
    } catch (e) {
      log("[local_database_controller.dart] Error sending summary email: $e");
      rethrow;
    }
  }
}

// A class to represent one category of item being supplied in a delivery.
class Donation {
  String category;
  double? weight;
  String? endLocation;

  Donation(this.category) {
    weight = null;
    endLocation = null;
  }

  bool isValid() {
    log(
      "[local_database_controller.dart] Donation weight: $weight, end location: $endLocation",
    );
    return weight != null && endLocation != null;
  }
}
