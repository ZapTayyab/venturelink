import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firebase_service.dart';
import '../../../services/functions_service.dart';
import '../../../shared/models/funding_round_model.dart';
import '../../../core/errors/app_exception.dart';

class RoundRepository {
  final FirebaseFirestore _db = FirebaseService.firestore;

  Stream<List<FundingRoundModel>> watchStartupRounds(String startupId) {
    return _db
        .collection(FirebaseService.fundingRoundsCollection)
        .where('startupId', isEqualTo: startupId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(FundingRoundModel.fromFirestore).toList());
  }

  Stream<List<FundingRoundModel>> watchOpenRounds() {
    return _db
        .collection(FirebaseService.fundingRoundsCollection)
        .where('status', isEqualTo: 'open')
        .orderBy('deadline')
        .snapshots()
        .map((snap) => snap.docs.map(FundingRoundModel.fromFirestore).toList());
  }

  Stream<FundingRoundModel?> watchRound(String roundId) {
    return _db
        .collection(FirebaseService.fundingRoundsCollection)
        .doc(roundId)
        .snapshots()
        .map((doc) => doc.exists ? FundingRoundModel.fromFirestore(doc) : null);
  }

  Future<void> createRound(Map<String, dynamic> data) async {
    await FunctionsService.createFundingRound(data);
  }

  Future<void> updateRound(String roundId, Map<String, dynamic> data) async {
    try {
      await _db
          .collection(FirebaseService.fundingRoundsCollection)
          .doc(roundId)
          .update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw AppException.fromFirebase(e);
    }
  }
}