import 'package:intl/intl.dart';

abstract final class DateUtils {
  static String formatDate(DateTime date) => DateFormat('MMM d, yyyy').format(date);
  static String formatTime(DateTime date) => DateFormat('h:mm a').format(date);
  static String formatShort(DateTime date) => DateFormat('MMM d').format(date);
  static String formatDay(DateTime date) => DateFormat('EEEE').format(date);
  static String formatMonth(DateTime date) => DateFormat('MMMM yyyy').format(date);
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatShort(date);
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime startOfWeek(DateTime date) {
    final weekday = date.weekday;
    return startOfDay(date.subtract(Duration(days: weekday - 1)));
  }
}
