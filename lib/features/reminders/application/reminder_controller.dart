import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_rest_calendar/app/app_dependencies.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/reminders/application/reminder_platform_adapter.dart';
import 'package:worker_rest_calendar/features/reminders/domain/reminder_preferences.dart';
import 'package:worker_rest_calendar/features/reminders/domain/reminder_scheduler.dart';
import 'package:worker_rest_calendar/features/schedule/application/active_schedule_controller.dart';
import 'package:worker_rest_calendar/platform/notifications/flutter_local_notifications_adapter.dart';

final reminderPlatformAdapterProvider = Provider<ReminderPlatformAdapter>(
  (ref) => FlutterLocalNotificationsAdapter(),
);

final notificationTargetDateProvider =
    NotifierProvider<NotificationTargetDateController, CalendarDate?>(
      NotificationTargetDateController.new,
    );

final reminderControllerProvider =
    AsyncNotifierProvider<ReminderController, ReminderControllerState>(
      ReminderController.new,
      retry: (retryCount, error) => null,
    );

final class NotificationTargetDateController extends Notifier<CalendarDate?> {
  @override
  CalendarDate? build() => null;

  void open(CalendarDate date) => state = date;

  void clear() => state = null;
}

final class ReminderControllerState {
  const ReminderControllerState({
    required this.preferences,
    required this.permissionStatus,
    required this.pendingCount,
  });

  final ReminderPreferences preferences;
  final ReminderPermissionStatus permissionStatus;
  final int pendingCount;
}

final class ReminderController extends AsyncNotifier<ReminderControllerState> {
  @override
  Future<ReminderControllerState> build() async {
    final adapter = ref.watch(reminderPlatformAdapterProvider);
    await adapter.initialize(onTap: _handlePayload);
    final preferences = await ref
        .watch(settingsRepositoryProvider)
        .getReminderPreferences();
    final permissionStatus = await adapter.getPermissionStatus();

    ref.listen(scheduleRefreshEventProvider, (previous, next) {
      if (next != null && previous?.sequence != next.sequence) {
        unawaited(reschedule());
      }
    });

    final pendingCount = await _replacePlans(
      preferences,
      permissionStatus: permissionStatus,
    );
    return ReminderControllerState(
      preferences: preferences,
      permissionStatus: permissionStatus,
      pendingCount: pendingCount,
    );
  }

  Future<void> savePreferences(ReminderPreferences preferences) async {
    await ref
        .read(settingsRepositoryProvider)
        .saveReminderPreferences(preferences);
    final permissionStatus = state.requireValue.permissionStatus;
    final count = await _replacePlans(
      preferences,
      permissionStatus: permissionStatus,
    );
    state = AsyncData(
      ReminderControllerState(
        preferences: preferences,
        permissionStatus: permissionStatus,
        pendingCount: count,
      ),
    );
  }

  Future<void> requestPermission() async {
    final current = state.requireValue;
    final permissionStatus = await ref
        .read(reminderPlatformAdapterProvider)
        .requestPermission();
    final count = await _replacePlans(
      current.preferences,
      permissionStatus: permissionStatus,
    );
    state = AsyncData(
      ReminderControllerState(
        preferences: current.preferences,
        permissionStatus: permissionStatus,
        pendingCount: count,
      ),
    );
  }

  Future<void> refreshPermission() async {
    final current = state.requireValue;
    final permissionStatus = await ref
        .read(reminderPlatformAdapterProvider)
        .getPermissionStatus();
    final count = await _replacePlans(
      current.preferences,
      permissionStatus: permissionStatus,
    );
    state = AsyncData(
      ReminderControllerState(
        preferences: current.preferences,
        permissionStatus: permissionStatus,
        pendingCount: count,
      ),
    );
  }

  Future<void> reschedule() async {
    final current = state.value;
    if (current == null) {
      return;
    }
    final count = await _replacePlans(
      current.preferences,
      permissionStatus: current.permissionStatus,
    );
    if (ref.mounted) {
      state = AsyncData(
        ReminderControllerState(
          preferences: current.preferences,
          permissionStatus: current.permissionStatus,
          pendingCount: count,
        ),
      );
    }
  }

  Future<int> _replacePlans(
    ReminderPreferences preferences, {
    required ReminderPermissionStatus permissionStatus,
  }) async {
    final adapter = ref.read(reminderPlatformAdapterProvider);
    if (permissionStatus != ReminderPermissionStatus.granted ||
        !preferences.hasAnyReminderEnabled) {
      return adapter.replaceAll(const [], timeZoneId: preferences.timeZoneId);
    }
    final schedule = await ref.read(activeScheduleControllerProvider.future);
    final plans = ReminderScheduler(
      schedule.engine,
    ).build(preferences: preferences, nowLocal: ref.read(localNowProvider)());
    return adapter.replaceAll(plans, timeZoneId: preferences.timeZoneId);
  }

  void _handlePayload(String payload) {
    final match = RegExp(
      r'^restcalendar://date/(\d{4}-\d{2}-\d{2})$',
    ).firstMatch(payload);
    if (match == null) {
      return;
    }
    try {
      ref
          .read(notificationTargetDateProvider.notifier)
          .open(CalendarDate.parse(match.group(1)!));
    } on Object {
      // 忽略损坏或过期通知 payload，不让启动流程崩溃。
    }
  }
}
