import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:givesync_application_385/pages/donation_detail_page.dart';
import 'package:givesync_application_385/services/user_service.dart';
import 'package:givesync_application_385/util/database_view_cell.dart';
import 'package:givesync_application_385/util/firebase_controller.dart';
import 'package:givesync_application_385/util/local_database_controller.dart';

class DonationDatabaseView extends StatefulWidget {
  const DonationDatabaseView({super.key});

  @override
  State<DonationDatabaseView> createState() => _DonationDatabaseViewState();
}

class _DonationDatabaseViewState extends State<DonationDatabaseView> {
  final Stream<QuerySnapshot> databaseStream = FirebaseFirestore.instance
      .collection("donations")
      .snapshots();

  Widget createLocalDatabaseList() {
    log("[database_view_tile.dart] Creating the local database list.");

    final List<Map<String, dynamic>> entries =
        LocalDatabaseController.makeEntriesDynamic(
          LocalDatabaseController.localDatabaseController.entries,
        );

    // If there are no entries, show a placeholder
    if (entries.isEmpty) {
      return const Center(
        child: Text(
          "No donation entries found.",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    // Use ListView.builder inside another ListView
    return ListView.builder(
      // Important: shrinkWrap and physics prevent infinite height errors
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return AnimatedPressTile(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DonationDetailPage(entry: entry),
              ),
            ).then((_) {
              setState(() {});
            });
          },
          child: DonationViewCell(entry: entry), // <-- your tile
        );
      },
    );
  }

  Widget createCloudDatabaseList(AsyncSnapshot<QuerySnapshot> snapshot) {
    log("[database_view_tile.dart] Creating the cloud database list.");

    final List<Map<String, dynamic>> entries =
        FirebaseDatabaseController.asyncSnapshotToEntryList(snapshot);

    // If there are no entries, show a placeholder
    if (entries.isEmpty) {
      return const Center(
        child: Text(
          "No donation entries found.",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    // Use ListView.builder inside another ListView
    return ListView.builder(
      // Important: shrinkWrap and physics prevent infinite height errors
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return AnimatedPressTile(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DonationDetailPage(entry: entry),
              ),
            ).then((_) {
              setState(() {});
            });
          },
          child: DonationViewCell(entry: entry), // <-- your tile
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: pull entries from Firebase
    // currently a placeholder
    // final List<Map<String, dynamic>> entries = [
    //   {
    //     "date": "2025-11-13",
    //     "store": "Store 1",
    //     "donations": "",
    //     "id": "123456789",
    //   },
    // ];

    if (UserService.cachedPermissionLevel != null &&
        (UserService.cachedPermissionLevel == "staff" ||
            UserService.cachedPermissionLevel == "admin")) {
      return StreamBuilder(
        stream: databaseStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Error loading cloud database.");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading database...");
          }

          return createCloudDatabaseList(snapshot);
        },
      );
    }

    return createLocalDatabaseList();
  }
}

/// ---------------------------------------------------------------------------
/// Press-Animated Tile
/// ---------------------------------------------------------------------------

class AnimatedPressTile extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;

  const AnimatedPressTile({
    required this.child,
    required this.onPressed,
    super.key,
  });

  @override
  State<AnimatedPressTile> createState() => _AnimatedPressTileState();
}

class _AnimatedPressTileState extends State<AnimatedPressTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.zero, // let child control padding
        height: _pressed ? 145 : 130, // same behavior as before
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (_pressed)
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                offset: const Offset(0, 4),
                blurRadius: 8,
              ),
          ],
        ),

        child: widget.child, // <--- Your DonationViewCell goes here
      ),
    );
  }
}
