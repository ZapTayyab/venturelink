import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/round_status.dart';

class FundingRoundModel {
  final String id;
  final String startupId;
  final String startupName;
  final String founderId;
  final String title;
  final double targetAmount;
  final double raisedAmount;
  final double minInvestment;
  final RoundStatus status;
  final DateTime deadline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int investorCount;

  const FundingRoundModel({
    required this.id,
    required this.startupId,
    required this.startupName,
    required this.founderId,
    required this.title,
    required this.targetAmount,
    required this.raisedAmount,
    required this.minInvestment,
    required this.status,
    required this.deadline,
    required this.createdAt,
    required this.updatedAt,
    required this.investorCount,
  });

  double get progressPercent =>
      targetAmount > 0 ? (raisedAmount / targetAmount * 100).clamp(0, 100) : 0;

  double get remainingAmount => (targetAmount - raisedAmount).clamp(0, targetAmount);

  bool get isOpen => status == RoundStatus.open && deadline.isAfter(DateTime.now());

  factory FundingRoundModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FundingRoundModel(
      id: doc.id,
      startupId: data['startupId'] as String? ?? '',
      startupName: data['startupName'] as String? ?? '',
      founderId: data['founderId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      targetAmount: (data['targetAmount'] as num?)?.toDouble() ?? 0,
      raisedAmount: (data['raisedAmount'] as num?)?.toDouble() ?? 0,
      minInvestment: (data['minInvestment'] as num?)?.toDouble() ?? 0,
      status: RoundStatus.fromString(data['status'] as String?),
      deadline: (data['deadline'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      investorCount: data['investorCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'startupId': startupId,
        'startupName': startupName,
        'founderId': founderId,
        'title': title,
        'targetAmount': targetAmount,
        'raisedAmount': raisedAmount,
        'minInvestment': minInvestment,
        'status': status.name,
        'deadline': Timestamp.fromDate(deadline),
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
        'investorCount': investorCount,
      };
}