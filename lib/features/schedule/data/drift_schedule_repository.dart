import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:worker_rest_calendar/core/database/app_database.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/schedule/application/schedule_repository.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_pattern.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_profile.dart';
import 'package:worker_rest_calendar/features/schedule/domain/stored_day_override.dart';
import 'package:worker_rest_calendar/features/schedule/domain/stored_holiday_override.dart';

final class DriftScheduleRepository implements ScheduleRepository {
  const DriftScheduleRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<ScheduleProfile?> watchActiveProfile() {
    final query = _database.select(_database.scheduleProfiles)
      ..where((table) => table.isActive.equals(true) & table.deletedAt.isNull())
      ..limit(1);
    return query.watchSingleOrNull().distinct().map(
      (row) => row == null ? null : _profileFromRow(row),
    );
  }

  @override
  Future<ScheduleProfile?> getActiveProfile() async {
    final query = _database.select(_database.scheduleProfiles)
      ..where((table) => table.isActive.equals(true) & table.deletedAt.isNull())
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row == null ? null : _profileFromRow(row);
  }

  @override
  Future<List<ScheduleProfile>> getProfiles({
    bool includeDeleted = false,
  }) async {
    final query = _database.select(_database.scheduleProfiles);
    if (!includeDeleted) {
      query.where((table) => table.deletedAt.isNull());
    }
    query.orderBy([(table) => OrderingTerm.desc(table.updatedAt)]);
    return (await query.get()).map(_profileFromRow).toList(growable: false);
  }

  @override
  Future<ScheduleProfile?> getProfile(String id) async {
    final query = _database.select(_database.scheduleProfiles)
      ..where((table) => table.id.equals(id));
    final row = await query.getSingleOrNull();
    return row == null ? null : _profileFromRow(row);
  }

  @override
  Future<void> saveProfile(ScheduleProfile profile) {
    return _database.transaction(() async {
      if (profile.isActive && profile.deletedAt == null) {
        await _database
            .update(_database.scheduleProfiles)
            .write(const ScheduleProfilesCompanion(isActive: Value(false)));
      }
      await _database
          .into(_database.scheduleProfiles)
          .insertOnConflictUpdate(_profileToCompanion(profile));
    });
  }

  @override
  Future<void> setActiveProfile(String id, {required DateTime updatedAt}) {
    return _database.transaction(() async {
      final targetQuery = _database.select(_database.scheduleProfiles)
        ..where((table) => table.id.equals(id) & table.deletedAt.isNull());
      if (await targetQuery.getSingleOrNull() == null) {
        throw StateError('无法激活不存在或已删除的班制：$id');
      }

      await _database
          .update(_database.scheduleProfiles)
          .write(const ScheduleProfilesCompanion(isActive: Value(false)));
      await (_database.update(
        _database.scheduleProfiles,
      )..where((table) => table.id.equals(id))).write(
        ScheduleProfilesCompanion(
          isActive: const Value(true),
          updatedAt: Value(updatedAt),
        ),
      );
    });
  }

  @override
  Future<void> softDeleteProfile(String id, {required DateTime deletedAt}) {
    return (_database.update(
      _database.scheduleProfiles,
    )..where((table) => table.id.equals(id))).write(
      ScheduleProfilesCompanion(
        isActive: const Value(false),
        updatedAt: Value(deletedAt),
        deletedAt: Value(deletedAt),
      ),
    );
  }

  @override
  Future<List<StoredDayOverride>> getDayOverrides(
    String profileId, {
    bool includeDeleted = false,
  }) async {
    final query = _database.select(_database.dayOverrides)
      ..where((table) => table.profileId.equals(profileId));
    if (!includeDeleted) {
      query.where((table) => table.deletedAt.isNull());
    }
    query.orderBy([(table) => OrderingTerm.asc(table.date)]);
    return (await query.get()).map(_overrideFromRow).toList(growable: false);
  }

  @override
  Future<void> saveDayOverride(StoredDayOverride override) {
    return _database.transaction(() async {
      final profileQuery = _database.select(_database.scheduleProfiles)
        ..where(
          (table) =>
              table.id.equals(override.profileId) & table.deletedAt.isNull(),
        );
      if (await profileQuery.getSingleOrNull() == null) {
        throw StateError('无法为不存在或已删除的班制保存日期覆盖');
      }
      final existingQuery = _database.select(_database.dayOverrides)
        ..where(
          (table) =>
              table.profileId.equals(override.profileId) &
              table.date.equals(override.date.toString()),
        );
      final existing = await existingQuery.getSingleOrNull();
      if (existing != null && existing.id != override.id) {
        await (_database.delete(
          _database.dayOverrides,
        )..where((table) => table.id.equals(existing.id))).go();
      }
      await _database
          .into(_database.dayOverrides)
          .insertOnConflictUpdate(_overrideToCompanion(override));
    });
  }

