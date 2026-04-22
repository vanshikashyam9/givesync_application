import 'package:flutter/material.dart';
import 'package:givesync_application_385/util/bug_report_backend_controller.dart';
import 'package:givesync_application_385/services/user_service.dart';

// This is for text sizing applications applied for all texts in the app
class TextSizeController extends ChangeNotifier {
  double textSize = 16.0;

  void setTextSize(double size) {
    textSize = size;
    notifyListeners(); // tells the app to rebuild using new size
  }
}

class ThemeController extends ChangeNotifier {
  bool isDarkMode = false;

  void toggleDarkMode(bool value) {
    isDarkMode = value;
    notifyListeners(); // tells the app to rebuild with new theme
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final textSizeController = TextSizeController();
  final themeController = ThemeController();

  // Text field controllers
  final TextEditingController bugTitleController = TextEditingController();
  final TextEditingController bugDescController = TextEditingController();

  void _submitBugReport(BuildContext context) {
    if (UserService.cachedPermissionLevel == null ||
        UserService.cachedPermissionLevel == "unassigned") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign in to submit a bug report!'),
          duration: Duration(seconds: 2),
        ),
      );

      return;
    }

    final bugTitle = bugTitleController.text.trim();
    final bugDescription = bugDescController.text.trim();

    if (bugTitle.isEmpty || bugDescription.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please fill out all fields.")));
      return;
    }

    // Add the bug report in the backend.
    BugReportController.setCurrentName(bugTitle);
    BugReportController.setCurrentReport(bugDescription);
    BugReportController.tryAddBugReport();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Bug Report Submitted"),
        content: Text("Thank you for your feedback!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );

    // Clear fields
    bugTitleController.clear();
    bugDescController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([textSizeController, themeController]),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: themeController.isDarkMode
              ? Colors.grey.shade900
              : Colors.white,
          body: Padding(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // --------------------------
                  // TEXT SIZE SECTION
                  // --------------------------
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: themeController.isDarkMode
                          ? Colors.grey.shade800
                          : Colors.white,
                      border: Border.all(
                        color: themeController.isDarkMode
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Text Size",
                          style: TextStyle(
                            fontSize: textSizeController.textSize,
                            color: themeController.isDarkMode
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        Slider(
                          value: textSizeController.textSize,
                          min: 12,
                          max: 30,
                          divisions: 18,
                          label: textSizeController.textSize.toStringAsFixed(0),
                          onChanged: (value) {
                            textSizeController.setTextSize(value);
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.0),

                  // --------------------------
                  // DARK MODE SECTION
                  // --------------------------
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: themeController.isDarkMode
                          ? Colors.grey.shade800
                          : Colors.white,
                      border: Border.all(
                        color: themeController.isDarkMode
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Dark Mode",
                          style: TextStyle(
                            fontSize: textSizeController.textSize,
                            color: themeController.isDarkMode
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        Switch(
                          value: themeController.isDarkMode,
                          onChanged: (value) {
                            themeController.toggleDarkMode(value);
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.0),

                  // --------------------------
                  // BUG REPORT SECTION
                  // --------------------------
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: themeController.isDarkMode
                          ? Colors.grey.shade800
                          : Colors.white,
                      border: Border.all(
                        color: themeController.isDarkMode
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Report a Bug",
                          style: TextStyle(
                            fontSize: textSizeController.textSize + 2,
                            fontWeight: FontWeight.bold,
                            color: themeController.isDarkMode
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),

                        SizedBox(height: 12),

                        TextField(
                          controller: bugTitleController,
                          decoration: InputDecoration(
                            labelText: "Bug Title",
                            labelStyle: TextStyle(
                              fontSize: textSizeController.textSize,
                              color: themeController.isDarkMode
                                  ? Colors.white70
                                  : Colors.grey.shade700,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: themeController.isDarkMode
                                    ? Colors.white38
                                    : Colors.grey,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: themeController.isDarkMode
                                    ? Colors.blue.shade200
                                    : Colors.blue,
                              ),
                            ),
                          ),
                          style: TextStyle(
                            fontSize: textSizeController.textSize,
                            color: themeController.isDarkMode
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),

                        SizedBox(height: 12),

                        TextField(
                          controller: bugDescController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText: "Describe the issue",
                            labelStyle: TextStyle(
                              fontSize: textSizeController.textSize,
                              color: themeController.isDarkMode
                                  ? Colors.white70
                                  : Colors.grey.shade700,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: themeController.isDarkMode
                                    ? Colors.white38
                                    : Colors.grey,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: themeController.isDarkMode
                                    ? Colors.blue.shade200
                                    : Colors.blue,
                              ),
                            ),
                          ),
                          style: TextStyle(
                            fontSize: textSizeController.textSize,
                            color: themeController.isDarkMode
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),

                        SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _submitBugReport(context);
                            },
                            child: Text(
                              "Submit",
                              style: TextStyle(
                                fontSize: textSizeController.textSize,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
