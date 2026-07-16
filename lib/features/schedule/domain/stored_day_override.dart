import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';

enum StoredOverrideSource { manual, imported }

final class StoredDayOverride {
  const StoredDayOverride({
    required this.id,
    required this.date,
    required this.profileId,
    required this.kind,
    required this.overtimeMinutes,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
    this.note,
    this.deletedAt,
  });

  final String id;
  final CalendarDate date;
  final String profileId;
  final DayKind kind;
  final int overtimeMinutes;
  final String? note;
  final StoredOverrideSource source;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  StoredDayOverride copyWith({
    DayKind? kind,
    int? overtimeMinutes,
    String? note,
    bool clearNote = false,
    StoredOverrideSource? source,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) => StoredDayOverride(
    id: id,
    date: date,
    profileId: profileId,
    kind: kind ?? this.kind,
    overtimeMinutes: overtimeMinutes ?? this.overtimeMinutes,
    note: clearNote ? null : note ?? this.note,
    source: source ?? this.source,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: clearDeletedAt ? null : deletedAt ?? this.deletedAt,
  );
}