  @override
  Future<void> softDeleteDayOverride({
    required String profileId,
    required CalendarDate date,
    required DateTime deletedAt,
  }) {
    return (_database.update(_database.dayOverrides)..where(
          (table) =>
              table.profileId.equals(profileId) &
              table.date.equals(date.toString()),
        ))
        .write(
          DayOverridesCompanion(
            updatedAt: Value(deletedAt),
            deletedAt: Value(deletedAt),
          ),
        );
  }

  @override
  Future<List<StoredHolidayOverride>> getHolidayOverrides(String region) async {
    final query = _database.select(_database.holidayOverrides)
      ..where((table) => table.region.equals(region))
      ..orderBy([(table) => OrderingTerm.asc(table.date)]);
    return (await query.get())
        .map(
          (row) => StoredHolidayOverride(
            date: CalendarDate.parse(row.date),
            kind: DayKind.values.byName(row.kind),
            title: row.title,
            region: row.region,
            dataVersion: row.dataVersion,
            updatedAt: row.updatedAt.toUtc(),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> saveHolidayOverrides(List<StoredHolidayOverride> overrides) {
    return _database.transaction(() async {
      for (final override in overrides) {
        await _database
            .into(_database.holidayOverrides)
            .insertOnConflictUpdate(
              HolidayOverridesCompanion.insert(
                date: override.date.toString(),
                kind: override.kind.name,
                title: override.title,
                region: override.region,
                dataVersion: override.dataVersion,
                updatedAt: override.updatedAt,
              ),
            );
      }
    });
  }

  ScheduleProfile _profileFromRow(ScheduleProfileRow row) {
    final decodedCycle = jsonDecode(row.cycleDaysJson) as List<dynamic>;
    return ScheduleProfile(
      id: row.id,
      name: row.name,
      patternType: SchedulePatternType.values.byName(row.patternType),
      anchorDate: CalendarDate.parse(row.anchorDate),
      anchorWeekType: row.anchorWeekType == null
          ? null
          : WeekType.values.byName(row.anchorWeekType!),
      cycleDays: decodedCycle
          .cast<String>()
          .map(DayKind.values.byName)
          .toList(growable: false),
      holidayOverridesEnabled: row.holidayOverridesEnabled,
      isActive: row.isActive,
      createdAt: row.createdAt.toUtc(),
      updatedAt: row.updatedAt.toUtc(),
      deletedAt: row.deletedAt?.toUtc(),
    );
  }

  ScheduleProfilesCompanion _profileToCompanion(ScheduleProfile profile) {
    return ScheduleProfilesCompanion.insert(
      id: profile.id,
      name: profile.name,
      patternType: profile.patternType.name,
      anchorDate: profile.anchorDate.toString(),
      anchorWeekType: Value(profile.anchorWeekType?.name),
      cycleDaysJson: Value(
        jsonEncode(profile.cycleDays.map((kind) => kind.name).toList()),
      ),
      holidayOverridesEnabled: Value(profile.holidayOverridesEnabled),
      isActive: Value(profile.isActive),
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
      deletedAt: Value(profile.deletedAt),
    );
  }

  StoredDayOverride _overrideFromRow(DayOverrideRow row) => StoredDayOverride(
    id: row.id,
    date: CalendarDate.parse(row.date),
    profileId: row.profileId,
    kind: DayKind.values.byName(row.kind),
    overtimeMinutes: row.overtimeMinutes,
    note: row.note,
    source: StoredOverrideSource.values.byName(row.source),
    createdAt: row.createdAt.toUtc(),
    updatedAt: row.updatedAt.toUtc(),
    deletedAt: row.deletedAt?.toUtc(),
  );

  DayOverridesCompanion _overrideToCompanion(StoredDayOverride override) {
    return DayOverridesCompanion.insert(
      id: override.id,
      date: override.date.toString(),
      profileId: override.profileId,
      kind: override.kind.name,
      overtimeMinutes: Value(override.overtimeMinutes),
      note: Value(override.note),
      source: override.source.name,
      createdAt: override.createdAt,
      updatedAt: override.updatedAt,
      deletedAt: Value(override.deletedAt),
    );
  }
}
