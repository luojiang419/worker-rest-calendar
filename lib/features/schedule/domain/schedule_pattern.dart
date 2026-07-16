import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/core/date/calendar_math.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_error.dart';

enum SchedulePatternType {
  doubleRest,
  singleRest,
  alternatingBigSmallWeek,
  sixOnOneOff,
  twoOnTwoOff,
  customCycle,
}

sealed class SchedulePattern {
  const SchedulePattern();

  SchedulePatternType get type;

  DayKind plannedKind(CalendarDate date);

  WeekType? weekTypeFor(CalendarDate date) => null;
}

final class FixedWeeklyPattern extends SchedulePattern {
  const FixedWeeklyPattern.doubleRest()
    : type = SchedulePatternType.doubleRest,
      saturdayIsRest = true;

  const FixedWeeklyPattern.singleRest()
    : type = SchedulePatternType.singleRest,
      saturdayIsRest = false;

  @override
  final SchedulePatternType type;
  final bool saturdayIsRest;

  @override
  DayKind plannedKind(CalendarDate date) {
    if (date.weekday == DateTime.sunday) {
      return DayKind.rest;
    }
    if (saturdayIsRest && date.weekday == DateTime.saturday) {
      return DayKind.rest;
    }
    return DayKind.work;
  }
}

final class AlternatingBigSmallWeekPattern extends SchedulePattern {
  AlternatingBigSmallWeekPattern({
    required CalendarDate anchorDate,
    required this.anchorWeekType,
  }) : anchorMonday = anchorDate.monday;

  final CalendarDate anchorMonday;
  final WeekType anchorWeekType;

  @override
  SchedulePatternType get type => SchedulePatternType.alternatingBigSmallWeek;

  @override
  WeekType weekTypeFor(CalendarDate date) {
    final daysFromAnchor = date.monday.daysSince(anchorMonday);
    final weekOffset = floorDiv(daysFromAnchor, DateTime.daysPerWeek);
    return weekOffset.isEven ? anchorWeekType : anchorWeekType.opposite;
  }

  @override
  DayKind plannedKind(CalendarDate date) {
    if (date.weekday == DateTime.sunday) {
      return DayKind.rest;
    }
    if (date.weekday == DateTime.saturday &&
        weekTypeFor(date) == WeekType.big) {
      return DayKind.rest;
    }
    return DayKind.work;
  }
}

final class CycleSchedulePattern extends SchedulePattern {
  CycleSchedulePattern._({
    required this.anchorDate,
    required this.type,
    required List<DayKind> cycleDays,
  }) : cycleDays = List.unmodifiable(cycleDays) {
    if (cycleDays.isEmpty || cycleDays.length > 56) {
      throw const InvalidPattern('循环长度必须在 1–56 天之间');
    }
    if (cycleDays.any((kind) => !kind.isBaseKind)) {
      throw const InvalidPattern('基础循环只能包含工作或休息');
    }
    if (cycleDays.every((kind) => kind != DayKind.rest)) {
      throw const InvalidPattern('循环中必须至少包含一个休息日');
    }
  }

  factory CycleSchedulePattern.sixOnOneOff({
    required CalendarDate anchorDate,
  }) => CycleSchedulePattern._(
    anchorDate: anchorDate,
    type: SchedulePatternType.sixOnOneOff,
    cycleDays: const [
      DayKind.work,
      DayKind.work,
      DayKind.work,
      DayKind.work,
      DayKind.work,
      DayKind.work,
      DayKind.rest,
    ],
  );

  factory CycleSchedulePattern.twoOnTwoOff({
    required CalendarDate anchorDate,
  }) => CycleSchedulePattern._(
    anchorDate: anchorDate,
    type: SchedulePatternType.twoOnTwoOff,
    cycleDays: const [DayKind.work, DayKind.work, DayKind.rest, DayKind.rest],
  );

  factory CycleSchedulePattern.custom({
    required CalendarDate anchorDate,
    required List<DayKind> cycleDays,
  }) => CycleSchedulePattern._(
    anchorDate: anchorDate,
    type: SchedulePatternType.customCycle,
    cycleDays: cycleDays,
  );

  final CalendarDate anchorDate;

  @override
  final SchedulePatternType type;
  final List<DayKind> cycleDays;

  @override
  DayKind plannedKind(CalendarDate date) {
    final offset = date.daysSince(anchorDate);
    final index = positiveModulo(offset, cycleDays.length);
    return cycleDays[index];
  }
}
