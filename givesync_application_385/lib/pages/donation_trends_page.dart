import 'package:flutter/material.dart';
import 'package:givesync_application_385/util/donation_trends_tile.dart';
import 'package:givesync_application_385/services/user_service.dart';

class DonationTrendsPage extends StatefulWidget {
  const DonationTrendsPage({super.key});

  @override
  State<DonationTrendsPage> createState() => _DonationTrendsPageState();
}

class _DonationTrendsPageState extends State<DonationTrendsPage> {

  String? permission;  // user role
  bool loading = true; // loading indicator

  @override
  void initState() {
    super.initState();
    _loadPermission();
  }

  // Load cached user permission or fetch again if needed.
  Future<void> _loadPermission() async {
    // Get the user permission level (admin, staff, volunteer)
    permission = await UserService.getPermissionLevel();

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show a simple loading spinner while checking permissions
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // If user is not allowed (not logged in or invalid role)
  if (permission == null ||
      (permission != "admin" && permission != "staff" && permission != "volunteer")) {

      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green, width: 2),
          ),
          child: const Text(
            "You do not have permission to view the Donation Trends report.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    // If admin or staff, show the actual page
    return const DonationTrendsTile();
  }
}
