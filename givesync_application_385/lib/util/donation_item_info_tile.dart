import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:givesync_application_385/util/local_database_controller.dart';

/// A tile representing a single donation item entry.
/// Allows inputting weight, choosing an end location, and removing the item.
class DonationItemInfoTile extends StatefulWidget {
  final int index;
  final String category;
  final VoidCallback onRemove;
  final Map<String, dynamic>? initialData;

  const DonationItemInfoTile({
    super.key,
    required this.index,
    required this.category,
    required this.onRemove,
    this.initialData,
  });

  @override
  State<DonationItemInfoTile> createState() => _DonationItemInfoTileState();
}

class _DonationItemInfoTileState extends State<DonationItemInfoTile> {
  /// Controller for the weight input field.
  late TextEditingController weightController;

  /// Controller for optional name field (you referenced this in your code).
  late TextEditingController nameController;

  /// The currently selected end location (e.g., Client, Farm, Compost).
  String? selectedEndLocation;

  /// List of possible end locations for the donation.
  final List<String> endLocations = ['Client', 'Farm', 'Compost'];

  @override
  void initState() {
    super.initState();

    // Initialize controllers using initialData if available
    nameController = TextEditingController(
      text: widget.initialData?['name'] ?? '',
    );

    weightController = TextEditingController(
      text: widget.initialData?['weight']?.toString() ?? '',
    );

    // Prefill selected location if editing
    selectedEndLocation = widget.initialData?['endLocation'];
  }

  @override
  void dispose() {
    weightController.dispose();
    nameController.dispose();
    super.dispose();
  }

  /// Builds the donation intake tile UI.
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green.shade300,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Displays the donation category at the top of the tile
            Text(
              widget.category,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Row: weight input, location chips, remove button
            Row(
              children: [
                // Weight input field
                SizedBox(
                  width: 90,
                  child: TextField(
                    controller: weightController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      // Allow numeric input with an optional decimal
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      // Limit input length for formatting consistency
                      LengthLimitingTextInputFormatter(5),
                    ],
                    onChanged: (value) =>
                        LocalDatabaseController.editDonation(
                          widget.index,
                          widget.category,
                          weight: double.tryParse(value),
                        ),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "kg",
                      labelStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      filled: true,
                      fillColor: Colors.green.shade400,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // End location selection chips
                Expanded(
                  child: Wrap(
                    spacing: 4,
                    children: endLocations.map((location) {
                      final isSelected = selectedEndLocation == location;
                      return _LocationChip(
                        label: location,
                        selected: isSelected,
                        onTap: () {
                          LocalDatabaseController.editDonation(
                            widget.index,
                            widget.category,
                            endLocation: location,
                          );

                          setState(() {
                            selectedEndLocation = location;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),

                // Remove button for this item
                IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  tooltip: "Remove item",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A chip-style button representing an end location option.
/// Changes color and style when selected.
class _LocationChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LocationChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeInOut,
      constraints: const BoxConstraints(minWidth: 30, minHeight: 36),
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.green.shade400,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white54),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.green : Colors.white,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
