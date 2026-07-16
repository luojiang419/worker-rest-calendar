import 'package:drift/native.dart';
import 'package:test/test.dart';
import 'package:worker_rest_calendar/core/database/app_database.dart';
import 'package:worker_rest_calendar/core/theme/app_visual_style.dart';
import 'package:worker_rest_calendar/features/reminders/domain/reminder_preferences.dart';
import 'package:worker_rest_calendar/features/schedule/data/drift_schedule_repository.dart';
import 'package:worker_rest_calendar/features/settings/data/drift_settings_repository.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';
import 'package:worker_rest_calendar/features/sync/data/backup_codec.dart';
import 'package:worker_rest_calendar/features/sync/data/local_backup_repository.dart';
import 'package:worker_rest_calendar/features/sync/domain/backup_bundle.dart';
import 'package:worker_rest_calendar/features/sync/domain/import_error.dart';

import '../../../helpers/test_models.dart';

void main() {
  late AppDatabase database;
  late DriftScheduleRepository schedules;
  late DriftSettingsRepository settings;
  late LocalBackupRepository backups;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    schedules = DriftScheduleRepository(database);
    settings = DriftSettingsRepository(database);
    backups = LocalBackupRepository(
      database: database,
      scheduleRepository: schedules,
      settingsRepository: settings,
    );
  });

  tearDown(() => database.close());

  test('导出 JSON 可解析并保留核心数据与设置', () async {
    await schedules.saveProfile(testProfile());
    await schedules.saveDayOverride(testOverride());
    await settings.saveAppPreferences(
      const AppPreferences(
        themeMode: AppThemePreference.dark,
        visualStyle: AppVisualStyle.glass,
        desktopWidgetType: DesktopWidgetType.note,
        desktopWidgetNote: '备份中的便笺',
        desktopWidgetLargeDateShape: DesktopWidgetLargeDateShape.circle,
        desktopWidgetTodayHighlightStyle:
            DesktopWidgetTodayHighlightStyle.filled,
        calendarScrollAxis: CalendarScrollAxis.vertical,
      ),
    );
    await settings.saveReminderPreferences(
      const ReminderPreferences(dailyNextDayEnabled: true),
    );

    final json = await backups.exportJson(
      exportedAt: DateTime.utc(2026, 7, 12, 10),
    );
    final parsed = backups.parseJson(json);

    expect(parsed.schemaVersion, BackupBundle.currentSchemaVersion);
    expect(parsed.profiles.single.id, 'profile-1');
    expect(parsed.overrides.single.id, 'override-1');
    expect(parsed.appSettings.themeMode, AppThemePreference.dark);
    expect(parsed.appSettings.visualStyle, AppVisualStyle.glass);
    expect(parsed.appSettings.desktopWidgetType, DesktopWidgetType.note);
    expect(parsed.appSettings.desktopWidgetNote, '备份中的便笺');
    expect(
      parsed.appSettings.desktopWidgetLargeDateShape,
      DesktopWidgetLargeDateShape.circle,
    );
    expect(
      parsed.appSettings.desktopWidgetTodayHighlightStyle,
      DesktopWidgetTodayHighlightStyle.filled,
    );
    expect(parsed.appSettings.calendarScrollAxis, CalendarScrollAxis.vertical);
    final legacyJson = json.replaceFirst('"visualStyle":"glass",', '');
    expect(
      backups.parseJson(legacyJson).appSettings.visualStyle,
      AppVisualStyle.classic,
    );
    final legacyDateShapeJson = json.replaceFirst(
      '"desktopWidgetLargeDateShape":"circle",',
      '',
    );
    expect(
      backups
          .parseJson(legacyDateShapeJson)
          .appSettings
          .desktopWidgetLargeDateShape,
      DesktopWidgetLargeDateShape.roundedRectangle,
    );
    final legacyTodayHighlightJson = json.replaceFirst(
      '"desktopWidgetTodayHighlightStyle":"filled",',
      '',
    );
    expect(
      backups
          .parseJson(legacyTodayHighlightJson)
          .appSettings
          .desktopWidgetTodayHighlightStyle,
      DesktopWidgetTodayHighlightStyle.glowOutline,
    );
    final legacyScrollAxisJson = json.replaceFirst(
      ',"calendarScrollAxis":"vertical"',
      '',
    );
    expect(
      backups.parseJson(legacyScrollAxisJson).appSettings.calendarScrollAxis,
      CalendarScrollAxis.horizontal,
    );
    final legacyWidgetTypeJson = json.replaceFirst(
      '"desktopWidgetType":"note",',
      '',
    );
    expect(
      backups.parseJson(legacyWidgetTypeJson).appSettings.desktopWidgetType,
      DesktopWidgetType.schedule,
    );
    final legacyWidgetNoteJson = json.replaceFirst(
      '"desktopWidgetNote":"备份中的便笺",',
      '',
    );
    expect(
      backups.parseJson(legacyWidgetNoteJson).appSettings.desktopWidgetNote,
      isEmpty,
    );
    expect(parsed.reminderSettings.dailyNextDayEnabled, isTrue);
  });

  test('解析拒绝不兼容 schema、损坏 JSON 和超限输入', () {
    expect(
      () => backups.parseJson('{"schemaVersion":"2.0.0"}'),
      throwsA(isA<ImportSchemaMismatch>()),
    );
    expect(
      () => backups.parseJson('not-json'),
      throwsA(isA<InvalidImportData>()),
    );
    const tinyCodec = BackupCodec(maxImportBytes: 8);
    expect(
      () => tinyCodec.decode('123456789'),
      throwsA(isA<ImportFileTooLarge>()),
    );
  });

  test('导入预览区分新增、覆盖和本地较新冲突', () async {
    await schedules.saveProfile(
      testProfile(updatedAt: DateTime.utc(2026, 7, 20)),
    );
    await schedules.saveDayOverride(testOverride());
    final bundle = BackupBundle(
      schemaVersion: BackupBundle.currentSchemaVersion,
      profiles: [
        testProfile(updatedAt: DateTime.utc(2026, 7, 10)),
        testProfile(id: 'profile-2', isActive: false),
      ],
      overrides: [
        testOverride(updatedAt: DateTime.utc(2026, 7, 13)),
        testOverride(id: 'override-2', profileId: 'profile-2'),
      ],
      reminderSettings: const ReminderPreferences(),
      appSettings: const AppPreferences(),
      exportedAt: DateTime.utc(2026, 7, 12),
    );

    final preview = await backups.previewImport(bundle);

    expect(preview.newRecords, 2);
    expect(preview.overwrittenRecords, 1);
    expect(preview.conflictingRecords, 1);
    expect(preview.settingsWillChange, isTrue);
  });

  test('导入中途失败时整个事务回滚', () async {
    final bundle = BackupBundle(
      schemaVersion: BackupBundle.currentSchemaVersion,
      profiles: [testProfile(id: 'imported')],
      overrides: [testOverride(profileId: 'missing-profile')],
      reminderSettings: const ReminderPreferences(),
      appSettings: const AppPreferences(),
      exportedAt: DateTime.utc(2026, 7, 12),
    );

    await expectLater(backups.importBundle(bundle), throwsStateError);

    expect(await schedules.getProfiles(includeDeleted: true), isEmpty);
    expect(await database.select(database.dayOverrides).get(), isEmpty);
  });

  test('确认导入后可用新 UUID 替换同一日期的旧覆盖', () async {
    await schedules.saveProfile(testProfile());
    await schedules.saveDayOverride(testOverride());
    final bundle = BackupBundle(
      schemaVersion: BackupBundle.currentSchemaVersion,
      profiles: [testProfile(updatedAt: DateTime.utc(2026, 7, 20))],
      overrides: [
        testOverride(id: 'replacement', updatedAt: DateTime.utc(2026, 7, 20)),
      ],
      reminderSettings: const ReminderPreferences(),
      appSettings: const AppPreferences(),
      exportedAt: DateTime.utc(2026, 7, 20),
    );

    await backups.importBundle(bundle);

    final overrides = await schedules.getDayOverrides('profile-1');
    expect(overrides, hasLength(1));
    expect(overrides.single.id, 'replacement');
  });

  test('导出后清空再导入可恢复全部核心数据', () async {
    await schedules.saveProfile(testProfile());
    await schedules.saveDayOverride(testOverride());
    await settings.saveAppPreferences(
      const AppPreferences(
        firstLaunchCompleted: true,
        themeMode: AppThemePreference.dark,
      ),
    );
    final json = await backups.exportJson(
      exportedAt: DateTime.utc(2026, 7, 13),
    );

    await backups.clearAllData();

    expect(await schedules.getProfiles(includeDeleted: true), isEmpty);
    expect((await settings.getAppPreferences()).firstLaunchCompleted, isFalse);

    await backups.importBundle(backups.parseJson(json));

    expect(await schedules.getProfiles(includeDeleted: true), hasLength(1));
    expect(await schedules.getDayOverrides('profile-1'), hasLength(1));
    expect(
      (await settings.getAppPreferences()).themeMode,
      AppThemePreference.dark,
    );
  });

  test('导入时保留更新时间更晚的本地冲突记录', () async {
    final local = testProfile(updatedAt: DateTime.utc(2026, 7, 20));
    await schedules.saveProfile(local);
    final bundle = BackupBundle(
      schemaVersion: BackupBundle.currentSchemaVersion,
      profiles: [
        testProfile(name: '旧备份名称', updatedAt: DateTime.utc(2026, 7, 10)),
      ],
      overrides: const [],
      reminderSettings: const ReminderPreferences(),
      appSettings: const AppPreferences(),
      exportedAt: DateTime.utc(2026, 7, 10),
    );

    await backups.importBundle(bundle);

    expect((await schedules.getProfile(local.id))!.name, local.name);
  });
}
