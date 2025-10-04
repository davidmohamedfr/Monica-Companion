import 'package:intl/intl.dart';

/// Utility class for formatting dates in dual format (relative + absolute)
class DateFormatter {
  DateFormatter._(); // Private constructor to prevent instantiation

  static const String _separator = ' • ';

  /// Formats a date as "relative time • absolute date"
  /// Example: "2 days ago • Oct 2, 2024"
  ///
  /// Returns empty string if date is null.
  /// The [now] parameter is used for testing and defaults to DateTime.now()
  static String formatDualDate(DateTime? date, {DateTime? now}) {
    if (date == null) return '';

    final DateTime currentTime = now ?? DateTime.now();
    final Duration difference = currentTime.difference(date);

    final String relative = _formatRelativeTime(difference);
    final String absolute = DateFormat('MMM d, y').format(date);

    return '$relative$_separator$absolute';
  }

  static String _formatRelativeTime(Duration difference) {
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final int weeks = (difference.inDays / 7).floor();
      return '$weeks ${_pluralize('week', weeks)} ago';
    } else if (difference.inDays < 365) {
      final int months = (difference.inDays / 30).floor();
      return '$months ${_pluralize('month', months)} ago';
    } else {
      final int years = (difference.inDays / 365).floor();
      return '$years ${_pluralize('year', years)} ago';
    }
  }

  static String _pluralize(String word, int count) {
    return count == 1 ? word : '${word}s';
  }
}
