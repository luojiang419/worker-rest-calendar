import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_pattern.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_profile.dart';
import 'package:worker_rest_calendar/features/schedule/domain/stored_day_override.dart';

ScheduleProfile testProfile({
  String id = 'profile-1',
  String name = '测试大小周',
  bool isActive = true,
  DateTime? updatedAt,
}) {
  final timestamp = updatedAt ?? DateTime.utc(2026, 7, 12, 8);
  return ScheduleProfile(
    id: id,
    name: name,
    patternType: SchedulePatternType.alternatingBigSmallWeek,
    anchorDate: CalendarDate(2026, 7, 6),
    anchorWeekType: WeekType.big,
    holidayOverridesEnabled: true,
    isActive: isActive,
    createdAt: DateTime.utc(2026, 7, 1),
    updatedAt: timestamp,
  );
}

StoredDayOverride testOverride({
  String id = 'override-1',
  String profileId = 'profile-1',
  CalendarDate? date,
  DayKind kind = DayKind.adjustedRest,
  DateTime? updatedAt,
}) {
  final timestamp = updatedAt ?? DateTime.utc(2026, 7, 12, 9);
  return StoredDayOverride(
    id: id,
    date: date ?? CalendarDate(2026, 7, 11),
    profileId: profileId,
    kind: kind,
    overtimeMinutes: 0,
    note: '测试覆盖',
    source: StoredOverrideSource.manual,
    createdAt: DateTime.utc(2026, 7, 12, 8),
    updatedAt: timestamp,
  );
}
