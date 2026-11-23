import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/desktop_widget/domain/desktop_widget_snapshot.dart';
import 'package:worker_rest_calendar/features/schedule/application/active_schedule_controller.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_override.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_engine.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_pattern.dart';

import '../../../helpers/test_models.dart';

void main() {
  test('生成今日、下次休息、周节奏和 6 周月历快照', () {
    final profile = testProfile();
    final schedule = ActiveScheduleState(
      profile: profile,
      engine: ScheduleEngine(
        pattern: AlternatingBigSmallWeekPattern(
          anchorDate: profile.anchorDate,
          anchorWeekType: profile.anchorWeekType!,
        ),
      ),
      manualOverrides: const [],
      holidayOverrides: const [],
    );

    final snapshot = DesktopWidgetSnapshot.build(
      schedule,
      CalendarDate(2026, 7, 13),
    );

    expect(snapshot.today.effectiveKind, DayKind.work);
    expect(snapshot.currentWeekType, WeekType.small);
    expect(snapshot.daysToNextRest, 6);
    expect(snapshot.nextRestDate, CalendarDate(2026, 7, 19));
    expect(snapshot.weekDays, hasLength(7));
    expect(snapshot.weekDays.first.date.weekday, DateTime.monday);
    expect(snapshot.monthDays, hasLength(42));
    expect(snapshot.monthDays.first.date, CalendarDate(2026, 6, 29));
    expect(snapshot.remainingWeekWorkDays, 5);
    expect(snapshot.remainingMonthWorkDays, 15);
  });

  test('剩余工作日从明天起按最终排班统计并在月末归零', () {
    final profile = testProfile();
    ActiveScheduleState schedule({
      Map<CalendarDate, DayOverride> manualOverrides = const {},
    }) => ActiveScheduleState(
      profile: profile,
      engine: ScheduleEngine(
        pattern: AlternatingBigSmallWeekPattern(
          anchorDate: profile.anchorDate,
          anchorWeekType: profile.anchorWeekType!,
        ),
        manualOverrides: manualOverrides,
      ),
      manualOverrides: const [],
      holidayOverrides: const [],
    );

    final adjusted = DesktopWidgetSnapshot.build(
      schedule(
        manualOverrides: {
          CalendarDate(2026, 7, 14): DayOverride(kind: DayKind.leave),
          CalendarDate(2026, 7, 15): DayOverride(kind: DayKind.adjustedRest),
          CalendarDate(2026, 7, 19): DayOverride(kind: DayKind.adjustedWork),
        },
      ),
      CalendarDate(2026, 7, 13),
    );
    expect(adjusted.remainingWeekWorkDays, 4);
    expect(adjusted.remainingMonthWorkDays, 14);

    final monthEnd = DesktopWidgetSnapshot.build(
      schedule(),
      CalendarDate(2026, 7, 31),
    );
    expect(monthEnd.remainingWeekWorkDays, 1);
    expect(monthEnd.remainingMonthWorkDays, 0);
  });
}
