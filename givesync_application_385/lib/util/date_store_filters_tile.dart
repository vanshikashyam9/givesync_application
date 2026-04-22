// Version History
// v1.0 (2025-11-25) - Eunjung
//   Added date and store filter callbacks (onDateChanged, onStoreChanged)
//   Implemented real DateRangePicker for date filtering
//   Added store selection callback connection
//   Updated state changes to notify parent widget
//   Added Dropdown store selector (All, Store 1, Store 2, Store 3).

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateStoreFiltersTile extends StatefulWidget {

  // Start Eunjung
  // Parent callbacks to notify about date or store changes
  final Function(DateTime start, DateTime end) onDateChanged;
  final Function(String store) onStoreChanged;
  const DateStoreFiltersTile({
    super.key,
    required this.onDateChanged,
    required this.onStoreChanged,
    // End Eunjung
  });

  @override
  State<DateStoreFiltersTile> createState() => _DateStoreFiltersTileState();
}

class _DateStoreFiltersTileState extends State<DateStoreFiltersTile> {
  late DateTime _startDate;
  late DateTime _endDate;
  // Start Eunjung
  String _store = "All";  // Default: show all stores
  // End Eunjung

  String _format(DateTime date) {
    return DateFormat('MM/dd/yyyy').format(date);
  }

  @override
  void initState() {
    super.initState();
    _endDate = DateTime.now();
    _startDate = DateTime(_endDate.year, _endDate.month - 1, _endDate.day);
  }

  void _changeDateRange(DateTime newStart, DateTime newEnd) {
    setState(() {
      _startDate = newStart;
      _endDate = newEnd;
    });
    // Start Eunjung
    widget.onDateChanged(newStart, newEnd);
    // End Eunjung
  }

  void _changeStore(String newStore) {
    setState(() {
      _store = newStore;
    });
    // Start Eunjung
    widget.onStoreChanged(newStore);
    // End Eunjung
  }

  @override
  Widget build(BuildContext context) {
    final dateRangeText = "${_format(_startDate)} - ${_format(_endDate)}";

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row containing the Date filter button and Store dropdown
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    // TODO: change these to actual backend things
                    // Start Eunjung
                    // Use real DateRangePicker
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      initialDateRange: DateTimeRange(
                        start: _startDate,
                        end: _endDate,
                      ),
                    );

                    if (picked != null) {
                      _changeDateRange(picked.start, picked.end);
                    }
                    // End Eunjung
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text("Filter by Date"),
                ),
              ),
              const SizedBox(width: 12),
              // Start Eunjung (Store Dropdown)
              // Start Eunjung (Store Dropdown)
              Expanded(
                child: Container(
                  height: 49,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),

                  child: DropdownButton<String>(
                    value: _store,
                    isExpanded: true,
                    underline: const SizedBox(),
                    iconEnabledColor: Colors.white,
                    dropdownColor: Colors.white,

                    // Selected item (closed state)
                    selectedItemBuilder: (BuildContext context) {
                      return const [
                        Center(child: Text("All Stores", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                        Center(child: Text("Store 1", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                        Center(child: Text("Store 2", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                        Center(child: Text("Store 3", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                      ];
                    },

                    items: const [
                      DropdownMenuItem(value: "All", child: Text("All Stores", style: TextStyle(color: Colors.black))),
                      DropdownMenuItem(value: "Store 1", child: Text("Store 1", style: TextStyle(color: Colors.black))),
                      DropdownMenuItem(value: "Store 2", child: Text("Store 2", style: TextStyle(color: Colors.black))),
                      DropdownMenuItem(value: "Store 3", child: Text("Store 3", style: TextStyle(color: Colors.black))),
                    ],

                    onChanged: (value) {
                      if (value != null) _changeStore(value);
                    },
                  ),
                ),
              ),
              // End Eunjung
            ],
          ),

          const SizedBox(height: 20),

          // Labels (Date range + Store)
          Text(
            "Current Date Range",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dateRangeText,
            style: const TextStyle(fontSize: 15),
          ),

          const SizedBox(height: 16),

          Text(
            "Current Store",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _store,
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }
}
