import 'dart:convert';

import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/core/theme/app_visual_style.dart';
import 'package:worker_rest_calendar/features/reminders/domain/reminder_preferences.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_pattern.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_profile.dart';
import 'package:worker_rest_calendar/features/schedule/domain/stored_day_override.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';
import 'package:worker_rest_calendar/features/sync/domain/backup_bundle.dart';
import 'package:worker_rest_calendar/features/sync/domain/import_error.dart';

final class BackupCodec {
  const BackupCodec({this.maxImportBytes = 5 * 1024 * 1024});

  final int maxImportBytes;

  String encode(BackupBundle bundle) => jsonEncode({
    'schemaVersion': bundle.schemaVersion,
    'profiles': bundle.profiles.map(_profileToJson).toList(),
    'overrides': bundle.overrides.map(_overrideToJson).toList(),
    'reminderSettings': _reminderSettingsToJson(bundle.reminderSettings),
    'appSettings': _appSettingsToJson(bundle.appSettings),
    'exportedAt': bundle.exportedAt.toUtc().toIso8601String(),
  });

  BackupBundle decode(String source) {
    final byteLength = utf8.encode(source).length;
    if (byteLength > maxImportBytes) {
      throw ImportFileTooLarge(
        actualBytes: byteLength,
        maxBytes: maxImportBytes,
      );
    }

    try {
      final root = _asMap(jsonDecode(source), '根对象');
      final schemaVersion = _asString(root['schemaVersion'], 'schemaVersion');
      if (schemaVersion != BackupBundle.currentSchemaVersion) {
        throw ImportSchemaMismatch(
          actual: schemaVersion,
          expected: BackupBundle.currentSchemaVersion,
        );
      }

      return BackupBundle(
        schemaVersion: schemaVersion,
        profiles: _asList(root['profiles'], 'profiles')
            .map((item) => _profileFromJson(_asMap(item, 'profile')))
            .toList(growable: false),
        overrides: _asList(root['overrides'], 'overrides')
            .map((item) => _overrideFromJson(_asMap(item, 'override')))
            .toList(growable: false),
        reminderSettings: _reminderSettingsFromJson(
          _asMap(root['reminderSettings'], 'reminderSettings'),
        ),
        appSettings: _appSettingsFromJson(
          _asMap(root['appSettings'], 'appSettings'),
        ),
        exportedAt: DateTime.parse(_asString(root['exportedAt'], 'exportedAt')),
      );
    } on ImportException {
      rethrow;
    } on Object catch (error) {
      throw InvalidImportData('导入 JSON 字段无效：$error');
    }
  }

  Map<String, Object?> _profileToJson(ScheduleProfile profile) => {
    'id': profile.id,
    'name': profile.name,
    'patternType': profile.patternType.name,
    'anchorDate': profile.anchorDate.toString(),
    'anchorWeekType': profile.anchorWeekType?.name,
    'cycleDays': profile.cycleDays.map((kind) => kind.name).toList(),
    'holidayOverridesEnabled': profile.holidayOverridesEnabled,
    'isActive': profile.isActive,
    'createdAt': profile.createdAt.toUtc().toIso8601String(),
    'updatedAt': profile.updatedAt.toUtc().toIso8601String(),
    'deletedAt': profile.deletedAt?.toUtc().toIso8601String(),
  };

  ScheduleProfile _profileFromJson(Map<String, Object?> json) =>
      ScheduleProfile(
        id: _asString(json['id'], 'profile.id'),
        name: _asString(json['name'], 'profile.name'),
        patternType: SchedulePatternType.values.byName(
          _asString(json['patternType'], 'profile.patternType'),
        ),
        anchorDate: CalendarDate.parse(
          _asString(json['anchorDate'], 'profile.anchorDate'),
        ),
        anchorWeekType: json['anchorWeekType'] == null
            ? null
            : WeekType.values.byName(
                _asString(json['anchorWeekType'], 'profile.anchorWeekType'),
              ),
        cycleDays: _asList(json['cycleDays'], 'profile.cycleDays')
            .map((kind) => DayKind.values.byName(_asString(kind, 'cycleDay')))
            .toList(growable: false),
        holidayOverridesEnabled: _asBool(
          json['holidayOverridesEnabled'],
          'profile.holidayOverridesEnabled',
        ),
        isActive: _asBool(json['isActive'], 'profile.isActive'),
        createdAt: DateTime.parse(
          _asString(json['createdAt'], 'profile.createdAt'),
        ),
        updatedAt: DateTime.parse(
          _asString(json['updatedAt'], 'profile.updatedAt'),
        ),
        deletedAt: json['deletedAt'] == null
            ? null
            : DateTime.parse(_asString(json['deletedAt'], 'profile.deletedAt')),
      );

