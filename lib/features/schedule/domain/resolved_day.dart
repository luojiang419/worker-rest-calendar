import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_override.dart';

final class ResolvedDay {
  const ResolvedDay({
    required this.date,
    required this.plannedKind,
    required this.effectiveKind,
    required this.weekType,
    this.appliedOverrideSource,
    this.overtimeMinutes = 0,
    this.note,
  });

  final CalendarDate date;
  final DayKind plannedKind;
  final DayKind effectiveKind;
  final WeekType? weekType;
  final DayOverrideSource? appliedOverrideSource;
  final int overtimeMinutes;
  final String? note;
}
