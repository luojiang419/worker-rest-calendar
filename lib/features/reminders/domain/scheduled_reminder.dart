import 'package:worker_rest_calendar/core/date/calendar_date.dart';

enum ReminderType { nextDayStatus, adjustedWork, weeklyPreview, countdown }

final class ReminderMoment implements Comparable<ReminderMoment> {
  ReminderMoment({
    required this.date,
    required this.hour,
    required this.minute,
  }) {
    if (hour < 0 || hour > 23) {
      throw ArgumentError.value(hour, 'hour', '必须在 0–23 之间');
    }
    if (minute < 0 || minute > 59) {
      throw ArgumentError.value(minute, 'minute', '必须在 0–59 之间');
    }
  }

  final CalendarDate date;
  final int hour;
  final int minute;

  @override
  int compareTo(ReminderMoment other) {
    final dateResult = date.compareTo(other.date);
    if (dateResult != 0) {
      return dateResult;
    }
    final hourResult = hour.compareTo(other.hour);
    return hourResult != 0 ? hourResult : minute.compareTo(other.minute);
  }
}

final class ScheduledReminder {
  const ScheduledReminder({
    required this.id,
    required this.type,
    required this.moment,
    required this.targetDate,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final ReminderType type;
  final ReminderMoment moment;
  final CalendarDate targetDate;
  final String title;
  final String body;
  final String payload;
}
