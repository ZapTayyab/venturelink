import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firebase_service.dart';
import '../../../services/functions_service.dart';
import '../../../shared/models/investment_model.dart';

class InvestmentRepository {
  final FirebaseFirestore _db = FirebaseService.firestore;

  Stream<List<InvestmentModel>> watchInvestorInvestments(String investorId) {
    return _db
        .collection(FirebaseService.investmentsCollection)
        .where('investorId', isEqualTo: investorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(InvestmentModel.fromFirestore).toList());
  }

  Stream<List<InvestmentModel>> watchRoundInvestments(String roundId) {
    return _db
        .collection(FirebaseService.investmentsCollection)
        .where('roundId', isEqualTo: roundId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(InvestmentModel.fromFirestore).toList());
  }

  Future<void> makeInvestment(Map<String, dynamic> data) async {
    await FunctionsService.makeInvestment(data);
  }
}