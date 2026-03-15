import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firebase_service.dart';
import '../../../services/functions_service.dart';
import '../../../shared/models/startup_model.dart';
import '../../../shared/enums/startup_status.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_handler.dart';

class StartupRepository {
  final FirebaseFirestore _db = FirebaseService.firestore;

  Stream<List<StartupModel>> watchApprovedStartups() {
    return _db
        .collection(FirebaseService.startupsCollection)
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(StartupModel.fromFirestore).toList());
  }

  Stream<List<StartupModel>> watchFounderStartups(String founderId) {
    return _db
        .collection(FirebaseService.startupsCollection)
        .where('founderId', isEqualTo: founderId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(StartupModel.fromFirestore).toList());
  }

  Stream<List<StartupModel>> watchPendingStartups() {
    return _db
        .collection(FirebaseService.startupsCollection)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(StartupModel.fromFirestore).toList());
  }

  Future<StartupModel?> getStartup(String startupId) async {
    try {
      final doc = await _db
          .collection(FirebaseService.startupsCollection)
          .doc(startupId)
          .get();
      if (!doc.exists) return null;
      return StartupModel.fromFirestore(doc);
    } catch (e, stack) {
      ErrorHandler.log('Get startup failed', error: e, stackTrace: stack);
      throw const AppException(message: 'Failed to load startup', code: 'fetch-failed');
    }
  }

  Stream<StartupModel?> watchStartup(String startupId) {
    return _db
        .collection(FirebaseService.startupsCollection)
        .doc(startupId)
        .snapshots()
        .map((doc) => doc.exists ? StartupModel.fromFirestore(doc) : null);
  }

  Future<void> createStartup(Map<String, dynamic> data) async {
    await FunctionsService.createStartup(data);
  }

  Future<void> updateStartup(String startupId, Map<String, dynamic> data) async {
    try {
      await _db
          .collection(FirebaseService.startupsCollection)
          .doc(startupId)
          .update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw AppException.fromFirebase(e);
    }
  }

  Future<void> deleteStartup(String startupId) async {
    try {
      await _db
          .collection(FirebaseService.startupsCollection)
          .doc(startupId)
          .delete();
    } on FirebaseException catch (e) {
      throw AppException.fromFirebase(e);
    }
  }
}