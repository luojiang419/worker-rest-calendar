import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/core/date/date_labels.dart';
import 'package:worker_rest_calendar/features/reminders/domain/reminder_preferences.dart';
import 'package:worker_rest_calendar/features/reminders/domain/scheduled_reminder.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_engine.dart';

final class ReminderScheduler {
  const ReminderScheduler(this.engine);

  final ScheduleEngine engine;

  List<ScheduledReminder> build({
    required ReminderPreferences preferences,
    required DateTime nowLocal,
    int horizonDays = 60,
  }) {
    if (horizonDays <= 0) {
      throw ArgumentError.value(horizonDays, 'horizonDays', '必须大于 0');
    }
    _validatePreferences(preferences);
    final today = CalendarDate.fromDateTime(nowLocal);
    final nowMoment = ReminderMoment(
      date: today,
      hour: nowLocal.hour,
      minute: nowLocal.minute,
    );
    final dailyTime = _parseTime(preferences.dailyNextDayTime);
    final weeklyTime = _parseTime(preferences.weeklyPreviewTime);
    final reminders = <ScheduledReminder>[];

    for (var offset = 0; offset < horizonDays; offset++) {
      final scheduleDate = today.addDays(offset);
      if (preferences.dailyNextDayEnabled) {
        final targetDate = scheduleDate.addDays(1);
        final target = engine.resolve(targetDate);
        _addIfFuture(
          reminders,
          nowMoment,
          ScheduledReminder(
            id: stableReminderId(ReminderType.nextDayStatus, scheduleDate),
            type: ReminderType.nextDayStatus,
            moment: _moment(scheduleDate, dailyTime),
            targetDate: targetDate,
            title: '明天${_kindLabel(target.effectiveKind)}',
            body:
                '${targetDate.monthDayLabel} ${targetDate.weekdayLabel}，${_dayMessage(target.effectiveKind)}',
            payload: _payload(targetDate),
          ),
        );
      }

      if (preferences.adjustedWorkEnabled) {
        final targetDate = scheduleDate.addDays(
          preferences.adjustedWorkLeadDays,
        );
        if (engine.resolve(targetDate).effectiveKind == DayKind.adjustedWork) {
          _addIfFuture(
            reminders,
            nowMoment,
            ScheduledReminder(
              id: stableReminderId(ReminderType.adjustedWork, scheduleDate),
              type: ReminderType.adjustedWork,
              moment: _moment(scheduleDate, dailyTime),
              targetDate: targetDate,
              title: '调休上班提醒',
              body:
                  '${targetDate.monthDayLabel} ${targetDate.weekdayLabel}是调休上班日，别被周末骗了。',
              payload: _payload(targetDate),
            ),
          );
        }
      }

      if (preferences.weeklyPreviewEnabled &&
          scheduleDate.weekday == preferences.weeklyPreviewWeekday) {
        final nextMonday = scheduleDate.monday.addDays(7);
        final weekType = engine.resolve(nextMonday).weekType;
        final restDays = List.generate(
          7,
          (index) => engine.resolve(nextMonday.addDays(index)),
        ).where((day) => day.effectiveKind.isRest).length;
        _addIfFuture(
          reminders,
          nowMoment,
          ScheduledReminder(
            id: stableReminderId(ReminderType.weeklyPreview, scheduleDate),
            type: ReminderType.weeklyPreview,
            moment: _moment(scheduleDate, weeklyTime),
            targetDate: nextMonday,
            title: weekType == null
                ? '下周安排'
                : '下周是${weekType == WeekType.big ? '大周' : '小周'}',
            body: weekType == WeekType.big
                ? '周六、周日休息，共 $restDays 个休息日。'
                : weekType == WeekType.small
                ? '周六上班、周日休息，共 $restDays 个休息日。'
                : '下周共有 $restDays 个休息日。',
            payload: _payload(nextMonday),
          ),
        );
      }

      if (preferences.countdownEnabled) {
        final daysToRest = engine.daysToNextRest(scheduleDate);
        if (daysToRest > 0) {
          final nextRest = scheduleDate.addDays(daysToRest);
          _addIfFuture(
            reminders,
            nowMoment,
            ScheduledReminder(
              id: stableReminderId(ReminderType.countdown, scheduleDate),
              type: ReminderType.countdown,
              moment: _moment(scheduleDate, dailyTime),
              targetDate: nextRest,
              title: '再上 $daysToRest 天班',
              body:
                  '下一休息日是 ${nextRest.monthDayLabel} ${nextRest.weekdayLabel}。',
              payload: _payload(nextRest),
            ),
          );
        }
      }
    }

    reminders.sort((left, right) => left.moment.compareTo(right.moment));
    return List.unmodifiable(reminders);
  }

  int stableReminderId(ReminderType type, CalendarDate date) =>
      (type.index + 1) * 100000000 +
      date.year * 10000 +
      date.month * 100 +
      date.day;

  void _addIfFuture(
    List<ScheduledReminder> reminders,
    ReminderMoment now,
    ScheduledReminder candidate,
  ) {
    if (candidate.moment.compareTo(now) > 0) {
      reminders.add(candidate);
    }
  }

  ReminderMoment _moment(CalendarDate date, ({int hour, int minute}) time) =>
      ReminderMoment(date: date, hour: time.hour, minute: time.minute);

  ({int hour, int minute}) _parseTime(String value) {
    final match = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(value);
    if (match == null) {
      throw FormatException('提醒时间必须使用 HH:mm 格式', value);
    }
    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    ReminderMoment(date: CalendarDate(2000, 1, 1), hour: hour, minute: minute);
    return (hour: hour, minute: minute);
  }

  void _validatePreferences(ReminderPreferences preferences) {
    if (preferences.adjustedWorkLeadDays < 0 ||
        preferences.adjustedWorkLeadDays > 30) {
      throw ArgumentError.value(
        preferences.adjustedWorkLeadDays,
        'adjustedWorkLeadDays',
        '必须在 0–30 之间',
      );
    }
    if (preferences.weeklyPreviewWeekday < DateTime.monday ||
        preferences.weeklyPreviewWeekday > DateTime.sunday) {
      throw ArgumentError.value(
        preferences.weeklyPreviewWeekday,
        'weeklyPreviewWeekday',
        '必须在周一至周日之间',
      );
    }
  }

  String _payload(CalendarDate date) => 'restcalendar://date/$date';

  String _dayMessage(DayKind kind) => switch (kind) {
    DayKind.work => '正常上班。',
    DayKind.rest => '可以安心休息。',
    DayKind.adjustedWork => '是调休上班日。',
    DayKind.adjustedRest => '是调休休息日。',
    DayKind.leave => '已记录请假。',
  };

  String _kindLabel(DayKind kind) => switch (kind) {
    DayKind.work => '工作',
    DayKind.rest => '休息',
    DayKind.adjustedWork => '调休上班',
    DayKind.adjustedRest => '调休休息',
    DayKind.leave => '请假',
  };
}
