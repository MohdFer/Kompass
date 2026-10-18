import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a real-time Roll Call 4-digit code session created by a Tour Guide.
class RollCallSessionModel {
  final String code;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String createdBy;
  final String? createdByName;
  final bool isActive;

  RollCallSessionModel({
    required this.code,
    required this.createdAt,
    required this.expiresAt,
    required this.createdBy,
    this.createdByName,
    this.isActive = true,
  });

  /// Check if the session has expired past its expiration timestamp.
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Remaining duration before expiration.
  Duration get remainingDuration {
    final diff = expiresAt.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  factory RollCallSessionModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return RollCallSessionModel(
      code: data['code']?.toString() ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy']?.toString() ?? '',
      createdByName: data['createdByName']?.toString(),
      isActive: data['isActive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'code': code,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'createdBy': createdBy,
      if (createdByName != null) 'createdByName': createdByName,
      'isActive': isActive,
    };
  }
}
