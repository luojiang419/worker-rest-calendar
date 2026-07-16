import 'dart:collection';

import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_override.dart';
import 'package:worker_rest_calendar/features/schedule/domain/resolved_day.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_error.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_pattern.dart';

enum WorkdayBasis { planned, effective }

final class ScheduleEngine {
  ScheduleEngine({
    required this.pattern,
    Map<CalendarDate, DayOverride> holidayOverrides = const {},
    Map<CalendarDate, DayOverride> manualOverrides = const {},
  }) : holidayOverrides = UnmodifiableMapView(Map.of(holidayOverrides)),
       manualOverrides = UnmodifiableMapView(Map.of(manualOverrides)) {
    final invalidHolidayOverride = holidayOverrides.values.any(
      (override) =>
          override.kind != DayKind.adjustedWork &&
          override.kind != DayKind.adjustedRest,
    );
    if (invalidHolidayOverride) {
      throw ArgumentError.value(
        holidayOverrides,
        'holidayOverrides',
        '节假日覆盖只能是调休上班或调休休息',
      );
    }
  }

  final SchedulePattern pattern;
  final Map<CalendarDate, DayOverride> holidayOverrides;
  final Map<CalendarDate, DayOverride> manualOverrides;

  ResolvedDay resolve(CalendarDate date) {
    final plannedKind = pattern.plannedKind(date);
    final manualOverride = manualOverrides[date];
    final holidayOverride = holidayOverrides[date];
    final appliedOverride = manualOverride ?? holidayOverride;
    final source = manualOverride != null
        ? DayOverrideSource.manual
        : holidayOverride != null
        ? DayOverrideSource.holiday
        : null;

    return ResolvedDay(
      date: date,
      plannedKind: plannedKind,
      effectiveKind: appliedOverride?.kind ?? plannedKind,
      weekType: pattern.weekTypeFor(date),
      appliedOverrideSource: source,
      overtimeMinutes: appliedOverride?.overtimeMinutes ?? 0,
      note: appliedOverride?.note,
    );
  }

  int daysToNextRest(CalendarDate from, {int maxScanDays = 366}) {
    if (maxScanDays < 0) {
      throw ArgumentError.value(maxScanDays, 'maxScanDays', '不能小于 0');
    }

    for (var offset = 0; offset <= maxScanDays; offset++) {
      if (resolve(from.addDays(offset)).effectiveKind.isRest) {
        return offset;
      }
    }

    throw NoRestDayFound(from: from, maxScanDays: maxScanDays);
  }

  int consecutiveWorkDaysEndingOn(
    CalendarDate endingOn, {
    WorkdayBasis basis = WorkdayBasis.effective,
    int maxScanDays = 366,
  }) {
    if (maxScanDays <= 0) {
      throw ArgumentError.value(maxScanDays, 'maxScanDays', '必须大于 0');
    }

    var count = 0;
    for (var offset = 0; offset < maxScanDays; offset++) {
      if (!_isWorkday(endingOn.addDays(-offset), basis)) {
        return count;
      }
      count++;
    }

    if (_isWorkday(endingOn.addDays(-maxScanDays), basis)) {
      throw WorkStreakScanLimitExceeded(
        endingOn: endingOn,
        maxScanDays: maxScanDays,
      );
    }
    return count;
  }

  int longestConsecutiveWorkDays({
    required CalendarDate start,
    required CalendarDate end,
    WorkdayBasis basis = WorkdayBasis.effective,
  }) {
    if (start.compareTo(end) > 0) {
      throw ArgumentError('start 不能晚于 end');
    }

    var longest = 0;
    var current = 0;
    final totalDays = end.daysSince(start);
    for (var offset = 0; offset <= totalDays; offset++) {
      if (_isWorkday(start.addDays(offset), basis)) {
        current++;
        if (current > longest) {
          longest = current;
        }
      } else {
        current = 0;
      }
    }
    return longest;
  }

  bool _isWorkday(CalendarDate date, WorkdayBasis basis) {
    final resolved = resolve(date);
    return switch (basis) {
      WorkdayBasis.planned => resolved.plannedKind == DayKind.work,
      WorkdayBasis.effective => resolved.effectiveKind.isActualWork,
    };
  }
}
