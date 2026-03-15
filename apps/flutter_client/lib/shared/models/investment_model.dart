import 'package:cloud_firestore/cloud_firestore.dart';

enum InvestmentStatus { pending, confirmed, failed, refunded }

class InvestmentModel {
  final String id;
  final String investorId;
  final String investorName;
  final String startupId;
  final String startupName;
  final String roundId;
  final String roundTitle;
  final double amount;
  final InvestmentStatus status;
  final DateTime createdAt;

  const InvestmentModel({
    required this.id,
    required this.investorId,
    required this.investorName,
    required this.startupId,
    required this.startupName,
    required this.roundId,
    required this.roundTitle,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory InvestmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InvestmentModel(
      id: doc.id,
      investorId: data['investorId'] as String? ?? '',
      investorName: data['investorName'] as String? ?? '',
      startupId: data['startupId'] as String? ?? '',
      startupName: data['startupName'] as String? ?? '',
      roundId: data['roundId'] as String? ?? '',
      roundTitle: data['roundTitle'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      status: _statusFromString(data['status'] as String?),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static InvestmentStatus _statusFromString(String? value) =>
      switch (value?.toLowerCase()) {
        'confirmed' => InvestmentStatus.confirmed,
        'failed' => InvestmentStatus.failed,
        'refunded' => InvestmentStatus.refunded,
        _ => InvestmentStatus.pending,
      };

  Map<String, dynamic> toFirestore() => {
        'investorId': investorId,
        'investorName': investorName,
        'startupId': startupId,
        'startupName': startupName,
        'roundId': roundId,
        'roundTitle': roundTitle,
        'amount': amount,
        'status': status.name,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}