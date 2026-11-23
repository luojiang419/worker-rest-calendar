import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_override.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_engine.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_pattern.dart';
import 'package:worker_rest_calendar/features/statistics/domain/schedule_statistics.dart';

void main() {
  final engine = ScheduleEngine(
    pattern: const FixedWeeklyPattern.doubleRest(),
    manualOverrides: {
      CalendarDate(2026, 7, 4): DayOverride(kind: DayKind.adjustedWork),
      CalendarDate(2026, 7, 6): DayOverride(kind: DayKind.leave),
      CalendarDate(2026, 7, 7): DayOverride(kind: DayKind.adjustedRest),
    },
  );
  final calculator = ScheduleStatisticsCalculator(engine);

  test('月度统计严格区分计划、实际、休息、请假与两类调休', () {
    final statistics = calculator.calculateMonth(year: 2026, month: 7);

    expect(statistics.dayCount, 31);
    expect(statistics.plannedWorkDays, 23);
    expect(statistics.actualWorkDays, 22);
    expect(statistics.restDays, 8);
    expect(statistics.leaveDays, 1);
    expect(statistics.adjustedWorkDays, 1);
    expect(statistics.adjustedRestDays, 1);
    expect(statistics.longestPlannedWorkStreak, 5);
    expect(statistics.longestActualWorkStreak, 5);
  });

  test('请假中断实际连续工作但不改变计划连续工作', () {
    final streak = calculator.calculateCurrentStreak(CalendarDate(2026, 7, 6));

    expect(streak.plannedDays, 1);
    expect(streak.actualDays, 0);
  });

  test('年度热力图覆盖普通年与闰年所有日期', () {
    final normalYear = calculator.calculateYear(2026);
    final leapYear = calculator.calculateYear(2024);

    expect(normalYear.days, hasLength(365));
    expect(normalYear.days.first.date, CalendarDate(2026, 1, 1));
    expect(normalYear.days.last.date, CalendarDate(2026, 12, 31));
    expect(leapYear.days, hasLength(366));
    expect(
      leapYear.days.any((day) => day.date == CalendarDate(2024, 2, 29)),
      isTrue,
    );
  });

  test('拒绝无效月份', () {
    expect(
      () => calculator.calculateMonth(year: 2026, month: 13),
      throwsArgumentError,
    );
  });
}
