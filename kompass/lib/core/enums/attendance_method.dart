/// Enum for attendance check-in methods.
enum AttendanceMethod {
  qr('QR'),
  manual('Manual');

  const AttendanceMethod(this.label);
  final String label;

  static AttendanceMethod fromString(String value) {
    return AttendanceMethod.values.firstWhere(
      (m) => m.label.toLowerCase() == value.toLowerCase(),
      orElse: () => AttendanceMethod.manual,
    );
  }
}
