import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/core/database/app_database.dart';
import 'package:worker_rest_calendar/features/holidays/application/holiday_data_installer.dart';
import 'package:worker_rest_calendar/features/holidays/data/holiday_data_codec.dart';
import 'package:worker_rest_calendar/features/schedule/data/drift_schedule_repository.dart';

void main() {
  test('跨年数据同时安装，重复启动不丢失上一年度', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftScheduleRepository(database);
    final installer = HolidayDataInstaller(repository);
    for (final year in [2026, 2027, 2026, 2027]) {
      await installer.install(
        const HolidayDataCodec().decode(
          await File('assets/holidays/cn_$year.json').readAsString(),
        ),
      );
    }
    final stored = await repository.getHolidayOverrides('CN');
    expect(stored, hasLength(73));
    expect(stored.where((day) => day.date.year == 2026), hasLength(39));
    expect(stored.where((day) => day.date.year == 2027), hasLength(34));
  });

  test('同版本官方数据只安装一次且数据库保持 39 条', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftScheduleRepository(database);
    final installer = HolidayDataInstaller(repository);
    final bundle = const HolidayDataCodec().decode(
      await File('assets/holidays/cn_2026.json').readAsString(),
    );

    expect(await installer.install(bundle), isTrue);
    expect(await installer.install(bundle), isFalse);

    final stored = await repository.getHolidayOverrides('CN');
    expect(stored, hasLength(39));
    expect(
      stored.every((item) => item.dataVersion == bundle.dataVersion),
      isTrue,
    );
  });
}
