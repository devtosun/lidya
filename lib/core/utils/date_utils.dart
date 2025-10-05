import 'package:intl/intl.dart';

class ChartDateUtils {
  ChartDateUtils._();

  /// Format date based on time range
  static String formatByRange(DateTime date, Duration visibleRange) {
    if (visibleRange.inDays > 365) {
      return DateFormat('MMM yyyy').format(date);
    } else if (visibleRange.inDays > 90) {
      return DateFormat('MMM d').format(date);
    } else if (visibleRange.inDays > 30) {
      return DateFormat('MMM d').format(date);
    } else if (visibleRange.inDays > 7) {
      return DateFormat('MMM d').format(date);
    } else if (visibleRange.inHours > 24) {
      return DateFormat('MMM d HH:mm').format(date);
    } else {
      return DateFormat('HH:mm').format(date);
    }
  }

  /// Format time for axis labels
  static String formatTimeAxis(DateTime date, Duration interval) {
    if (interval.inDays >= 365) {
      return DateFormat('yyyy').format(date);
    } else if (interval.inDays >= 30) {
      return DateFormat('MMM yyyy').format(date);
    } else if (interval.inDays >= 1) {
      return DateFormat('MMM d').format(date);
    } else if (interval.inHours >= 1) {
      return DateFormat('HH:mm').format(date);
    } else {
      return DateFormat('HH:mm:ss').format(date);
    }
  }

  /// Get optimal time interval based on visible duration
  static Duration calculateOptimalInterval(Duration visibleDuration) {
    if (visibleDuration.inDays > 365 * 5) {
      return const Duration(days: 365);
    } else if (visibleDuration.inDays > 365) {
      return const Duration(days: 90);
    } else if (visibleDuration.inDays > 90) {
      return const Duration(days: 30);
    } else if (visibleDuration.inDays > 30) {
      return const Duration(days: 7);
    } else if (visibleDuration.inDays > 7) {
      return const Duration(days: 1);
    } else if (visibleDuration.inHours > 24) {
      return const Duration(hours: 4);
    } else if (visibleDuration.inHours > 6) {
      return const Duration(hours: 1);
    } else {
      return const Duration(minutes: 15);
    }
  }

  /// Round date to interval
  static DateTime roundToInterval(DateTime date, Duration interval) {
    final millisSinceEpoch = date.millisecondsSinceEpoch;
    final intervalMillis = interval.inMilliseconds;
    final rounded = (millisSinceEpoch / intervalMillis).round() * intervalMillis;
    return DateTime.fromMillisecondsSinceEpoch(rounded);
  }

  /// Get time steps for grid
  static List<DateTime> getTimeSteps(
    DateTime start,
    DateTime end,
    Duration interval,
  ) {
    final steps = <DateTime>[];
    DateTime current = roundToInterval(start, interval);

    while (current.isBefore(end)) {
      if (current.isAfter(start)) {
        steps.add(current);
      }
      current = current.add(interval);
    }

    return steps;
  }

  /// Check if date is trading day (Monday-Friday)
  static bool isTradingDay(DateTime date) {
    return date.weekday >= DateTime.monday && date.weekday <= DateTime.friday;
  }

  /// Get next trading day
  static DateTime nextTradingDay(DateTime date) {
    DateTime next = date.add(const Duration(days: 1));
    while (!isTradingDay(next)) {
      next = next.add(const Duration(days: 1));
    }
    return next;
  }

  /// Get previous trading day
  static DateTime previousTradingDay(DateTime date) {
    DateTime prev = date.subtract(const Duration(days: 1));
    while (!isTradingDay(prev)) {
      prev = prev.subtract(const Duration(days: 1));
    }
    return prev;
  }

  /// Format duration as human readable
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }
}