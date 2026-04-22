import 'package:flutter/material.dart';
import 'package:givesync_application_385/util/user_roles_view_cell.dart';

class UserRolesViewTile extends StatefulWidget {
  const UserRolesViewTile({super.key});

  @override
  State<UserRolesViewTile> createState() => _UserRolesViewTileState();
}

class _UserRolesViewTileState extends State<UserRolesViewTile> {

  // placeholder users for UI testing
  final users = [
    {
      "fullName": "Alice Johnson",
      "email": "alice@example.com",
      "phone": "555-111-2222",
      "role": "volunteer",
    },
    {
      "fullName": "Bob Smith",
      "email": "bob@example.com",
      "phone": "555-222-3333",
      "role": "staff",
    },
    {
      "fullName": "Charlie Admin",
      "email": "admin@example.com",
      "phone": "555-999-8888",
      "role": "admin",
    },
    {
      "fullName": "Charlie Admin",
      "email": "admin@example.com",
      "phone": "555-999-8888",
      "role": "admin",
    },
    {
      "fullName": "Charlie Admin",
      "email": "admin@example.com",
      "phone": "555-999-8888",
      "role": "admin",
    },
    {
      "fullName": "Charlie Admin",
      "email": "admin@example.com",
      "phone": "555-999-8888",
      "role": "admin",
    },
    {
      "fullName": "Charlie Admin",
      "email": "admin@example.com",
      "phone": "555-999-8888",
      "role": "admin",
    },
    {
      "fullName": "Charlie Admin",
      "email": "admin@example.com",
      "phone": "555-999-8888",
      "role": "admin",
    },
    {
      "fullName": "Charlie Admin",
      "email": "admin@example.com",
      "phone": "555-999-8888",
      "role": "admin",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ]
        ),
        padding: const EdgeInsets.all(8),
      
        child: Column(
          children: users.map((u) {
            return UserRolesViewCell(
              fullName: u["fullName"]!,
              email: u["email"]!,
              phone: u["phone"]!,
              role: u["role"]!,
              onRoleChanged: (newRole) {
                setState(() {
                  u["role"] = newRole;
                });
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
