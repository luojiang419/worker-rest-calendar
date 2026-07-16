import 'package:worker_rest_calendar/features/reminders/domain/reminder_preferences.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_profile.dart';
import 'package:worker_rest_calendar/features/schedule/domain/stored_day_override.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

final class BackupBundle {
  const BackupBundle({
    required this.schemaVersion,
    required this.profiles,
    required this.overrides,
    required this.reminderSettings,
    required this.appSettings,
    required this.exportedAt,
  });

  static const currentSchemaVersion = '1.0.0';

  final String schemaVersion;
  final List<ScheduleProfile> profiles;
  final List<StoredDayOverride> overrides;
  final ReminderPreferences reminderSettings;
  final AppPreferences appSettings;
  final DateTime exportedAt;
}

final class ImportPreview {
  const ImportPreview({
    required this.newRecords,
    required this.overwrittenRecords,
    required this.conflictingRecords,
    required this.settingsWillChange,
  });

  final int newRecords;
  final int overwrittenRecords;
  final int conflictingRecords;
  final bool settingsWillChange;
}
