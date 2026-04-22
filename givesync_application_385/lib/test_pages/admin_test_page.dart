import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminTestPage extends StatefulWidget {
  const AdminTestPage({super.key});

  @override
  State<AdminTestPage> createState() => _AdminTestPageState();
}

class _AdminTestPageState extends State<AdminTestPage> {
  final emailController = TextEditingController();
  final permissionController = TextEditingController();

  String result = "";

  // Fetch permission by email
  Future<void> fetchPermission() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection("user_permission_levels")
          .where("email", isEqualTo: emailController.text.trim())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        setState(() => result = "User not found");
        return;
      }

      final data = query.docs.first.data();
      final currentLevel = data["permission_level"];

      setState(() => result = "Current Permission: $currentLevel");
    } catch (e) {
      setState(() => result = "Error: $e");
    }
  }

  // Update permission by email
  Future<void> updatePermission() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection("user_permission_levels")
          .where("email", isEqualTo: emailController.text.trim())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        setState(() => result = "User not found");
        return;
      }

      final docId = query.docs.first.id;

      await FirebaseFirestore.instance
          .collection("user_permission_levels")
          .doc(docId)
          .update({
        "permission_level": permissionController.text.trim(),
      });

      setState(() => result = "Permission Updated");
    } catch (e) {
      setState(() => result = "Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Page")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            textBox(emailController, "User Email"),
            textBox(permissionController, "New Permission Level"),

            ElevatedButton(onPressed: fetchPermission, child: const Text("Get Permission Level")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: updatePermission, child: const Text("Update Permission Level")),

            const SizedBox(height: 20),
            Text(result, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget textBox(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }
}
