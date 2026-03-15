import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/startup_status.dart';

class StartupModel {
  final String id;
  final String founderId;
  final String founderName;
  final String name;
  final String description;
  final String industry;
  final String? website;
  final String? location;
  final int teamSize;
  final String? logoUrl;
  final StartupStatus status;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StartupModel({
    required this.id,
    required this.founderId,
    required this.founderName,
    required this.name,
    required this.description,
    required this.industry,
    this.website,
    this.location,
    required this.teamSize,
    this.logoUrl,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StartupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StartupModel(
      id: doc.id,
      founderId: data['founderId'] as String? ?? '',
      founderName: data['founderName'] as String? ?? '',
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      industry: data['industry'] as String? ?? '',
      website: data['website'] as String?,
      location: data['location'] as String?,
      teamSize: data['teamSize'] as int? ?? 1,
      logoUrl: data['logoUrl'] as String?,
      status: StartupStatus.fromString(data['status'] as String?),
      rejectionReason: data['rejectionReason'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'founderId': founderId,
        'founderName': founderName,
        'name': name,
        'description': description,
        'industry': industry,
        'website': website,
        'location': location,
        'teamSize': teamSize,
        'logoUrl': logoUrl,
        'status': status.name,
        'rejectionReason': rejectionReason,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  StartupModel copyWith({
    String? name,
    String? description,
    String? industry,
    String? website,
    String? location,
    int? teamSize,
    String? logoUrl,
    StartupStatus? status,
    String? rejectionReason,
  }) {
    return StartupModel(
      id: id,
      founderId: founderId,
      founderName: founderName,
      name: name ?? this.name,
      description: description ?? this.description,
      industry: industry ?? this.industry,
      website: website ?? this.website,
      location: location ?? this.location,
      teamSize: teamSize ?? this.teamSize,
      logoUrl: logoUrl ?? this.logoUrl,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}