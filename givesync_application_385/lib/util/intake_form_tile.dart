import 'package:flutter/material.dart';
import 'package:givesync_application_385/util/back_to_database_tile.dart';
import 'package:givesync_application_385/util/choose_date_tile.dart';
import 'package:givesync_application_385/util/choose_store_location_tile.dart';
import 'package:givesync_application_385/util/donation_intake_tile.dart';
import 'package:givesync_application_385/util/submit_button_tile.dart';

/// A composite widget that builds the full donation intake form.
/// Contains tiles for selecting a store, entering donation items,
/// choosing a date, and submitting the form.
///
/// When [initialEntry] is provided, all tiles will prefill their values
/// so the user can edit an existing donation record.
class IntakeFormTile extends StatelessWidget {
  final Map<String, dynamic>? initialEntry;

  const IntakeFormTile({
    super.key,
    this.initialEntry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (initialEntry?["id"] != null) Text(initialEntry?["id"]),

        // Tile for selecting the store location
        ChooseStoreLocationTile(
          initialStore: initialEntry?['store'],
        ),

        // Tile for choosing the donation date
        ChooseDonationDateTile(
          initialDate: initialEntry?['date'],
        ),

        // Tile for adding donation item details
        DonationIntakeTile(
          // TODO: uncomment this one we have figured out the correct donation mapping / saving
          //initialDonation: initialEntry?['donations']
        ),

        // Tile containing the form submission button
        SubmitDonationTile(
          editingExistingEntry: initialEntry?['donations'] != null,
        ),
      ],
    );
  }
}
