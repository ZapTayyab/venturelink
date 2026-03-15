import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firebase_service.dart';
import '../../../services/functions_service.dart';
import '../../../shared/models/startup_model.dart';

class AdminRepository {
  final FirebaseFirestore _db = FirebaseService.firestore;

  Stream<List<StartupModel>> watchAllStartups() {
    return _db
        .collection(FirebaseService.startupsCollection)
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

  Future<void> moderateStartup({
    required String startupId,
    required String action,
    String? note,
  }) async {
    await FunctionsService.moderateStartup({
      'startupId': startupId,
      'action': action,
      if (note != null) 'note': note,
    });
  }

  Future<Map<String, dynamic>> getPlatformMetrics() async {
    return FunctionsService.getPlatformMetrics();
  }
}