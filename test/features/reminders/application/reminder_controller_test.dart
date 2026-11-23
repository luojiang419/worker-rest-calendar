import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/app/app_dependencies.dart';
import 'package:worker_rest_calendar/core/database/app_database.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/reminders/application/reminder_controller.dart';
import 'package:worker_rest_calendar/features/reminders/application/reminder_platform_adapter.dart';
import 'package:worker_rest_calendar/features/reminders/domain/scheduled_reminder.dart';
import 'package:worker_rest_calendar/features/schedule/application/active_schedule_controller.dart';
import 'package:worker_rest_calendar/features/schedule/data/drift_schedule_repository.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';

import '../../../helpers/test_models.dart';

void main() {
  late AppDatabase database;
  late ProviderContainer container;
  late _FakeReminderPlatform platform;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    await DriftScheduleRepository(database).saveProfile(testProfile());
    platform = _FakeReminderPlatform(ReminderPermissionStatus.granted);
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        reminderPlatformAdapterProvider.overrideWithValue(platform),
        currentDateProvider.overrideWithValue(() => CalendarDate(2026, 7, 13)),
        localNowProvider.overrideWithValue(() => DateTime(2026, 7, 13, 10)),
        utcNowProvider.overrideWithValue(() => DateTime.utc(2026, 7, 13, 10)),
        dayOverrideIdProvider.overrideWithValue(() => 'reminder-override'),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  test('设置变化和排班修改都会稳定替换旧通知', () async {
    final initial = await container.read(reminderControllerProvider.future);
    expect(initial.permissionStatus, ReminderPermissionStatus.granted);
    expect(platform.replacementHistory, hasLength(1));

    final preferences = initial.preferences.copyWith(
      dailyNextDayEnabled: true,
      adjustedWorkEnabled: true,
      countdownEnabled: true,
    );
    await container
        .read(reminderControllerProvider.notifier)
        .savePreferences(preferences);
    expect(platform.current, isNotEmpty);
    final oldIds = platform.current.map((item) => item.id).toSet();

    await container.read(activeScheduleControllerProvider.future);
    await container
        .read(activeScheduleControllerProvider.notifier)
        .saveManualOverride(
          date: CalendarDate(2026, 7, 18),
          kind: DayKind.adjustedWork,
          overtimeMinutes: 0,
        );
    await _waitForReplacements(platform, 3);

    expect(platform.replacementHistory, hasLength(3));
    expect(
      platform.current.any(
        (item) =>
            item.type == ReminderType.adjustedWork &&
            item.targetDate == CalendarDate(2026, 7, 18),
      ),
      isTrue,
    );
    expect(platform.current.map((item) => item.id).toSet(), isNot(oldIds));
  });

  test('权限关闭时清空计划，授权后重新生成', () async {
    platform.status = ReminderPermissionStatus.systemDisabled;
    final initial = await container.read(reminderControllerProvider.future);

    expect(initial.permissionStatus, ReminderPermissionStatus.systemDisabled);
    expect(platform.current, isEmpty);

    platform.requestResult = ReminderPermissionStatus.granted;
    await container
        .read(reminderControllerProvider.notifier)
        .savePreferences(
          initial.preferences.copyWith(dailyNextDayEnabled: true),
        );
    await container
        .read(reminderControllerProvider.notifier)
        .requestPermission();

    final granted = container.read(reminderControllerProvider).requireValue;
    expect(granted.permissionStatus, ReminderPermissionStatus.granted);
    expect(granted.pendingCount, greaterThan(0));
  });

  test('通知点击 payload 深链到日期且损坏 payload 被忽略', () async {
    await container.read(reminderControllerProvider.future);

    platform.tap('restcalendar://date/2026-07-18');
    expect(
      container.read(notificationTargetDateProvider),
      CalendarDate(2026, 7, 18),
    );

    platform.tap('restcalendar://date/not-a-date');
    expect(
      container.read(notificationTargetDateProvider),
      CalendarDate(2026, 7, 18),
    );
  });
}

Future<void> _waitForReplacements(
  _FakeReminderPlatform platform,
  int count,
) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    if (platform.replacementHistory.length >= count) {
      return;
    }
    await Future<void>.delayed(Duration.zero);
  }
  throw TestFailure('等待通知重排超时');
}

final class _FakeReminderPlatform implements ReminderPlatformAdapter {
  _FakeReminderPlatform(this.status) : requestResult = status;

  ReminderPermissionStatus status;
  ReminderPermissionStatus requestResult;
  void Function(String payload)? _onTap;
  List<ScheduledReminder> current = [];
  final List<List<ScheduledReminder>> replacementHistory = [];

  @override
  Future<ReminderPermissionStatus> getPermissionStatus() async => status;

  @override
  Future<void> initialize({
    required void Function(String payload) onTap,
  }) async {
    _onTap = onTap;
  }

  @override
  Future<int> pendingCount() async => current.length;

  @override
  Future<ReminderPermissionStatus> requestPermission() async {
    status = requestResult;
    return status;
  }

  @override
  Future<int> replaceAll(
    List<ScheduledReminder> reminders, {
    required String timeZoneId,
  }) async {
    current = List.of(reminders);
    replacementHistory.add(List.of(reminders));
    return current.length;
  }

  void tap(String payload) => _onTap?.call(payload);
}
