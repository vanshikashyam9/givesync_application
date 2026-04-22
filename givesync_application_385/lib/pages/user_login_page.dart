import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:givesync_application_385/pages/user_register_page.dart';
import 'package:givesync_application_385/pages/controller_page.dart';
import 'package:givesync_application_385/services/user_service.dart';

/// LoginPage handles user authentication.
/// After successful login, the user is forwarded to ControllerPage.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // User input controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String result = "";

  /// Attempts to authenticate user using FirebaseAuth.
  /// After success: loads permission level, then goes to ControllerPage.
  Future<void> login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Load permission level for navbar/menu access
      await UserService().loadPermissionLevelOnce();

      // Navigate to main controller page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ControllerPage()),
      );

    } catch (e) {
      setState(() => result = "Login Failed: $e");
    }
  }

  // ---------------------------------------------------------
  // NEW: Reset password function using FirebaseAuth
  // Sends a reset email to the provided email address
  // ---------------------------------------------------------
  Future<void> resetPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        result = "Please enter your email first.";
      });
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      setState(() {
        result = "Password reset email sent to $email";
      });
    } catch (e) {
      setState(() {
        result = "Error: $e";
      });
    }
  }

  /// Builds a standard input field.
  Widget input(TextEditingController c, String label, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// A green action button shared in this page.
  Widget actionGreen(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontSize: 18)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Login", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),

      backgroundColor: Colors.grey[100],

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "GiveSync Login",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              // ------------------------------
              // Login Input Card
              // ------------------------------
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      input(emailController, "Email"),
                      input(passwordController, "Password", obscure: true),

                      const SizedBox(height: 10),

                      // Login Button
                      actionGreen("Login", login),

                      const SizedBox(height: 8),

                      // ---------------------------------------------------------
                      // NEW: "Forgot password" clickable text
                      // ---------------------------------------------------------
                      TextButton(
                        onPressed: resetPassword,
                        child: const Text(
                          "Forgot your password?",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Error or status text
              Text(
                result,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 12),

              // Create Account Link
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  );
                },
                child: const Text(
                  "Create an account",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
