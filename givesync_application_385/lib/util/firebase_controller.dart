import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:givesync_application_385/services/user_service.dart';
import 'package:givesync_application_385/util/local_database_controller.dart';

class FirebaseDatabaseController {
  static late FirebaseDatabaseController firebaseDatabaseController;

  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  FirebaseDatabaseController() {
    firebaseDatabaseController = this;
  }

  static Future<void> trySyncLocalEntries() async {
    QuerySnapshot<Map<String, dynamic>> query = await firestore
        .collection("donations")
        .get();
    var cloudEntries = query.docs;
    var localEntries = LocalDatabaseController.localDatabaseController.entries;

    for (var entry in localEntries) {
      var matchingEntry = cloudEntries
          .where((e) => e.data()["id"] as String == entry["id"])
          .firstOrNull;

      if (matchingEntry != null) {
        removeEntry(matchingEntry.id);
      }

      addEntry(entry);
    }

    // Pull missing entries from cloud to local
    for (var cloudDoc in cloudEntries) {
      var cloudData = cloudDoc.data();
      bool existsLocally = localEntries.any((e) => e["id"] == cloudData["id"]);
      
      if (!existsLocally) {
        try {
          // Convert cloud data (dynamic) to local format (String)
          // We wrap it in a list because makeEntriesStrings expects a list
          var convertedList = LocalDatabaseController.makeEntriesStrings([cloudData]);
          if (convertedList.isNotEmpty) {
            localEntries.add(convertedList.first);
            log("[firebase_controller.dart] Pulled entry from cloud: ${cloudData['id']}");
          }
        } catch (e) {
          log("[firebase_controller.dart] Error converting cloud entry: $e");
        }
      }
    }
    
    // Save updated local entries to file
    LocalDatabaseController.writeEntriesToFile();
  }

  static Future<List<Map<String, dynamic>>> getCloudEntryList() async {
    QuerySnapshot<Map<String, dynamic>> query = await firestore
        .collection("donations")
        .get();
    var cloudEntries = query.docs;
    List<Map<String, dynamic>> convertedEntryList = List.empty(growable: true);

    for (var rawEntry in cloudEntries) {
      convertedEntryList.add(rawEntry.data());
    }

    return convertedEntryList;
  }

  static List<Map<String, dynamic>> asyncSnapshotToEntryList(
    AsyncSnapshot<QuerySnapshot> snapshot,
  ) {
    var cloudEntries = snapshot.data!.docs;
    List<Map<String, dynamic>> convertedEntryList = List.empty(growable: true);

    for (var rawEntry in cloudEntries) {
      convertedEntryList.add(
        (rawEntry as QueryDocumentSnapshot<Map<String, dynamic>>).data(),
      );
    }

    return convertedEntryList;
  }

  static void addEntry(Map<String, String> entry) {
    firestore
        .collection("donations")
        .add(entry)
        .then((value) => log("[firebase_controller.dart] Added entry."))
        .catchError(
          (error) =>
              log("[firebase_controller.dart] Failed to add entry: $error."),
        );
  }

  static void removeEntry(String name) {
    firestore
        .collection("donations")
        .doc(name)
        .delete()
        .then(
          (value) =>
              log("[firebase_controller.dart] Entry deleted. Name: $name"),
        )
        .catchError(
          (error) =>
              log("[firebase_controller.dart] Failed to delete entry: $error."),
        );
  }

  static void removeEntryByID(String donationID) async {
    QuerySnapshot<Map<String, dynamic>> query = await firestore
        .collection("donations")
        .get();
    var cloudEntries = query.docs;
    var matchingEntry = cloudEntries
        .where((e) => e.data()["id"] as String == donationID)
        .firstOrNull;

    if (matchingEntry != null) {
      removeEntry(matchingEntry.id);
    }
  }
}
