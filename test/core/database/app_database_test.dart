import 'dart:io';

import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';
import 'package:worker_rest_calendar/core/database/app_database.dart';
import 'package:worker_rest_calendar/core/database/database_migration_backup.dart';

void main() {
  test('新数据库创建全部表和单例默认设置', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    expect(await database.select(database.scheduleProfiles).get(), isEmpty);
    expect(
      await database.select(database.reminderSettings).get(),
      hasLength(1),
    );
    expect(await database.select(database.appSettings).get(), hasLength(1));
    expect(await database.select(database.syncQueue).get(), isEmpty);
  });

  test('v1 文件升级到最新版本时保留核心表并补齐新表', () async {
    final directory = await Directory.systemTemp.createTemp(
      'rest_calendar_migration_',
    );
    addTearDown(() => directory.delete(recursive: true));
    final file = File(
      '${directory.path}${Platform.pathSeparator}legacy.sqlite',
    );

    final legacy = sqlite3.open(file.path);
    legacy.execute('''
      CREATE TABLE schedule_profiles (
        id TEXT NOT NULL PRIMARY KEY,
        name TEXT NOT NULL,
        pattern_type TEXT NOT NULL,
        anchor_date TEXT NOT NULL,
        anchor_week_type TEXT,
        cycle_days_json TEXT NOT NULL DEFAULT '[]',
        holiday_overrides_enabled INTEGER NOT NULL DEFAULT 1,
        is_active INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER
      )
    ''');
    legacy.execute('''
      CREATE TABLE day_overrides (
        id TEXT NOT NULL PRIMARY KEY,
        date TEXT NOT NULL,
        profile_id TEXT NOT NULL,
        kind TEXT NOT NULL,
        overtime_minutes INTEGER NOT NULL DEFAULT 0,
        note TEXT,
        source TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER,
        UNIQUE(profile_id, date),
        FOREIGN KEY(profile_id) REFERENCES schedule_profiles(id)
      )
    ''');
    final timestamp = DateTime.utc(2026, 7, 1).millisecondsSinceEpoch ~/ 1000;
    legacy.execute(
      'INSERT INTO schedule_profiles '
      '(id, name, pattern_type, anchor_date, anchor_week_type, '
      'cycle_days_json, holiday_overrides_enabled, is_active, created_at, updated_at) '
      "VALUES ('legacy', '旧班制', 'doubleRest', '2026-07-01', NULL, '[]', 1, 1, $timestamp, $timestamp)",
    );
    legacy.execute('PRAGMA user_version = 1');
    legacy.dispose();

    final backup = await backupDatabaseBeforeMigration(
      file,
      currentSchemaVersion: 7,
    );
    expect(backup, isNotNull);
    expect(await backup!.exists(), isTrue);

    final database = AppDatabase(NativeDatabase(file));
    addTearDown(database.close);

    expect(
      await database.select(database.scheduleProfiles).get(),
      hasLength(1),
    );
    expect(
      await database.select(database.reminderSettings).get(),
      hasLength(1),
    );
    expect(await database.select(database.appSettings).get(), hasLength(1));
    expect(await database.select(database.holidayOverrides).get(), isEmpty);
    expect(await database.select(database.syncQueue).get(), isEmpty);
    final version = await database
        .customSelect('PRAGMA user_version')
        .getSingle();
    expect(version.read<int>('user_version'), 7);
  });

  test('v2 文件升级到最新版时补齐桌面启动、视觉风格和日期样式', () async {
    final directory = await Directory.systemTemp.createTemp(
      'rest_calendar_v3_migration_',
    );
    addTearDown(() => directory.delete(recursive: true));
    final file = File(
      '${directory.path}${Platform.pathSeparator}legacy-v2.sqlite',
    );
    final legacy = sqlite3.open(file.path);
    legacy.execute('''
      CREATE TABLE app_settings (
        id INTEGER NOT NULL DEFAULT 1 PRIMARY KEY,
        theme_mode TEXT NOT NULL DEFAULT 'system',
        locale TEXT NOT NULL DEFAULT 'zh_CN',
        first_launch_completed INTEGER NOT NULL DEFAULT 0,
        desktop_widget_size TEXT NOT NULL DEFAULT 'small',
        desktop_widget_opacity REAL NOT NULL DEFAULT 1.0,
        desktop_widget_always_on_top INTEGER NOT NULL DEFAULT 0,
        desktop_widget_locked INTEGER NOT NULL DEFAULT 0
      )
    ''');
    legacy.execute('INSERT INTO app_settings (id) VALUES (1)');
    legacy.execute('PRAGMA user_version = 2');
    legacy.dispose();

    final database = AppDatabase(NativeDatabase(file));
    addTearDown(database.close);
    final row = await database.select(database.appSettings).getSingle();

    expect(row.desktopLaunchAtStartup, isFalse);
    expect(row.visualStyle, 'classic');
    expect(row.desktopWidgetLargeDateShape, 'roundedRectangle');
    expect(row.desktopWidgetTodayHighlightStyle, 'glowOutline');
    expect(row.calendarScrollAxis, 'horizontal');
    final version = await database
        .customSelect('PRAGMA user_version')
        .getSingle();
    expect(version.read<int>('user_version'), 7);
  });

  test('v5 文件升级到最新版时为当日突出样式写入兼容默认值', () async {
    final directory = await Directory.systemTemp.createTemp(
      'rest_calendar_v5_migration_',
    );
    addTearDown(() => directory.delete(recursive: true));
    final file = File(
      '${directory.path}${Platform.pathSeparator}legacy-v4.sqlite',
    );
    final legacy = sqlite3.open(file.path);
    legacy.execute('''
      CREATE TABLE app_settings (
        id INTEGER NOT NULL DEFAULT 1 PRIMARY KEY,
        theme_mode TEXT NOT NULL DEFAULT 'system',
        visual_style TEXT NOT NULL DEFAULT 'classic',
        locale TEXT NOT NULL DEFAULT 'zh_CN',
        first_launch_completed INTEGER NOT NULL DEFAULT 0,
        desktop_widget_size TEXT NOT NULL DEFAULT 'small',
        desktop_widget_large_date_shape TEXT NOT NULL DEFAULT 'roundedRectangle',
        desktop_widget_opacity REAL NOT NULL DEFAULT 1.0,
        desktop_widget_always_on_top INTEGER NOT NULL DEFAULT 0,
        desktop_widget_locked INTEGER NOT NULL DEFAULT 0,
        desktop_launch_at_startup INTEGER NOT NULL DEFAULT 0
      )
    ''');
    legacy.execute(
      "INSERT INTO app_settings (id, desktop_widget_size, desktop_widget_large_date_shape) VALUES (1, 'large', 'circle')",
    );
    legacy.execute('PRAGMA user_version = 5');
    legacy.dispose();

    final database = AppDatabase(NativeDatabase(file));
    addTearDown(database.close);
    final row = await database.select(database.appSettings).getSingle();

    expect(row.desktopWidgetSize, 'large');
    expect(row.desktopWidgetLargeDateShape, 'circle');
    expect(row.desktopWidgetTodayHighlightStyle, 'glowOutline');
    expect(row.calendarScrollAxis, 'horizontal');
    final version = await database
        .customSelect('PRAGMA user_version')
        .getSingle();
    expect(version.read<int>('user_version'), 7);
  });
}
