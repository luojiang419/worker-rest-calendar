import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/home/application/today_dashboard.dart';
import 'package:worker_rest_calendar/features/schedule/application/active_schedule_controller.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_override.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_engine.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_pattern.dart';

import '../../../helpers/test_models.dart';

void main() {
  ActiveScheduleState schedule({
    Map<CalendarDate, DayOverride> manualOverrides = const {},
  }) {
    final profile = testProfile().copyWith(
      anchorDate: CalendarDate(2026, 7, 13),
      anchorWeekType: WeekType.big,
    );
    return ActiveScheduleState(
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
  }

  test('大周剩余工作日不把今天和下次休息日计入', () {
    final dashboard = TodayDashboard.build(
      schedule(),
      CalendarDate(2026, 7, 14),
    );

    expect(dashboard.daysToNextRest, 4);
    expect(dashboard.nextRestDate, CalendarDate(2026, 7, 18));
    expect(dashboard.remainingWorkDaysBeforeNextRest, 3);
  });

  test('剩余工作日按手动覆盖后的最终排班统计', () {
    final dashboard = TodayDashboard.build(
      schedule(
        manualOverrides: {
          CalendarDate(2026, 7, 15): DayOverride(kind: DayKind.leave),
        },
      ),
      CalendarDate(2026, 7, 14),
    );

    expect(dashboard.nextRestDate, CalendarDate(2026, 7, 18));
    expect(dashboard.remainingWorkDaysBeforeNextRest, 2);
  });

  test('今天就是休息日时剩余工作日为零', () {
    final dashboard = TodayDashboard.build(
      schedule(),
      CalendarDate(2026, 7, 18),
    );

    expect(dashboard.daysToNextRest, 0);
    expect(dashboard.nextRestDate, CalendarDate(2026, 7, 18));
    expect(dashboard.remainingWorkDaysBeforeNextRest, 0);
  });
}
