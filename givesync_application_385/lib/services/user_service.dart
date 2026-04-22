import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cached permission level
  static String? cachedPermissionLevel;

  // UserService handles user-related backend operations.
  // It creates new user accounts, saves user profiles in Firestore,
  // authenticates users during login, and retrieves basic user info.
  // This service is used by the Login and Registration features of the app.

  // Create account
  Future<String?> register({
    required String email,
    required String password,
    required String phoneNumber,
    required String permissionLevel,
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user data in Firestore
      await _firestore
          .collection("user_permission_levels")
          .doc(cred.user!.uid)
          .set({
            "email": email,
            "phone_number": phoneNumber,
            "permission_level": permissionLevel,
          });

      return "success";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Login
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "success";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Current logged-in user
  static User? get currentUser => _auth.currentUser;

  // Get the permission level of the currently logged-in user.
  // This reads the user's document from Firestore and returns the level.
  static Future<String?> getPermissionLevel() async {
    // If cached already, return immediately
    if (cachedPermissionLevel != null) {
      return cachedPermissionLevel;
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _firestore
        .collection("user_permission_levels")
        .doc(uid)
        .get();

    cachedPermissionLevel = doc.data()?["permission_level"];
    return cachedPermissionLevel;
  }

  // This function loads the permission level from Firestore only one time.
  Future<void> loadPermissionLevelOnce() async {
    cachedPermissionLevel = await getPermissionLevel();
  }

  // Update only the phone number field in Firestore.
  // This is used when a logged-in user wants to change their phone number.
  Future<String?> updatePhoneNumber(String newPhone) async {
    final uid = _auth.currentUser?.uid;

    if (uid == null) return "No user logged in";

    try {
      await _firestore.collection("user_permission_levels").doc(uid).update({
        "phone_number": newPhone,
      });
      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  // Update a user's permission level (Admin feature).
  // This requires an admin to provide the target user's UID and the new level.
  Future<String?> updatePermissionLevel({
    required String uid,
    required String newLevel,
  }) async {
    try {
      await _firestore.collection("user_permission_levels").doc(uid).update({
        "permission_level": newLevel,
      });
      return "success";
    } catch (e) {
      return e.toString();
    }
  }
}
