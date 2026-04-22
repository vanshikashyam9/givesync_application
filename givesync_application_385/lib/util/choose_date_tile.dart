import 'package:flutter/material.dart';
import 'package:givesync_application_385/util/local_database_controller.dart';
import 'package:intl/intl.dart';

/// widget that lets the user choose a donation date.
/// the selected date is saved locally through [LocalDatabaseController].
class ChooseDonationDateTile extends StatefulWidget {
  final String? initialDate;
  const ChooseDonationDateTile({
    super.key,
    this.initialDate
    });

  @override
  State<ChooseDonationDateTile> createState() => _ChooseDonationDateTileState();
}

class _ChooseDonationDateTileState extends State<ChooseDonationDateTile> {
  /// Stores the currently selected donation date.
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();

    // initialize selected date if provided (string format: "2025-11-13")
    if (widget.initialDate != null) {
      try {
        selectedDate = DateTime.parse(widget.initialDate!);

        // also persist to controller so the rest of the form stays in sync
        LocalDatabaseController.setCurrentDate(selectedDate!);
      } catch (_) {
        // ignore parse errors, keep null
      }
    }
  }

  /// Opens a date picker and updates the selected date if the user confirms.
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    // Update the state and persist the new date if a valid one was chosen.
    if (picked != null && picked != selectedDate) {
      LocalDatabaseController.setCurrentDate(picked);

      setState(() {
        selectedDate = picked;
      });
    }
  }

  /// Builds the date selection tile displayed in the donation form.
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
        child: Row(
          children: [
            // Label for the date picker
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Donation Date:",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            // Date display and picker trigger
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Shows selected date or placeholder text
                        Text(
                          selectedDate != null
                              ? DateFormat('MMM dd, yyyy').format(selectedDate!)
                              : 'Select date',
                          style: TextStyle(
                            color: selectedDate != null
                                ? Colors.black
                                : Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                        // Calendar icon indicator
                        Icon(
                          Icons.calendar_today,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
