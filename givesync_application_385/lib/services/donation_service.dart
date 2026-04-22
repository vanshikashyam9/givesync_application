import 'package:cloud_firestore/cloud_firestore.dart';

class DonationService {
  // Firestore instance for reading and writing data
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save donation data into Firestore
  //
  // jsonText: the form data saved as a single JSON string
  // uniqueId: a unique document ID for this donation entry
  //
  // Returns "success" if saved correctly
  // Returns an error message if something goes wrong
  Future<String?> saveDonation({
    required String jsonText,
    required String uniqueId,
  }) async {
    try {
      await _firestore.collection("donations").doc(uniqueId).set({
        "json_text": jsonText,
        "unique_id": uniqueId,
      });

      return "success";
    } catch (e) {
      return e.toString();
    }
  }
}
