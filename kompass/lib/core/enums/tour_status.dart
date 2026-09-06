/// Enum representing the lifecycle status of a tour.
enum TourStatus {
  draft('Draft'),
  upcoming('Upcoming'),
  active('Active'),
  completed('Completed'),
  cancelled('Cancelled');

  const TourStatus(this.label);
  final String label;

  static TourStatus fromString(String value) {
    return TourStatus.values.firstWhere(
      (s) => s.label.toLowerCase() == value.toLowerCase(),
      orElse: () => TourStatus.draft,
    );
  }
}
