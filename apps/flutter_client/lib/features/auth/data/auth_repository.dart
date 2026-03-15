import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_handler.dart';
import '../../../services/firebase_service.dart';
import '../../../shared/enums/user_role.dart';
import '../../../shared/models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseService.auth;
  final FirebaseFirestore _db = FirebaseService.firestore;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> getCurrentUserModel() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _getUserModel(user.uid);
  }

  Future<UserModel?> _getUserModel(String uid) async {
    try {
      final doc = await _db.collection(FirebaseService.usersCollection).doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e, stack) {
      ErrorHandler.log('Get user model failed', error: e, stackTrace: stack);
      return null;
    }
  }

  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user!.updateDisplayName(displayName);

      final now = DateTime.now();
      final userModel = UserModel(
        uid: credential.user!.uid,
        email: email,
        displayName: displayName,
        role: role,
        isVerified: false,
        createdAt: now,
        updatedAt: now,
      );

      await _db
          .collection(FirebaseService.usersCollection)
          .doc(credential.user!.uid)
          .set(userModel.toFirestore());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AppException.fromFirebase(e);
    } catch (e) {
      throw AppException.unknown();
    }
  }

  Future<UserModel> login({
  required String email,
  required String password,
}) async {
  try {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // Try to get existing user document
    var userModel = await _getUserModel(credential.user!.uid);
    
    // If no document exists, create one automatically
    if (userModel == null) {
      final now = DateTime.now();
      userModel = UserModel(
        uid: credential.user!.uid,
        email: email,
        displayName: credential.user!.displayName ?? email.split('@').first,
        role: UserRole.investor,
        isVerified: false,
        createdAt: now,
        updatedAt: now,
      );
      await _db
          .collection(FirebaseService.usersCollection)
          .doc(credential.user!.uid)
          .set(userModel.toFirestore());
    }
    
    return userModel;
  } on FirebaseAuthException catch (e) {
    throw AppException.fromFirebase(e);
  } on AppException {
    rethrow;
  } catch (e) {
    throw AppException.unknown();
  }
}

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AppException.fromFirebase(e);
    }
  }

  Stream<UserModel?> userStream(String uid) {
    return _db
        .collection(FirebaseService.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  Future<void> updateProfile({
    required String uid,
    required String displayName,
  }) async {
    try {
      await _db
          .collection(FirebaseService.usersCollection)
          .doc(uid)
          .update({'displayName': displayName, 'updatedAt': FieldValue.serverTimestamp()});
      await _auth.currentUser?.updateDisplayName(displayName);
    } on FirebaseException catch (e) {
      throw AppException.fromFirebase(e);
    }
  }
}