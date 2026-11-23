import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_override.dart';
import 'package:worker_rest_calendar/features/schedule/domain/resolved_day.dart';

final class DayPresentation {
  const DayPresentation({
    required this.date,
    required this.plannedKind,
    required this.effectiveKind,
    required this.label,
    required this.shortLabel,
    required this.weekType,
    required this.overtimeMinutes,
    required this.appliedOverrideSource,
    this.note,
  });

  factory DayPresentation.fromResolvedDay(ResolvedDay day) => DayPresentation(
    date: day.date,
    plannedKind: day.plannedKind,
    effectiveKind: day.effectiveKind,
    label: day.effectiveKind.fullLabel,
    shortLabel: day.effectiveKind.shortLabel,
    weekType: day.weekType,
    overtimeMinutes: day.overtimeMinutes,
    note: day.note,
    appliedOverrideSource: day.appliedOverrideSource,
  );

  final CalendarDate date;
  final DayKind plannedKind;
  final DayKind effectiveKind;
  final String label;
  final String shortLabel;
  final WeekType? weekType;
  final int overtimeMinutes;
  final String? note;
  final DayOverrideSource? appliedOverrideSource;

  bool get hasManualOverride =>
      appliedOverrideSource == DayOverrideSource.manual;
}

extension DayKindPresentation on DayKind {
  String get fullLabel => switch (this) {
    DayKind.work => '工作',
    DayKind.rest => '休息',
    DayKind.adjustedWork => '调休上班',
    DayKind.adjustedRest => '调休休息',
    DayKind.leave => '请假',
  };

  String get shortLabel => switch (this) {
    DayKind.work => '班',
    DayKind.rest => '休',
    DayKind.adjustedWork => '调班',
    DayKind.adjustedRest => '调休',
    DayKind.leave => '假',
  };
}
