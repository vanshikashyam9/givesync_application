import 'package:flutter/material.dart';
import 'package:givesync_application_385/util/date_store_filters_tile.dart';
import 'package:givesync_application_385/util/database_sync_tile.dart';
import 'package:givesync_application_385/util/database_view_tile.dart';
import 'package:givesync_application_385/util/intake_form_tile.dart';


/// Page for displaying the database
class DatabasePage extends StatefulWidget {
  const DatabasePage({super.key});

  @override
  State<DatabasePage> createState() => _DatabasePageState();
}

class _DatabasePageState extends State<DatabasePage> {
  // Start Eunjung
  DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime endDate = DateTime.now();
  // End Eunjung

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // Srart Eunjung
        DateStoreFiltersTile(
          onDateChanged: (start, end) {
            setState(() {
              startDate = start;
              endDate = end;
            });
          },
          onStoreChanged: (store) {},
        ),
        // End Eunjung
        DatabaseSyncTile(
          startDate: startDate,
          endDate: endDate,
        ),
        DonationDatabaseView(),
      ],
    );
  }
}