  Map<String, Object?> _overrideToJson(StoredDayOverride override) => {
    'id': override.id,
    'date': override.date.toString(),
    'profileId': override.profileId,
    'kind': override.kind.name,
    'overtimeMinutes': override.overtimeMinutes,
    'note': override.note,
    'source': override.source.name,
    'createdAt': override.createdAt.toUtc().toIso8601String(),
    'updatedAt': override.updatedAt.toUtc().toIso8601String(),
    'deletedAt': override.deletedAt?.toUtc().toIso8601String(),
  };

  StoredDayOverride _overrideFromJson(Map<String, Object?> json) =>
      StoredDayOverride(
        id: _asString(json['id'], 'override.id'),
        date: CalendarDate.parse(_asString(json['date'], 'override.date')),
        profileId: _asString(json['profileId'], 'override.profileId'),
        kind: DayKind.values.byName(_asString(json['kind'], 'override.kind')),
        overtimeMinutes: _asInt(
          json['overtimeMinutes'],
          'override.overtimeMinutes',
        ),
        note: json['note'] == null
            ? null
            : _asString(json['note'], 'override.note'),
        source: StoredOverrideSource.values.byName(
          _asString(json['source'], 'override.source'),
        ),
        createdAt: DateTime.parse(
          _asString(json['createdAt'], 'override.createdAt'),
        ),
        updatedAt: DateTime.parse(
          _asString(json['updatedAt'], 'override.updatedAt'),
        ),
        deletedAt: json['deletedAt'] == null
            ? null
            : DateTime.parse(
                _asString(json['deletedAt'], 'override.deletedAt'),
              ),
      );

  Map<String, Object?> _reminderSettingsToJson(ReminderPreferences settings) =>
      {
        'dailyNextDayEnabled': settings.dailyNextDayEnabled,
        'dailyNextDayTime': settings.dailyNextDayTime,
        'adjustedWorkEnabled': settings.adjustedWorkEnabled,
        'adjustedWorkLeadDays': settings.adjustedWorkLeadDays,
        'weeklyPreviewEnabled': settings.weeklyPreviewEnabled,
        'weeklyPreviewWeekday': settings.weeklyPreviewWeekday,
        'weeklyPreviewTime': settings.weeklyPreviewTime,
        'countdownEnabled': settings.countdownEnabled,
        'timeZoneId': settings.timeZoneId,
      };

  ReminderPreferences _reminderSettingsFromJson(Map<String, Object?> json) =>
      ReminderPreferences(
        dailyNextDayEnabled: _asBool(
          json['dailyNextDayEnabled'],
          'reminderSettings.dailyNextDayEnabled',
        ),
        dailyNextDayTime: _asString(
          json['dailyNextDayTime'],
          'reminderSettings.dailyNextDayTime',
        ),
        adjustedWorkEnabled: _asBool(
          json['adjustedWorkEnabled'],
          'reminderSettings.adjustedWorkEnabled',
        ),
        adjustedWorkLeadDays: _asInt(
          json['adjustedWorkLeadDays'],
          'reminderSettings.adjustedWorkLeadDays',
        ),
        weeklyPreviewEnabled: _asBool(
          json['weeklyPreviewEnabled'],
          'reminderSettings.weeklyPreviewEnabled',
        ),
        weeklyPreviewWeekday: _asInt(
          json['weeklyPreviewWeekday'],
          'reminderSettings.weeklyPreviewWeekday',
        ),
        weeklyPreviewTime: _asString(
          json['weeklyPreviewTime'],
          'reminderSettings.weeklyPreviewTime',
        ),
        countdownEnabled: _asBool(
          json['countdownEnabled'],
          'reminderSettings.countdownEnabled',
        ),
        timeZoneId: _asString(
          json['timeZoneId'],
          'reminderSettings.timeZoneId',
        ),
      );

  Map<String, Object?> _appSettingsToJson(AppPreferences settings) => {
    'themeMode': settings.themeMode.name,
    'visualStyle': settings.visualStyle.name,
    'locale': settings.locale,
    'firstLaunchCompleted': settings.firstLaunchCompleted,
    'desktopWidgetType': settings.desktopWidgetType.name,
    'desktopWidgetSize': settings.desktopWidgetSize.name,
    'desktopWidgetNote': settings.desktopWidgetNote,
    'desktopWidgetLargeDateShape': settings.desktopWidgetLargeDateShape.name,
    'desktopWidgetTodayHighlightStyle':
        settings.desktopWidgetTodayHighlightStyle.name,
    'desktopWidgetOpacity': settings.desktopWidgetOpacity,
    'desktopWidgetAlwaysOnTop': settings.desktopWidgetAlwaysOnTop,
    'desktopWidgetLocked': settings.desktopWidgetLocked,
    'desktopLaunchAtStartup': settings.desktopLaunchAtStartup,
    'calendarScrollAxis': settings.calendarScrollAxis.name,
  };

