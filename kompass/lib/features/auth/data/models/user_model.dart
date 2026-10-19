import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/enums/user_role.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// Represents a KOMPASS user document from the Users collection.
@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String userId,
    required String name,
    required String email,
    required String role,
    @Default('') String profileImage,
    @Default('') String phoneNumber,
    @Default(false) bool isPhoneVerified,
    @Default('') String address,
    @Default('') String gender,
    int? age,
    @Default('') String emergencyContact,
    @Default('') String emergencyContactName,
    @Default(false) bool isEmergencyContactVerified,
    DateTime? createdAt,
  }) = _UserModel;

  const UserModel._();

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Convenience constructor from a Firestore DocumentSnapshot.
  static UserModel fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    int? parsedAge;
    if (data['age'] != null) {
      if (data['age'] is int) {
        parsedAge = data['age'] as int;
      } else if (data['age'] is num) {
        parsedAge = (data['age'] as num).toInt();
      } else if (data['age'] is String) {
        parsedAge = int.tryParse(data['age'] as String);
      }
    }
    return UserModel.fromJson({
      ...data,
      'userId': doc.id,
      'age': parsedAge,
      'createdAt': (data['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }

  /// Convert to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('userId');
    json['createdAt'] = createdAt != null
        ? Timestamp.fromDate(createdAt!)
        : FieldValue.serverTimestamp();
    return json;
  }

  /// Contact phone accessor
  String get contact => phoneNumber;

  /// Check if the user has an emergency contact configured
  bool get hasEmergencyContact => emergencyContact.trim().isNotEmpty;

  /// Check if the user has personal contact configured
  bool get hasContact => phoneNumber.trim().isNotEmpty;

  /// Check if the user has address configured
  bool get hasAddress => address.trim().isNotEmpty;

  /// Get the parsed UserRole enum.
  UserRole get userRole => UserRole.fromString(role);

  /// Check if the user is an admin.
  bool get isAdmin => userRole == UserRole.admin;

  /// Check if the user is a guide.
  bool get isGuide => userRole == UserRole.guide;

  /// Check if the user is a participant.
  bool get isParticipant => userRole == UserRole.participant;
}
