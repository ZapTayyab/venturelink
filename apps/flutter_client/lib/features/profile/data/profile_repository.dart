import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firebase_service.dart';
import '../../../shared/models/user_model.dart';
import '../../../core/errors/app_exception.dart';

class ProfileRepository {
  final FirebaseFirestore _db = FirebaseService.firestore;

  Future<void> updateProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _db
          .collection(FirebaseService.usersCollection)
          .doc(uid)
          .update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw AppException.fromFirebase(e);
    }
  }

  Future<UserModel?> getProfile(String uid) async {
    try {
      final doc = await _db
          .collection(FirebaseService.usersCollection)
          .doc(uid)
          .get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw AppException.fromFirebase(e);
    }
  }
}