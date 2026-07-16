import 'dart:collection';

import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_pattern.dart';

final class ScheduleProfile {
  ScheduleProfile({
    required this.id,
    required this.name,
    required this.patternType,
    required this.anchorDate,
    required this.holidayOverridesEnabled,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.anchorWeekType,
    List<DayKind> cycleDays = const [],
    this.deletedAt,
  }) : cycleDays = UnmodifiableListView(List.of(cycleDays));

  final String id;
  final String name;
  final SchedulePatternType patternType;
  final CalendarDate anchorDate;
  final WeekType? anchorWeekType;
  final List<DayKind> cycleDays;
  final bool holidayOverridesEnabled;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  ScheduleProfile copyWith({
    String? id,
    String? name,
    SchedulePatternType? patternType,
    CalendarDate? anchorDate,
    WeekType? anchorWeekType,
    bool clearAnchorWeekType = false,
    List<DayKind>? cycleDays,
    bool? holidayOverridesEnabled,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) => ScheduleProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    patternType: patternType ?? this.patternType,
    anchorDate: anchorDate ?? this.anchorDate,
    anchorWeekType: clearAnchorWeekType
        ? null
        : anchorWeekType ?? this.anchorWeekType,
    cycleDays: cycleDays ?? this.cycleDays,
    holidayOverridesEnabled:
        holidayOverridesEnabled ?? this.holidayOverridesEnabled,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: clearDeletedAt ? null : deletedAt ?? this.deletedAt,
  );
}
