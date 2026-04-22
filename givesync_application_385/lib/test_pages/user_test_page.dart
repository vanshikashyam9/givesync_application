import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserTestPage extends StatefulWidget {
  const UserTestPage({super.key});

  @override
  State<UserTestPage> createState() => _UserTestPageState();
}

class _UserTestPageState extends State<UserTestPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final newPasswordController = TextEditingController();

  String result = "";

  // Register
  Future<void> register() async {
    try {
      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection("user_permission_levels")
          .doc(cred.user!.uid)
          .set({
        "email": emailController.text.trim(),
        "phone_number": phoneController.text.trim(),
        "permission_level": "volunteer",
      });

      setState(() {
        result = "Registered Successfully";
      });
    } catch (e) {
      setState(() => result = "Error: $e");
    }
  }

  // Login
  Future<void> login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      setState(() => result = "Login Successful");
    } catch (e) {
      setState(() => result = "Login Failed: $e");
    }
  }

  // Fetch Permission
  Future<void> getPermission() async {
    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        setState(() => result = "No user logged in");
        return;
      }

      DocumentSnapshot snap = await FirebaseFirestore.instance
          .collection("user_permission_levels")
          .doc(uid)
          .get();

      setState(() {
        result = "Permission Level: ${snap["permission_level"]}";
      });
    } catch (e) {
      setState(() => result = "Error: $e");
    }
  }

  // Update Phone Number
  Future<void> updatePhone() async {
    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      await FirebaseFirestore.instance
          .collection("user_permission_levels")
          .doc(uid)
          .update({
        "phone_number": phoneController.text.trim(),
      });

      setState(() => result = "Phone Updated");
    } catch (e) {
      setState(() => result = "Error: $e");
    }
  }

  // Update Password
  Future<void> updatePassword() async {
    try {
      await FirebaseAuth.instance.currentUser
          ?.updatePassword(newPasswordController.text.trim());

      setState(() => result = "Password Updated");
    } catch (e) {
      setState(() => result = "Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Test Page")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              textBox(emailController, "Email"),
              textBox(passwordController, "Password", obscure: true),
              textBox(phoneController, "Phone Number"),
              const SizedBox(height: 10),

              ElevatedButton(onPressed: register, child: const Text("Register")),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: login, child: const Text("Login")),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: getPermission, child: const Text("Get Permission Level")),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: updatePhone, child: const Text("Update Phone")),

              const SizedBox(height: 20),

              textBox(newPasswordController, "New Password", obscure: true),
              ElevatedButton(onPressed: updatePassword, child: const Text("Update Password")),

              const SizedBox(height: 20),
              Text(result, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget textBox(TextEditingController c, String label, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        obscureText: obscure,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }
}
