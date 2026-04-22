import 'package:flutter/material.dart';

/// A tile widget that provides a button for sending CSV.
/// Currently this button has no implemented functionality.
/// It is part of the original template layout.
import 'package:givesync_application_385/util/local_database_controller.dart';

class SendCSVTile extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;

  const SendCSVTile({
    super.key,
    this.startDate,
    this.endDate,
  });

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
            onPressed: () async {
              try {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Sending report..."), duration: Duration(seconds: 2)),
                );
                
                await LocalDatabaseController.sendSummaryEmail(
                  start: startDate,
                  end: endDate,
                );

                if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Report uploaded successfully! Staff have been notified."),
                    backgroundColor: Colors.green,
                  ),
                );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error sending report: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: const Text("Send .CSV"),
          ),
        ),
      ),
    );
  }
}
