/// Enum for participant status within a tour.
enum ParticipantStatus {
  invited('Invited'),
  active('Active'),
  removed('Removed'),
  left('Left');

  const ParticipantStatus(this.label);
  final String label;

  static ParticipantStatus fromString(String value) {
    return ParticipantStatus.values.firstWhere(
      (s) => s.label.toLowerCase() == value.toLowerCase(),
      orElse: () => ParticipantStatus.invited,
    );
  }
}
