import 'package:flutter/material.dart';
import 'package:givesync_application_385/services/user_service.dart';
import 'package:givesync_application_385/util/firebase_controller.dart';
import 'package:givesync_application_385/util/local_database_controller.dart';

class DonationViewCell extends StatelessWidget {
  final Map<String, dynamic> entry;

  const DonationViewCell({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    // Set the values from the database entry
    final date = entry['date'] ?? 'Unknown Date';
    final store = entry['store'] ?? 'Unknown Store';
    final items = (entry['donations'] ?? []).length;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                fit: FlexFit.tight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Write the text displaying critical information
                    Text(
                      "Store: $store",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text("Date: $date"),
                    //const SizedBox(height: 4),
                    //Text("Items: $items"),
                  ],
                ),
              ),

              SizedBox(
                width: 40,
                child: IconButton(
                  color: Colors.black,
                  // TODO: Add onpressed functionality for deleting database item
                  onPressed: () {
                    if (UserService.cachedPermissionLevel == null ||
                        UserService.cachedPermissionLevel == "unassigned") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sign in to delete entries!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } else if (UserService.cachedPermissionLevel != null &&
                        (UserService.cachedPermissionLevel == "staff" ||
                            UserService.cachedPermissionLevel == "admin")) {
                      FirebaseDatabaseController.removeEntryByID(entry["id"]);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cloud entry deleted!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } else {
                      LocalDatabaseController.removeEntryByID(entry["id"]);
                      LocalDatabaseController.writeEntriesToFile();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Local entry deleted! (reload the page)',
                          ),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.delete),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
