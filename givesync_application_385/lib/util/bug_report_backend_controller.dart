import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

class BugReportController {
  static late BugReportController bugReportController;
  static late FirebaseFirestore firestore;

  static const int maxReportCount = 100;

  String? currentName;
  String? currentReport;

  BugReportController() {
    firestore = FirebaseFirestore.instance;

    bugReportController = this;
  }

  static void setCurrentName(String? newName) {
    bugReportController.currentName = newName;

    log(
      "[bug_report_backend_controller.dart] Set currentName to: ${bugReportController.currentName}",
    );
  }

  static void setCurrentReport(String? newReport) {
    bugReportController.currentReport = newReport;

    log(
      "[bug_report_backend_controller.dart] Set currentReport to: ${bugReportController.currentReport}",
    );
  }

  static bool isBugReportValid() {
    return bugReportController.currentName != null &&
        bugReportController.currentReport != null;
  }

  static Future<bool> tryAddBugReport() async {
    if (!isBugReportValid()) return false;

    QuerySnapshot<Map<String, dynamic>> query = await firestore
        .collection("bug_reports")
        .get();
    int currentReports = query.docs.length;

    if (currentReports >= maxReportCount) {
      var reportToDelete = query.docs.elementAt(0).id;

      firestore
          .collection("bug_reports")
          .doc(reportToDelete)
          .delete()
          .then(
            (value) => log(
              "[bug_report_backend_controller.dart] Bug report deleted. ID: $reportToDelete",
            ),
          )
          .catchError(
            (error) => log(
              "[bug_report_backend_controller.dart] Failed to delete bug report: $error.",
            ),
          );
    }

    firestore
        .collection("bug_reports")
        .add({
          "name": bugReportController.currentName,
          "report": bugReportController.currentReport,
        })
        .then(
          (value) =>
              log("[bug_report_backend_controller.dart] Added bug report."),
        )
        .catchError(
          (error) => log(
            "[bug_report_backend_controller.dart] Failed to add bug report: $error.",
          ),
        );

    bugReportController.currentName = null;
    bugReportController.currentReport = null;

    return true;
  }
}
