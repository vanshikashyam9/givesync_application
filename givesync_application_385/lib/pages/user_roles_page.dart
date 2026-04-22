import 'package:flutter/material.dart';
import 'package:givesync_application_385/util/edit_user_permissions_tile.dart';

class UserRolesPage extends StatefulWidget {
  const UserRolesPage({super.key});

  @override
  State<UserRolesPage> createState() => _UserRolesPageState();
}

class _UserRolesPageState extends State<UserRolesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit User Roles"),
        centerTitle: true,
      ),
      body: EditUserPermissionsTile(),
    );
  }
}