import 'package:flutter/material.dart';
import 'package:givesync_application_385/util/local_database_controller.dart';

/// A widget that lets the user select a store location from a dropdown menu.
/// The selected store is saved locally through [LocalDatabaseController].
class ChooseStoreLocationTile extends StatelessWidget {
  final String? initialStore;

  const ChooseStoreLocationTile({
    super.key,
    this.initialStore
    });

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
        child: Row(
          children: [
            // Label for the store selection
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Choose Store Location:",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            // Dropdown menu for selecting a store
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownMenu<String>(
                  width: double.infinity, // Ensures the dropdown expands fully
                  menuStyle: const MenuStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.white),
                  ),
                  inputDecorationTheme: const InputDecorationTheme(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  initialSelection: initialStore, // Set the initial store if there is a value for it
                  dropdownMenuEntries: const [
                    DropdownMenuEntry(value: "Store 1", label: "Store 1"),
                    DropdownMenuEntry(value: "Store 2", label: "Store 2"),
                    DropdownMenuEntry(value: "Store 3", label: "Store 3"),
                  ],
                  // Store the selected location in the local database
                  onSelected: (store) {
                    LocalDatabaseController.setCurrentStore(store);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
