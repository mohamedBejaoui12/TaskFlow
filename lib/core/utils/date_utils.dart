import 'package:intl/intl.dart';

class AppDateUtils {
  static String humanDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd MMM yyyy').format(date);
  }

  static bool isDueToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return now.year == date.year && now.month == date.month && now.day == date.day;
  }

  static bool isOverdue(DateTime? date) {
    if (date == null) return false;
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedDue = DateTime(date.year, date.month, date.day);
    return normalizedDue.isBefore(normalizedToday);
  }
}
