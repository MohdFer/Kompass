/// Enum representing user roles in the KOMPASS system.
enum UserRole {
  admin('Admin'),
  guide('Guide'),
  participant('Participant');

  const UserRole(this.label);
  final String label;

  /// Parse a role from a Firestore string value.
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.label.toLowerCase() == value.toLowerCase(),
      orElse: () => UserRole.participant,
    );
  }
}