  AppPreferences _appSettingsFromJson(Map<String, Object?> json) =>
      AppPreferences(
        themeMode: AppThemePreference.values.byName(
          _asString(json['themeMode'], 'appSettings.themeMode'),
        ),
        visualStyle: json['visualStyle'] == null
            ? AppVisualStyle.classic
            : AppVisualStyle.values.byName(
                _asString(json['visualStyle'], 'appSettings.visualStyle'),
              ),
        locale: _asString(json['locale'], 'appSettings.locale'),
        firstLaunchCompleted: _asBool(
          json['firstLaunchCompleted'],
          'appSettings.firstLaunchCompleted',
        ),
        desktopWidgetType: json['desktopWidgetType'] == null
            ? DesktopWidgetType.schedule
            : DesktopWidgetType.values.byName(
                _asString(
                  json['desktopWidgetType'],
                  'appSettings.desktopWidgetType',
                ),
              ),
        desktopWidgetSize: DesktopWidgetSize.values.byName(
          _asString(json['desktopWidgetSize'], 'appSettings.desktopWidgetSize'),
        ),
        desktopWidgetNote: json['desktopWidgetNote'] == null
            ? ''
            : _asString(
                json['desktopWidgetNote'],
                'appSettings.desktopWidgetNote',
              ),
        desktopWidgetLargeDateShape: json['desktopWidgetLargeDateShape'] == null
            ? DesktopWidgetLargeDateShape.roundedRectangle
            : DesktopWidgetLargeDateShape.values.byName(
                _asString(
                  json['desktopWidgetLargeDateShape'],
                  'appSettings.desktopWidgetLargeDateShape',
                ),
              ),
        desktopWidgetTodayHighlightStyle:
            json['desktopWidgetTodayHighlightStyle'] == null
            ? DesktopWidgetTodayHighlightStyle.glowOutline
            : DesktopWidgetTodayHighlightStyle.values.byName(
                _asString(
                  json['desktopWidgetTodayHighlightStyle'],
                  'appSettings.desktopWidgetTodayHighlightStyle',
                ),
              ),
        desktopWidgetOpacity: _asDouble(
          json['desktopWidgetOpacity'],
          'appSettings.desktopWidgetOpacity',
        ),
        desktopWidgetAlwaysOnTop: _asBool(
          json['desktopWidgetAlwaysOnTop'],
          'appSettings.desktopWidgetAlwaysOnTop',
        ),
        desktopWidgetLocked: _asBool(
          json['desktopWidgetLocked'],
          'appSettings.desktopWidgetLocked',
        ),
        desktopLaunchAtStartup: json.containsKey('desktopLaunchAtStartup')
            ? _asBool(
                json['desktopLaunchAtStartup'],
                'appSettings.desktopLaunchAtStartup',
              )
            : false,
        calendarScrollAxis: json['calendarScrollAxis'] == null
            ? CalendarScrollAxis.horizontal
            : CalendarScrollAxis.values.byName(
                _asString(
                  json['calendarScrollAxis'],
                  'appSettings.calendarScrollAxis',
                ),
              ),
      );

  Map<String, Object?> _asMap(Object? value, String field) {
    if (value is! Map<String, Object?>) {
      throw InvalidImportData('$field 必须是对象');
    }
    return value;
  }

  List<Object?> _asList(Object? value, String field) {
    if (value is! List<Object?>) {
      throw InvalidImportData('$field 必须是数组');
    }
    return value;
  }

  String _asString(Object? value, String field) {
    if (value is! String) {
      throw InvalidImportData('$field 必须是字符串');
    }
    return value;
  }

  bool _asBool(Object? value, String field) {
    if (value is! bool) {
      throw InvalidImportData('$field 必须是布尔值');
    }
    return value;
  }

  int _asInt(Object? value, String field) {
    if (value is! int) {
      throw InvalidImportData('$field 必须是整数');
    }
    return value;
  }

  double _asDouble(Object? value, String field) {
    if (value is! num) {
      throw InvalidImportData('$field 必须是数字');
    }
    return value.toDouble();
  }
}
