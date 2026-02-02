import 'package:intl/intl.dart';

class DateUtils {
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  static String getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference == -1) return 'Yesterday';
    if (difference > 0 && difference <= 7) return 'In $difference days';
    if (difference < 0 && difference >= -7) return '${-difference} days ago';
    
    return formatDate(date);
  }

  static DateTime getNextCycleDate(DateTime startDate, CycleType cycleType, int cycleDuration, int cycleNumber) {
    switch (cycleType) {
      case CycleType.weekly:
        return startDate.add(Duration(days: 7 * cycleNumber));
      case CycleType.monthly:
        return DateTime(
          startDate.year,
          startDate.month + cycleNumber,
          startDate.day,
        );
      case CycleType.custom:
        return startDate.add(Duration(days: cycleDuration * cycleNumber));
    }
  }

  static int getDaysBetween(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}

enum CycleType { weekly, monthly, custom }