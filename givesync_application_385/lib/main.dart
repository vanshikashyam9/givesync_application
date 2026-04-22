import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:givesync_application_385/util/bug_report_backend_controller.dart';
import 'firebase_options.dart';
import 'package:givesync_application_385/pages/controller_page.dart';
import 'package:givesync_application_385/util/local_database_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:givesync_application_385/pages/settings_page.dart'; // for text sizing
// UserService import is needed because we must clear its cached permission.
import 'package:givesync_application_385/services/user_service.dart';


void main() async {
  // Initialize Google Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Always sign out when the app launches to avoid reusing old sessions.
  // This also clears cached permission data so UI does not show old role.
  await FirebaseAuth.instance.signOut();
  UserService.cachedPermissionLevel = null;

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final textSizeController = TextSizeController();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // initialize singleton(s)
    LocalDatabaseController();
    BugReportController();

    // build app UI
    return AnimatedBuilder(
      animation: textSizeController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: ControllerPage(),
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
            useMaterial3: true,

            textTheme: TextTheme(
              bodyLarge: TextStyle(fontSize: textSizeController.textSize),
              bodyMedium: TextStyle(fontSize: textSizeController.textSize),
              bodySmall: TextStyle(fontSize: textSizeController.textSize),
            ),

            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
