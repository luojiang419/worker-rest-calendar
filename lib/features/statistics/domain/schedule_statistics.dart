import 'dart:collection';

import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_engine.dart';

final class ScheduleStatisticsCalculator {
  const ScheduleStatisticsCalculator(this.engine);

  final ScheduleEngine engine;

  MonthlyScheduleStatistics calculateMonth({
    required int year,
    required int month,
  }) {
    if (month < 1 || month > 12) {
      throw ArgumentError.value(month, 'month', '必须在 1–12 之间');
    }
    final start = CalendarDate(year, month, 1);
    final dayCount = DateTime.utc(year, month + 1, 0).day;
    final end = start.addDays(dayCount - 1);
    var plannedWorkDays = 0;
    var actualWorkDays = 0;
    var restDays = 0;
    var leaveDays = 0;
    var adjustedWorkDays = 0;
    var adjustedRestDays = 0;

    for (var offset = 0; offset < dayCount; offset++) {
      final day = engine.resolve(start.addDays(offset));
      if (day.plannedKind == DayKind.work) {
        plannedWorkDays++;
      }
      if (day.effectiveKind.isActualWork) {
        actualWorkDays++;
      }
      if (day.effectiveKind.isRest) {
        restDays++;
      }
      switch (day.effectiveKind) {
        case DayKind.leave:
          leaveDays++;
        case DayKind.adjustedWork:
          adjustedWorkDays++;
        case DayKind.adjustedRest:
          adjustedRestDays++;
        case DayKind.work:
        case DayKind.rest:
          break;
      }
    }

    return MonthlyScheduleStatistics(
      year: year,
      month: month,
      dayCount: dayCount,
      plannedWorkDays: plannedWorkDays,
      actualWorkDays: actualWorkDays,
      restDays: restDays,
      leaveDays: leaveDays,
      adjustedWorkDays: adjustedWorkDays,
      adjustedRestDays: adjustedRestDays,
      longestPlannedWorkStreak: engine.longestConsecutiveWorkDays(
        start: start,
        end: end,
        basis: WorkdayBasis.planned,
      ),
      longestActualWorkStreak: engine.longestConsecutiveWorkDays(
        start: start,
        end: end,
        basis: WorkdayBasis.effective,
      ),
    );
  }

  CurrentWorkStreak calculateCurrentStreak(CalendarDate endingOn) =>
      CurrentWorkStreak(
        endingOn: endingOn,
        plannedDays: engine.consecutiveWorkDaysEndingOn(
          endingOn,
          basis: WorkdayBasis.planned,
        ),
        actualDays: engine.consecutiveWorkDaysEndingOn(
          endingOn,
          basis: WorkdayBasis.effective,
        ),
      );

  AnnualScheduleHeatmap calculateYear(int year) {
    final start = CalendarDate(year, 1, 1);
    final dayCount = DateTime.utc(
      year + 1,
      1,
      1,
    ).difference(DateTime.utc(year, 1, 1)).inDays;
    return AnnualScheduleHeatmap(
      year: year,
      days: List.generate(dayCount, (index) {
        final resolved = engine.resolve(start.addDays(index));
        return ScheduleHeatmapDay(
          date: resolved.date,
          effectiveKind: resolved.effectiveKind,
        );
      }, growable: false),
    );
  }
}

final class MonthlyScheduleStatistics {
  const MonthlyScheduleStatistics({
    required this.year,
    required this.month,
    required this.dayCount,
    required this.plannedWorkDays,
    required this.actualWorkDays,
    required this.restDays,
    required this.leaveDays,
    required this.adjustedWorkDays,
    required this.adjustedRestDays,
    required this.longestPlannedWorkStreak,
    required this.longestActualWorkStreak,
  });

  final int year;
  final int month;
  final int dayCount;
  final int plannedWorkDays;
  final int actualWorkDays;
  final int restDays;
  final int leaveDays;
  final int adjustedWorkDays;
  final int adjustedRestDays;
  final int longestPlannedWorkStreak;
  final int longestActualWorkStreak;
}

final class CurrentWorkStreak {
  const CurrentWorkStreak({
    required this.endingOn,
    required this.plannedDays,
    required this.actualDays,
  });

  final CalendarDate endingOn;
  final int plannedDays;
  final int actualDays;
}

final class AnnualScheduleHeatmap {
  AnnualScheduleHeatmap({
    required this.year,
    required List<ScheduleHeatmapDay> days,
  }) : days = UnmodifiableListView(days);

  final int year;
  final List<ScheduleHeatmapDay> days;
}

final class ScheduleHeatmapDay {
  const ScheduleHeatmapDay({required this.date, required this.effectiveKind});

  final CalendarDate date;
  final DayKind effectiveKind;

  bool get isRest => effectiveKind.isRest;
  bool get isActualWork => effectiveKind.isActualWork;
}
