import 'dart:io';

import 'package:drift/native.dart';
import 'package:test/test.dart';
import 'package:worker_rest_calendar/core/database/app_database.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/schedule/data/drift_schedule_repository.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/schedule/domain/stored_holiday_override.dart';

import '../../../helpers/test_models.dart';

void main() {
  test('active profile 流随保存和切换更新且始终唯一', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftScheduleRepository(database);
    final emissions = repository
        .watchActiveProfile()
        .map((profile) => profile?.id)
        .take(3)
        .toList();

    await Future<void>.delayed(Duration.zero);
    await repository.saveProfile(testProfile());
    await repository.saveProfile(
      testProfile(id: 'profile-2', name: '第二班制', isActive: false),
    );
    await repository.setActiveProfile(
      'profile-2',
      updatedAt: DateTime.utc(2026, 7, 13),
    );

    expect(await emissions, [null, 'profile-1', 'profile-2']);
    expect((await repository.getActiveProfile())?.id, 'profile-2');
    final profiles = await repository.getProfiles();
    expect(profiles.where((profile) => profile.isActive), hasLength(1));
    expect(profiles.singleWhere((profile) => profile.isActive).id, 'profile-2');
  });

  test('日期覆盖可保存、软删除并恢复', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftScheduleRepository(database);
    await repository.saveProfile(testProfile());
    final override = testOverride();

    await repository.saveDayOverride(override);
    expect(await repository.getDayOverrides('profile-1'), hasLength(1));

    final deletedAt = DateTime.utc(2026, 7, 14);
    await repository.softDeleteDayOverride(
      profileId: 'profile-1',
      date: CalendarDate(2026, 7, 11),
      deletedAt: deletedAt,
    );
    expect(await repository.getDayOverrides('profile-1'), isEmpty);
    final deleted = await repository.getDayOverrides(
      'profile-1',
      includeDeleted: true,
    );
    expect(deleted.single.deletedAt, deletedAt);

    await repository.saveDayOverride(
      override.copyWith(
        kind: DayKind.work,
        updatedAt: DateTime.utc(2026, 7, 15),
        clearDeletedAt: true,
      ),
    );
    expect(
      (await repository.getDayOverrides('profile-1')).single.kind,
      DayKind.work,
    );

    await repository.saveDayOverride(
      testOverride(id: 'replacement', kind: DayKind.leave),
    );
    final replaced = await repository.getDayOverrides('profile-1');
    expect(replaced, hasLength(1));
    expect(replaced.single.id, 'replacement');
    expect(replaced.single.kind, DayKind.leave);
  });

  test('班制软删除后不会出现在默认列表或 active flow', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftScheduleRepository(database);
    await repository.saveProfile(testProfile());

    final deletedAt = DateTime.utc(2026, 7, 16);
    await repository.softDeleteProfile('profile-1', deletedAt: deletedAt);

    expect(await repository.getProfiles(), isEmpty);
    final deleted = await repository.getProfiles(includeDeleted: true);
    expect(deleted.single.deletedAt, deletedAt);
    expect(await repository.watchActiveProfile().first, isNull);
  });

  test('节假日覆盖按地区保存并限制为两种调休状态', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftScheduleRepository(database);
    final updatedAt = DateTime.utc(2026, 1, 1);

    await repository.saveHolidayOverrides([
      StoredHolidayOverride(
        date: CalendarDate(2026, 10, 1),
        kind: DayKind.adjustedRest,
        title: '国庆节',
        region: 'CN',
        dataVersion: '2026.1',
        updatedAt: updatedAt,
      ),
      StoredHolidayOverride(
        date: CalendarDate(2026, 10, 10),
        kind: DayKind.adjustedWork,
        title: '调休上班',
        region: 'CN',
        dataVersion: '2026.1',
        updatedAt: updatedAt,
      ),
    ]);

    final holidays = await repository.getHolidayOverrides('CN');
    expect(holidays, hasLength(2));
    expect(holidays.first.kind, DayKind.adjustedRest);
    expect(
      () => StoredHolidayOverride(
        date: CalendarDate(2026, 10, 2),
        kind: DayKind.leave,
        title: '无效',
        region: 'CN',
        dataVersion: '2026.1',
        updatedAt: updatedAt,
      ),
      throwsArgumentError,
    );
  });

  test('文件数据库重开后班制与覆盖仍存在', () async {
    final directory = await Directory.systemTemp.createTemp(
      'rest_calendar_restart_',
    );
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}${Platform.pathSeparator}app.sqlite');

    var database = AppDatabase(NativeDatabase(file));
    var repository = DriftScheduleRepository(database);
    await repository.saveProfile(testProfile());
    await repository.saveDayOverride(testOverride());
    await database.close();

    database = AppDatabase(NativeDatabase(file));
    addTearDown(database.close);
    repository = DriftScheduleRepository(database);

    expect((await repository.getProfile('profile-1'))?.name, '测试大小周');
    expect(await repository.getDayOverrides('profile-1'), hasLength(1));
  });

  test('不存在的班制不能写入覆盖，且不留下部分数据', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftScheduleRepository(database);

    expect(
      () => repository.saveDayOverride(testOverride(profileId: 'missing')),
      throwsStateError,
    );
    expect(await database.select(database.dayOverrides).get(), isEmpty);
  });
}
