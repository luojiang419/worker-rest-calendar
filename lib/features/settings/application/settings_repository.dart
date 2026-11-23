import 'package:worker_rest_calendar/features/reminders/domain/reminder_preferences.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

abstract interface class SettingsRepository {
  Stream<AppPreferences> watchAppPreferences();

  Future<AppPreferences> getAppPreferences();

  Future<void> saveAppPreferences(AppPreferences preferences);

  Stream<ReminderPreferences> watchReminderPreferences();

  Future<ReminderPreferences> getReminderPreferences();

  Future<void> saveReminderPreferences(ReminderPreferences preferences);
}
