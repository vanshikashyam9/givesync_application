import 'package:flutter/material.dart';

class UserRolesViewCell extends StatefulWidget {
  final String fullName;
  final String email;
  final String phone;
  final String role; // volunteer, staff, admin
  final ValueChanged<String>? onRoleChanged;

  const UserRolesViewCell({
    super.key,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    this.onRoleChanged,
  });

  @override
  State<UserRolesViewCell> createState() => _UserRolesViewCellState();
}

class _UserRolesViewCellState extends State<UserRolesViewCell> {
  late String _role;

  @override
  void initState() {
    super.initState();
    _role = widget.role;
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _role.toLowerCase() == "admin";

    // Allowed roles. Admin should never be selectable unless it's the current role.
    final dropdownItems = isAdmin
        ? [
            const DropdownMenuItem(value: "admin", child: Text("Admin")),
          ]
        : const [
            DropdownMenuItem(value: "volunteer", child: Text("Volunteer")),
            DropdownMenuItem(value: "staff", child: Text("Staff")),
          ];

    return Card(
      color: Colors.green.shade300,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: info on left, delete button on right
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left info column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // keep text left aligned
                    children: [
                      Text("Name: ${widget.fullName}", style: const TextStyle(fontSize: 16)),
                      Text("Email: ${widget.email}"),
                      Text("Phone: ${widget.phone}"),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),

                // TODO: Add delete button funcitonality for firebase
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),

            // Role dropdown
            Row(
              children: [
                const Text("Role: "),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _role,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: dropdownItems,
                    onChanged: isAdmin
                        ? null // admin role cannot be changed
                        : (value) {
                            if (value == null) return;
                            setState(() => _role = value);
                            widget.onRoleChanged?.call(value);
                          },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
