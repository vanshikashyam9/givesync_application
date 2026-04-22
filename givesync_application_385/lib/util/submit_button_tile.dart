import 'package:flutter/material.dart';
import 'package:givesync_application_385/services/user_service.dart';
import 'package:givesync_application_385/util/local_database_controller.dart';

/// A tile widget that provides a button for submitting a donation entry.
///
/// When pressed, the button attempts to add the current donation entry
/// to the local database and provides feedback via a SnackBar.
class SubmitDonationTile extends StatelessWidget {
  final bool? editingExistingEntry;
  const SubmitDonationTile({super.key, this.editingExistingEntry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(12),
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (UserService.cachedPermissionLevel == null ||
                  UserService.cachedPermissionLevel == "unassigned") {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sign in to submit a donation!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
              // If the database entry is successfully added.
              else if (LocalDatabaseController.tryAddEntry()) {
                LocalDatabaseController.writeEntriesToFile();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Donation submitted!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
              // If the database entry fails to add due to missing data.
              else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Not all data has been filled in!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              (editingExistingEntry == false)
                  ? 'Submit Donation'
                  : 'Re-Submit Donation',
            ),
          ),
        ),
      ),
    );
  }
}
