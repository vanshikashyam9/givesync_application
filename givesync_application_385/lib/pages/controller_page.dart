import 'package:flutter/material.dart';
import 'package:givesync_application_385/pages/database_page.dart';
import 'package:givesync_application_385/pages/donation_page.dart';
import 'package:givesync_application_385/pages/donation_trends_page.dart';
import 'package:givesync_application_385/pages/settings_page.dart';
// Start Eunjung You
import 'package:givesync_application_385/pages/user_login_page.dart';
import 'package:givesync_application_385/pages/user_roles_page.dart';
import 'package:givesync_application_385/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
// End Eunjung You

class ControllerPage extends StatefulWidget {
  final int? startIndex; 
  const ControllerPage({
    super.key,
    this.startIndex
    });

  @override
  State<ControllerPage> createState() => _ControllerPageState();
}

class _ControllerPageState extends State<ControllerPage> {
  // Integer for keeping track of the currently displayed page index
  int _currentPageIndex = 0;
  String? permissionLevel;

  @override
  void initState() {
    super.initState();
    // Use widget.startIndex if provided and valid, otherwise default to 0
    _currentPageIndex = (widget.startIndex != null &&
            widget.startIndex! >= 0 &&
            widget.startIndex! < _pages.length)
        ? widget.startIndex!
        : 0;
    //Start Eunjung
    // Load permission level only once when app starts.
    UserService().loadPermissionLevelOnce();
    permissionLevel = UserService.cachedPermissionLevel;
    //End Eunjung
  }

  // This method updates the new index
  void _navigateBottomBar(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  // List of page indicies
  final List _pages = [
    // Donation intake page
    DonationPage(),
    // Database page
    DatabasePage(),

    // TODO: Make it so admin or staff can only see this
    DonationTrendsPage(),

    // Settings page
    SettingsPage()
  ];

  @override
  Widget build(BuildContext context) {
    // Only show user roles page if user is admin.
    IconButton? leading;
    if (permissionLevel == null || permissionLevel != "admin") {
      leading = null;
    }
    else {
      leading = IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => UserRolesPage()),
            ).then((_) {
              setState(() {});
            });
          }, 
          tooltip: "Manage User Roles",
          icon: Icon(Icons.supervised_user_circle)
          );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Center(child: Text("GiveSync")),
        // Leading button for the user roles page for admins
        leading: leading,
        elevation: 0,
        //Start Eunjung You - User login
          actions: [
            // Show user name or "Guest" if not logged in
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  FirebaseAuth.instance.currentUser != null
                      ? "Hello ${FirebaseAuth.instance.currentUser!.email!.split('@')[0]} "
                      "(${UserService.cachedPermissionLevel ?? 'loading...'})"
                      : "Hello Guest",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Show logout button when logged in
            if (FirebaseAuth.instance.currentUser != null)
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: "Logout",
                onPressed: () async {
                  // Sign out the current user
                  await FirebaseAuth.instance.signOut();

                  // Start Eunjung — Clear cached permission also
                  UserService.cachedPermissionLevel = null;
                  // End Eunjung

                  // Replace the current page with LoginPage
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const ControllerPage(startIndex: 0)),
                  );
                },
              ),

            // Show login button only when NOT logged in
            if (FirebaseAuth.instance.currentUser == null)
              IconButton(
                icon: const Icon(Icons.person),
                tooltip: "Login",
                onPressed: () {
                  // Navigate to LoginPage and refresh on return
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
                  ).then((_) {
                    setState(() {});
                  });
                },
              ),
          ]

        //End Eunjung You - Add this part for testing user login
      ),

      body: _pages[_currentPageIndex],
      // The navigation bar allows users to choose which page they want to view
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPageIndex,
        onTap: _navigateBottomBar,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        unselectedLabelStyle: TextStyle(color: Colors.grey),
        selectedLabelStyle: TextStyle(color: Colors.green),
        items: [
          // donation intake
          BottomNavigationBarItem(
            icon : Icon(Icons.edit_note),
            label: "Intake Form",
            tooltip: "Donation Intake Form"
            ),
          // database
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud_sync),
            label: "Database",
            tooltip: "Database View"
            ),
          // donation trends
          // TODO: Only add this when we can cache user permission level, only admin / staff should view
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Donation Trends",
            tooltip: "Donation Trends View"
            ),
          // settings
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
            tooltip: "Settings"
            ),
        ],
      ),
    );
  }
}

