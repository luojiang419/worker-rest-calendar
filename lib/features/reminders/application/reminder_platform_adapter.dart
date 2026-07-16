import 'package:worker_rest_calendar/features/reminders/domain/scheduled_reminder.dart';

enum ReminderPermissionStatus { granted, systemDisabled, unsupported }

abstract interface class ReminderPlatformAdapter {
  Future<void> initialize({required void Function(String payload) onTap});

  Future<ReminderPermissionStatus> getPermissionStatus();

  Future<ReminderPermissionStatus> requestPermission();

  Future<int> replaceAll(
    List<ScheduledReminder> reminders, {
    required String timeZoneId,
  });

  Future<int> pendingCount();
}
