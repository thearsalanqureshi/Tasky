import 'package:intl/intl.dart';

class DateHelper {
  const DateHelper._();

  static String formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat.jm().format(date);
  }

  static String formatDateTime(DateTime date) {
    return '${formatDate(date)} ${formatTime(date)}';
  }

  static String formatReminderDateTime(DateTime date) {
    final today = DateTime.now();
    final reminderDay = DateTime(date.year, date.month, date.day);
    final todayDay = DateTime(today.year, today.month, today.day);
    final tomorrowDay = todayDay.add(const Duration(days: 1));

    if (_isSameDay(reminderDay, todayDay)) {
      return 'Today at ${formatTime(date)}';
    }
    if (_isSameDay(reminderDay, tomorrowDay)) {
      return 'Tomorrow at ${formatTime(date)}';
    }
    return '${formatDate(date)} at ${formatTime(date)}';
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
