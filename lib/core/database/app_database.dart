import 'package:drift/drift.dart';
import 'package:worker_rest_calendar/core/database/tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    ScheduleProfiles,
    DayOverrides,
    HolidayOverrides,
    ReminderSettings,
    AppSettings,
    SyncQueue,
  ],
)
final class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await _ensureSingletonSettings();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(holidayOverrides);
        await migrator.createTable(reminderSettings);
        await migrator.createTable(appSettings);
        await migrator.createTable(syncQueue);
        await _ensureSingletonSettings();
      }
      if (from >= 2 && from < 3) {
        await migrator.addColumn(
          appSettings,
          appSettings.desktopLaunchAtStartup,
        );
      }
      if (from >= 2 && from < 4) {
        await migrator.addColumn(appSettings, appSettings.visualStyle);
      }
      if (from >= 2 && from < 5) {
        await migrator.addColumn(
          appSettings,
          appSettings.desktopWidgetLargeDateShape,
        );
      }
      if (from >= 2 && from < 6) {
        await migrator.addColumn(
          appSettings,
          appSettings.desktopWidgetTodayHighlightStyle,
        );
      }
      if (from >= 2 && from < 7) {
        await migrator.addColumn(appSettings, appSettings.calendarScrollAxis);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _ensureSingletonSettings() async {
    await into(reminderSettings).insert(
      const ReminderSettingsCompanion(),
      mode: InsertMode.insertOrIgnore,
    );
    await into(
      appSettings,
    ).insert(const AppSettingsCompanion(), mode: InsertMode.insertOrIgnore);
  }
}
