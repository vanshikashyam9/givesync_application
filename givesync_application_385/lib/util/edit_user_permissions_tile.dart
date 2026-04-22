import 'package:flutter/material.dart';
import 'package:givesync_application_385/util/save_user_roles_button.dart';
import 'package:givesync_application_385/util/user_roles_view_tile.dart';

class EditUserPermissionsTile extends StatefulWidget {
  const EditUserPermissionsTile({super.key});

  @override
  State<EditUserPermissionsTile> createState() => _EditUserPermissionsTileState();
}

class _EditUserPermissionsTileState extends State<EditUserPermissionsTile> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsetsGeometry.all(12),
            child: SearchBar(
              hintText: "Search by name...",
              // TODO: add search filtering with names
              onChanged: (value) => {
      
              },
            ),
          ),
          SaveUserRolesButton(),
          UserRolesViewTile(),
        ],
      ),
    );
  }
}