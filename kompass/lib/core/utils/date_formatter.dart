/// Date and time formatting utilities.
library;

import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final _dateFormat = DateFormat('MMM dd, yyyy');
  static final _timeFormat = DateFormat('hh:mm a');
  static final _dateTimeFormat = DateFormat('MMM dd, yyyy • hh:mm a');
  static final _shortDateFormat = DateFormat('dd/MM/yy');
  static final _dayFormat = DateFormat('EEEE, MMMM dd');

  /// Formats a DateTime to "Jan 01, 2026".
  static String formatDate(DateTime date) => _dateFormat.format(date);

  /// Formats a DateTime to "02:30 PM".
  static String formatTime(DateTime date) => _timeFormat.format(date);

  /// Formats a DateTime to "Jan 01, 2026 • 02:30 PM".
  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);

  /// Formats a DateTime to "01/01/26".
  static String formatShortDate(DateTime date) => _shortDateFormat.format(date);

  /// Formats a DateTime to "Monday, January 01".
  static String formatDayDate(DateTime date) => _dayFormat.format(date);

  /// Returns a human-readable relative time (e.g., "2 hours ago", "just now").
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) return 'just now';
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    }
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return formatDate(date);
  }

  /// Returns duration between two dates as "X days".
  static String tourDuration(DateTime start, DateTime end) {
    final days = end.difference(start).inDays;
    if (days == 0) return '1 day';
    return '$days days';
  }
}
