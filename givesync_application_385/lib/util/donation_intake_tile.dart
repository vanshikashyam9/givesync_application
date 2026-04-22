import 'package:flutter/material.dart';
import 'package:givesync_application_385/util/local_database_controller.dart';
import 'donation_item_info_tile.dart'; // Import the item info tile widget.

/// A widget that allows users to select food categories and add donation items.
/// Each selected category creates a corresponding [DonationItemInfoTile].
class DonationIntakeTile extends StatefulWidget {
  final Map<String, dynamic>? initialDonation;
  const DonationIntakeTile({
    super.key,
    this.initialDonation
  });

  @override
  State<DonationIntakeTile> createState() => _DonationIntakeTileState();
}

class _DonationIntakeTileState extends State<DonationIntakeTile> {
  /// Predefined list of food categories for selection.
  final List<String> _categories = [
    'Canned Goods',
    'Produce',
    'Dairy',
    'Bakery',
    'Meat',
    'Frozen',
    'Other',
  ];

  @override
  void initState() {
    super.initState();

    // If editing an existing donation entry:
    if (widget.initialDonation != null && widget.initialDonation!['donations'] != null) {
      final donations = widget.initialDonation!['donations'] as List<dynamic>;

      for (final d in donations) {
        if (d is Map && d.containsKey('category')) {
          _selectedCategories.add(d['category']);
        }
      }
    }
  }

  /// Tracks categories that have been selected by the user.
  final List<String> _selectedCategories = [];

  /// Adds a category to the list of selected items.
  void _addCategory(String category) {
    setState(() {
      _selectedCategories.add(category);
    });
  }

  /// Builds the donation intake tile UI.
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title for category selection
            const Text(
              'Select Food Category:',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 16),

            // Displays all category buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((category) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onPressed: () => _addCategory(category),
                  child: Text(category),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Section title for current donation items
            const Text(
              'Current Donation Items:',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),

            // Displays all added donation item tiles
            Container(
              decoration: BoxDecoration(
                color: Colors.green.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                children: _selectedCategories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final category = entry.value;

                  return DonationItemInfoTile(
                    index: index,
                    category: category,
                    onRemove: () {
                      setState(() => _selectedCategories.removeAt(index));
                      LocalDatabaseController.removeDonation(index);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
