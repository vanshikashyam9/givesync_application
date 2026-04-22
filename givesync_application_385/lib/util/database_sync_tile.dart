import 'package:flutter/material.dart';
import 'package:givesync_application_385/util/firebase_controller.dart';
import 'package:givesync_application_385/util/local_database_controller.dart';
import 'package:givesync_application_385/services/user_service.dart';

class DatabaseSyncTile extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;

  const DatabaseSyncTile({
    super.key,
    this.startDate,
    this.endDate,
  });

  @override
  State<DatabaseSyncTile> createState() => _DatabaseSyncTileState();
}

class _DatabaseSyncTileState extends State<DatabaseSyncTile> {
  bool _isSyncing = false;

  Future<void> _syncDatabase() async {
    if (UserService.cachedPermissionLevel == null ||
        UserService.cachedPermissionLevel == "unassigned") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign in to sync the database!'),
          duration: Duration(seconds: 2),
        ),
      );

      return;
    }

    setState(() {
      _isSyncing = true;
    });

    try {
      // Only sync local entries to Firestore here.
      // Generating/uploading reports is handled by the other buttons.
      await FirebaseDatabaseController.trySyncLocalEntries();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Database synced successfully!'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error syncing database: ${e.toString()}'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  Future<void> _generateReport(BuildContext context) async {
    setState(() {
      _isSyncing = true;
    });

    try {
      // Ensure we have the latest data before generating
      await FirebaseDatabaseController.trySyncLocalEntries();

      final summary = await LocalDatabaseController.generateSummary(
        start: widget.startDate,
        end: widget.endDate,
      );
      final emailText = LocalDatabaseController.buildEmailSummary(summary);

      if (!mounted) return;
      final navigatorContext = context;
      showDialog(
        context: navigatorContext,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Donation Summary Report'),
              content: SingleChildScrollView(
                child: Text(
                  emailText,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
    } catch (e) {
      if (!mounted) return;
      final messengerContext = context;
      ScaffoldMessenger.of(messengerContext).showSnackBar(
        SnackBar(
          content: Text('Error generating report: ${e.toString()}'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  Future<void> _emailCSVReport(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Select Report Period',
    );

    if (picked != null) {
      setState(() {
        _isSyncing = true;
      });

      try {
        await LocalDatabaseController.sendSummaryEmail(
          start: picked.start,
          end: picked.end,
        );
        
        if (!mounted) return;
        final messengerContext = context;
        ScaffoldMessenger.of(messengerContext).showSnackBar(
          const SnackBar(
            content: Text('CSV Report emailed successfully!'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        final dialogContext = context;
        showDialog(
          context: dialogContext,
          builder: (context) => AlertDialog(
            title: const Text('Error Emailing Report'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSyncing = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Sync Database Button
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSyncing ? null : _syncDatabase,
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
                child: _isSyncing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.green,
                          ),
                        ),
                      )
                    : const Text("Sync Database"),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Generate Report Button
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _generateReport(context),
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
                child: const Text("Generate Report"),
              ),
            ),
          ),
          
          const SizedBox(height: 8),

          // Email CSV Report Button
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSyncing ? null : () => _emailCSVReport(context),
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
                child: _isSyncing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                        ),
                      )
                    : const Text("Email CSV Report"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
