import 'package:flutter/material.dart';
import 'package:givesync_application_385/util/donation_intake_tile.dart';
import 'package:givesync_application_385/util/intake_form_tile.dart';

/// page for editing donations from the cloud
class DonationDetailPage extends StatefulWidget {
  final Map<String, dynamic> entry;
  const DonationDetailPage({super.key, required this.entry});

  @override
  State<DonationDetailPage> createState() => _DonationDetailPageState();
}

class _DonationDetailPageState extends State<DonationDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Donation Details"),
        centerTitle: true,
      ),
      body: ListView(children: [IntakeFormTile(initialEntry: widget.entry)]),
    );
  }
}
