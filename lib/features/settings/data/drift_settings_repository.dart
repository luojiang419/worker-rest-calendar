import 'package:drift/drift.dart';
import 'package:worker_rest_calendar/core/database/app_database.dart';
import 'package:worker_rest_calendar/core/theme/app_visual_style.dart';
import 'package:worker_rest_calendar/features/reminders/domain/reminder_preferences.dart';
import 'package:worker_rest_calendar/features/settings/application/settings_repository.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

final class DriftSettingsRepository implements SettingsRepository {
  const DriftSettingsRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<AppPreferences> watchAppPreferences() =>
      (_database.select(_database.appSettings)
            ..where((table) => table.id.equals(1)))
          .watchSingle()
          .map(_appPreferencesFromRow);

  @override
  Future<AppPreferences> getAppPreferences() async => _appPreferencesFromRow(
    await (_database.select(
      _database.appSettings,
    )..where((table) => table.id.equals(1))).getSingle(),
  );

  @override
  Future<void> saveAppPreferences(AppPreferences preferences) => _database
      .into(_database.appSettings)
      .insertOnConflictUpdate(
        AppSettingsCompanion.insert(
          id: const Value(1),
          themeMode: Value(preferences.themeMode.name),
          visualStyle: Value(preferences.visualStyle.name),
          locale: Value(preferences.locale),
          firstLaunchCompleted: Value(preferences.firstLaunchCompleted),
          desktopWidgetType: Value(preferences.desktopWidgetType.name),
          desktopWidgetSize: Value(preferences.desktopWidgetSize.name),
          desktopWidgetNote: Value(preferences.desktopWidgetNote),
          desktopWidgetLargeDateShape: Value(
            preferences.desktopWidgetLargeDateShape.name,
          ),
          desktopWidgetTodayHighlightStyle: Value(
            preferences.desktopWidgetTodayHighlightStyle.name,
          ),
          desktopWidgetOpacity: Value(preferences.desktopWidgetOpacity),
          desktopWidgetAlwaysOnTop: Value(preferences.desktopWidgetAlwaysOnTop),
          desktopWidgetLocked: Value(preferences.desktopWidgetLocked),
          desktopLaunchAtStartup: Value(preferences.desktopLaunchAtStartup),
          calendarScrollAxis: Value(preferences.calendarScrollAxis.name),
        ),
      );

  @override
  Stream<ReminderPreferences> watchReminderPreferences() =>
      (_database.select(_database.reminderSettings)
            ..where((table) => table.id.equals(1)))
          .watchSingle()
          .map(_reminderPreferencesFromRow);

  @override
  Future<ReminderPreferences> getReminderPreferences() async =>
      _reminderPreferencesFromRow(
        await (_database.select(
          _database.reminderSettings,
        )..where((table) => table.id.equals(1))).getSingle(),
      );

  @override
  Future<void> saveReminderPreferences(ReminderPreferences preferences) =>
      _database
          .into(_database.reminderSettings)
          .insertOnConflictUpdate(
            ReminderSettingsCompanion.insert(
              id: const Value(1),
              dailyNextDayEnabled: Value(preferences.dailyNextDayEnabled),
              dailyNextDayTime: Value(preferences.dailyNextDayTime),
              adjustedWorkEnabled: Value(preferences.adjustedWorkEnabled),
              adjustedWorkLeadDays: Value(preferences.adjustedWorkLeadDays),
              weeklyPreviewEnabled: Value(preferences.weeklyPreviewEnabled),
              weeklyPreviewWeekday: Value(preferences.weeklyPreviewWeekday),
              weeklyPreviewTime: Value(preferences.weeklyPreviewTime),
              countdownEnabled: Value(preferences.countdownEnabled),
              timeZoneId: Value(preferences.timeZoneId),
            ),
          );

  AppPreferences _appPreferencesFromRow(AppSettingsRow row) => AppPreferences(
    themeMode: AppThemePreference.values.byName(row.themeMode),
    visualStyle: AppVisualStyle.values.byName(row.visualStyle),
    locale: row.locale,
    firstLaunchCompleted: row.firstLaunchCompleted,
    desktopWidgetType: DesktopWidgetType.values.byName(row.desktopWidgetType),
    desktopWidgetSize: DesktopWidgetSize.values.byName(row.desktopWidgetSize),
    desktopWidgetNote: row.desktopWidgetNote,
    desktopWidgetLargeDateShape: DesktopWidgetLargeDateShape.values.byName(
      row.desktopWidgetLargeDateShape,
    ),
    desktopWidgetTodayHighlightStyle: DesktopWidgetTodayHighlightStyle.values
        .byName(row.desktopWidgetTodayHighlightStyle),
    desktopWidgetOpacity: row.desktopWidgetOpacity,
    desktopWidgetAlwaysOnTop: row.desktopWidgetAlwaysOnTop,
    desktopWidgetLocked: row.desktopWidgetLocked,
    desktopLaunchAtStartup: row.desktopLaunchAtStartup,
    calendarScrollAxis: CalendarScrollAxis.values.byName(
      row.calendarScrollAxis,
    ),
  );

  ReminderPreferences _reminderPreferencesFromRow(ReminderSettingsRow row) =>
      ReminderPreferences(
        dailyNextDayEnabled: row.dailyNextDayEnabled,
        dailyNextDayTime: row.dailyNextDayTime,
        adjustedWorkEnabled: row.adjustedWorkEnabled,
        adjustedWorkLeadDays: row.adjustedWorkLeadDays,
        weeklyPreviewEnabled: row.weeklyPreviewEnabled,
        weeklyPreviewWeekday: row.weeklyPreviewWeekday,
        weeklyPreviewTime: row.weeklyPreviewTime,
        countdownEnabled: row.countdownEnabled,
        timeZoneId: row.timeZoneId,
      );
}
