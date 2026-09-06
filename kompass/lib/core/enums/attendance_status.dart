/// Enum for attendance record status.
enum AttendanceStatus {
  present('Present'),
  absent('Absent'),
  late_('Late'),
  excused('Excused');

  const AttendanceStatus(this.label);
  final String label;

  static AttendanceStatus fromString(String value) {
    return AttendanceStatus.values.firstWhere(
      (s) => s.label.toLowerCase() == value.toLowerCase(),
      orElse: () => AttendanceStatus.absent,
    );
  }
}
