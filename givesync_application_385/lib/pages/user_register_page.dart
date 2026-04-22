import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';   // For filtering digits
import 'package:givesync_application_385/pages/controller_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controllers for input fields
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();

  // Validation messages
  String emailError = "";
  String passwordError = "";
  String phoneError = "";
  String result = "";

  // ------------------------------
  // PHONE FORMAT: auto dash insert
  // ------------------------------
  String _formatPhone(String input) {
    String digits = input.replaceAll(RegExp(r'[^0-9]'), "");
    if (digits.length > 10) digits = digits.substring(0, 10);

    if (digits.length <= 3) {
      return digits;
    } else if (digits.length <= 6) {
      return "${digits.substring(0, 3)}-${digits.substring(3)}";
    } else {
      return "${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}";
    }
  }

  // ------------------------------
  // FORM VALIDATION LOGIC
  // ------------------------------
  bool _isFormValid() {
    // Validate email
    emailError = emailController.text.contains("@") ? "" : "Must be a valid email format (example: user@gmail.com).";

    // Validate password
    passwordError = passwordController.text.length >= 6
        ? ""
        : "Password must be at least 6 characters.";

    // Validate phone (must be 10 digits after removing formatting)
    final digits = phoneController.text.replaceAll(RegExp(r'[^0-9]'), "");
    phoneError = digits.length == 10 ? "" : "Phone must be 10 digits.";

    // Trigger UI update
    setState(() {});

    return emailError.isEmpty && passwordError.isEmpty && phoneError.isEmpty;
  }

  // ------------------------------
  // Firebase registration
  // ------------------------------
  Future<void> register() async {
    if (!_isFormValid()) return;

    try {
      UserCredential cred =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
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

      // After register → go to ControllerPage
      Future.delayed(const Duration(milliseconds: 600), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ControllerPage()),
        );
      });

    } catch (e) {
      setState(() => result = "Error: $e");
    }
  }

  // ------------------------------
  // Reusable text input widget
  // ------------------------------
  Widget input(
      {required TextEditingController controller,
        required String label,
        bool obscure = false,
        TextInputType keyboardType = TextInputType.text,
        void Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // ------------------------------
  // UI Build
  // ------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text("Create Account"),
        backgroundColor: Colors.green,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- EMAIL ----------------
            input(
              controller: emailController,
              label: "Email",
              onChanged: (_) => _isFormValid(),
            ),
            if (emailError.isNotEmpty)
              Text(emailError, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 10),

            // ---------------- PASSWORD ---------------
            input(
              controller: passwordController,
              label: "Password",
              obscure: true,
              onChanged: (_) => _isFormValid(),
            ),
            if (passwordError.isNotEmpty)
              Text(passwordError, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 10),

            // ---------------- PHONE NUMBER ------------
            input(
              controller: phoneController,
              label: "Phone Number",
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                final formatted = _formatPhone(value);
                if (formatted != value) {
                  phoneController.value = TextEditingValue(
                    text: formatted,
                    selection:
                    TextSelection.collapsed(offset: formatted.length),
                  );
                }
                _isFormValid();
              },
            ),
            if (phoneError.isNotEmpty)
              Text(phoneError, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 20),

            // ---------------- Register button --------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isFormValid() ? register : null, // disabled if invalid
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Register", style: TextStyle(fontSize: 18)),
              ),
            ),

            const SizedBox(height: 20),

            // ---------------- Result message --------
            Center(
              child: Text(
                result,
                style: TextStyle(
                  fontSize: 16,
                  color: result.startsWith("Error") ? Colors.red : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
