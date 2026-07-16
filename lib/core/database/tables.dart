import 'package:drift/drift.dart';

@DataClassName('ScheduleProfileRow')
class ScheduleProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get patternType => text()();
  TextColumn get anchorDate => text()();
  TextColumn get anchorWeekType => text().nullable()();
  TextColumn get cycleDaysJson => text().withDefault(const Constant('[]'))();
  BoolColumn get holidayOverridesEnabled =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('DayOverrideRow')
class DayOverrides extends Table {
  TextColumn get id => text()();
  TextColumn get date => text()();
  TextColumn get profileId => text().references(ScheduleProfiles, #id)();
  TextColumn get kind => text()();
  IntColumn get overtimeMinutes => integer().withDefault(const Constant(0))();
  TextColumn get note => text().nullable()();
  TextColumn get source => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {profileId, date},
  ];
}

@DataClassName('HolidayOverrideRow')
class HolidayOverrides extends Table {
  TextColumn get date => text()();
  TextColumn get kind => text()();
  TextColumn get title => text()();
  TextColumn get region => text()();
  TextColumn get dataVersion => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {date, region};
}

@DataClassName('ReminderSettingsRow')
class ReminderSettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  BoolColumn get dailyNextDayEnabled =>
      boolean().withDefault(const Constant(false))();
  TextColumn get dailyNextDayTime =>
      text().withDefault(const Constant('20:00'))();
  BoolColumn get adjustedWorkEnabled =>
      boolean().withDefault(const Constant(true))();
  IntColumn get adjustedWorkLeadDays =>
      integer().withDefault(const Constant(1))();
  BoolColumn get weeklyPreviewEnabled =>
      boolean().withDefault(const Constant(false))();
  IntColumn get weeklyPreviewWeekday =>
      integer().withDefault(const Constant(7))();
  TextColumn get weeklyPreviewTime =>
      text().withDefault(const Constant('20:00'))();
  BoolColumn get countdownEnabled =>
      boolean().withDefault(const Constant(false))();
  TextColumn get timeZoneId => text().withDefault(const Constant('local'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('AppSettingsRow')
class AppSettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get themeMode => text().withDefault(const Constant('system'))();
  TextColumn get visualStyle => text().withDefault(const Constant('classic'))();
  TextColumn get locale => text().withDefault(const Constant('zh_CN'))();
  BoolColumn get firstLaunchCompleted =>
      boolean().withDefault(const Constant(false))();
  TextColumn get desktopWidgetType =>
      text().withDefault(const Constant('schedule'))();
  TextColumn get desktopWidgetSize =>
      text().withDefault(const Constant('small'))();
  TextColumn get desktopWidgetNote => text().withDefault(const Constant(''))();
  TextColumn get desktopWidgetLargeDateShape =>
      text().withDefault(const Constant('roundedRectangle'))();
  TextColumn get desktopWidgetTodayHighlightStyle =>
      text().withDefault(const Constant('glowOutline'))();
  RealColumn get desktopWidgetOpacity =>
      real().withDefault(const Constant(1.0))();
  BoolColumn get desktopWidgetAlwaysOnTop =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get desktopWidgetLocked =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get desktopLaunchAtStartup =>
      boolean().withDefault(const Constant(false))();
  TextColumn get calendarScrollAxis =>
      text().withDefault(const Constant('horizontal'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SyncQueueRow')
class SyncQueue extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
