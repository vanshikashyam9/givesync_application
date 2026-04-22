import 'package:flutter/material.dart';
import 'package:givesync_application_385/pages/database_page.dart';
import 'package:givesync_application_385/pages/settings_page.dart';
import 'package:givesync_application_385/util/intake_form_tile.dart';

class DonationPage extends StatefulWidget {
  const DonationPage({super.key});

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(children: [IntakeFormTile()]),
    );
  }
}
