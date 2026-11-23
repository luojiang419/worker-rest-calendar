import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/reminders/domain/reminder_preferences.dart';
import 'package:worker_rest_calendar/features/reminders/domain/reminder_scheduler.dart';
import 'package:worker_rest_calendar/features/reminders/domain/scheduled_reminder.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_override.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_engine.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_pattern.dart';

void main() {
  final anchor = CalendarDate(2026, 7, 13);
  final scheduler = ReminderScheduler(
    ScheduleEngine(
      pattern: AlternatingBigSmallWeekPattern(
        anchorDate: anchor,
        anchorWeekType: WeekType.big,
      ),
      manualOverrides: {
        CalendarDate(2026, 7, 18): DayOverride(kind: DayKind.adjustedWork),
      },
    ),
  );
  const preferences = ReminderPreferences(
    dailyNextDayEnabled: true,
    dailyNextDayTime: '20:00',
    adjustedWorkEnabled: true,
    adjustedWorkLeadDays: 1,
    weeklyPreviewEnabled: true,
    weeklyPreviewWeekday: DateTime.sunday,
    weeklyPreviewTime: '19:30',
    countdownEnabled: true,
  );

  test('生成未来 60 天四类通知且 ID 唯一稳定', () {
    final first = scheduler.build(
      preferences: preferences,
      nowLocal: DateTime(2026, 7, 13, 10),
    );
    final second = scheduler.build(
      preferences: preferences,
      nowLocal: DateTime(2026, 7, 13, 10),
    );

    expect(first.map((item) => item.type).toSet(), ReminderType.values.toSet());
    expect(first.map((item) => item.id).toSet(), hasLength(first.length));
    expect(first.map((item) => item.id), second.map((item) => item.id));
    expect(
      first.every(
        (item) => item.payload == 'restcalendar://date/${item.targetDate}',
      ),
      isTrue,
    );
  });

  test('调休上班按提前天数生成专门提醒', () {
    final plans = scheduler.build(
      preferences: preferences,
      nowLocal: DateTime(2026, 7, 13, 10),
    );
    final adjusted = plans.singleWhere(
      (item) =>
          item.type == ReminderType.adjustedWork &&
          item.targetDate == CalendarDate(2026, 7, 18),
    );

    expect(adjusted.moment.date, CalendarDate(2026, 7, 17));
    expect(adjusted.moment.hour, 20);
    expect(adjusted.title, '调休上班提醒');
    expect(adjusted.body, contains('别被周末骗了'));
  });

  test('周预览正确识别下一周为小周', () {
    final plans = scheduler.build(
      preferences: preferences,
      nowLocal: DateTime(2026, 7, 13, 10),
    );
    final weekly = plans.singleWhere(
      (item) =>
          item.type == ReminderType.weeklyPreview &&
          item.moment.date == CalendarDate(2026, 7, 19),
    );

    expect(weekly.targetDate, CalendarDate(2026, 7, 20));
    expect(weekly.title, '下周是小周');
    expect(weekly.body, contains('周六上班、周日休息'));
  });

  test('过滤已经过去的计划时间', () {
    final plans = scheduler.build(
      preferences: preferences,
      nowLocal: DateTime(2026, 7, 13, 21),
    );

    expect(
      plans.any((item) => item.moment.date == CalendarDate(2026, 7, 13)),
      isFalse,
    );
  });

  test('所有提醒关闭时计划为空', () {
    final plans = scheduler.build(
      preferences: const ReminderPreferences(adjustedWorkEnabled: false),
      nowLocal: DateTime(2026, 7, 13, 10),
    );

    expect(plans, isEmpty);
  });

  test('拒绝损坏时间和越界提前天数', () {
    expect(
      () => scheduler.build(
        preferences: preferences.copyWith(dailyNextDayTime: '25:00'),
        nowLocal: DateTime(2026, 7, 13, 10),
      ),
      throwsArgumentError,
    );
    expect(
      () => scheduler.build(
        preferences: preferences.copyWith(adjustedWorkLeadDays: 31),
        nowLocal: DateTime(2026, 7, 13, 10),
      ),
      throwsArgumentError,
    );
  });
}
