import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:worker_rest_calendar/app/app_dependencies.dart';
import 'package:worker_rest_calendar/core/database/app_database.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/home_widget/application/home_widget_service.dart';
import 'package:worker_rest_calendar/features/home_widget/application/home_widget_sync_controller.dart';
import 'package:worker_rest_calendar/features/home_widget/domain/home_widget_snapshot.dart';
import 'package:worker_rest_calendar/features/onboarding/application/onboarding_controller.dart';
import 'package:worker_rest_calendar/features/onboarding/application/onboarding_draft_repository.dart';
import 'package:worker_rest_calendar/features/onboarding/domain/onboarding_draft.dart';
import 'package:worker_rest_calendar/features/reminders/application/reminder_controller.dart';
import 'package:worker_rest_calendar/features/reminders/application/reminder_platform_adapter.dart';
import 'package:worker_rest_calendar/features/reminders/domain/scheduled_reminder.dart';
import 'package:worker_rest_calendar/features/schedule/application/active_schedule_controller.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_pattern.dart';
import 'package:worker_rest_calendar/features/sync/application/backup_file_gateway.dart';
import 'package:worker_rest_calendar/features/sync/application/data_management_controller.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('首次设置到备份恢复的 Windows/Android 发布关键流程', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    final draftRepository = _MemoryDraftRepository();
    final reminderPlatform = _FakeReminderPlatform();
    final homeWidgetService = _FakeHomeWidgetService();
    final fileGateway = _MemoryBackupFileGateway();
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        onboardingDraftRepositoryProvider.overrideWithValue(draftRepository),
        reminderPlatformAdapterProvider.overrideWithValue(reminderPlatform),
        homeWidgetServiceProvider.overrideWithValue(homeWidgetService),
        backupFileGatewayProvider.overrideWithValue(fileGateway),
        currentDateProvider.overrideWithValue(() => CalendarDate(2026, 7, 13)),
        localNowProvider.overrideWithValue(() => DateTime(2026, 7, 13, 10)),
        utcNowProvider.overrideWithValue(() => DateTime.utc(2026, 7, 13, 10)),
        profileIdProvider.overrideWithValue(() => 'release-profile'),
        dayOverrideIdProvider.overrideWithValue(() => 'release-override'),
      ],
    );

    try {
      await container.read(onboardingControllerProvider.future);
      final onboarding = container.read(onboardingControllerProvider.notifier);
      await onboarding.start();
      await onboarding.selectPattern(
        SchedulePatternType.alternatingBigSmallWeek,
      );
      expect(await onboarding.continueFromPattern(), isNull);
      await onboarding.setAnchorWeekType(WeekType.small);
      expect(await onboarding.continueFromConfiguration(), isNull);
      expect(await onboarding.complete(), isNull);

      var schedule = await container.read(
        activeScheduleControllerProvider.future,
      );
      expect(
        schedule.day(CalendarDate(2026, 7, 18)).effectiveKind,
        DayKind.work,
      );
      expect(
        schedule.day(CalendarDate(2026, 7, 19)).effectiveKind,
        DayKind.rest,
      );

      final homeWidgetSubscription = container.listen(
        homeWidgetSyncControllerProvider,
        (previous, next) {},
        fireImmediately: true,
      );
      await container.read(homeWidgetSyncControllerProvider.future);
      expect(homeWidgetService.snapshots, hasLength(1));

      final reminder = await container.read(reminderControllerProvider.future);
      await container
          .read(reminderControllerProvider.notifier)
          .savePreferences(
            reminder.preferences.copyWith(
              dailyNextDayEnabled: true,
              weeklyPreviewEnabled: true,
            ),
          );
      expect(reminderPlatform.current, isNotEmpty);

      await container
          .read(activeScheduleControllerProvider.notifier)
          .saveManualOverride(
            date: CalendarDate(2026, 7, 18),
            kind: DayKind.adjustedRest,
            overtimeMinutes: 0,
            note: '发布验收',
          );
      await _waitUntil(() => homeWidgetService.snapshots.length >= 2);
      expect(
        homeWidgetService.snapshots.last.days
            .firstWhere((day) => day.date == CalendarDate(2026, 7, 18))
            .kind,
        DayKind.adjustedRest,
      );
      homeWidgetSubscription.close();

      await container.read(dataManagementControllerProvider.future);
      final dataManagement = container.read(
        dataManagementControllerProvider.notifier,
      );
      await dataManagement.exportData();
      expect(fileGateway.savedJson, isNotNull);

      expect(await dataManagement.clearAllData(), isTrue);
      expect(
        await container.read(scheduleRepositoryProvider).getActiveProfile(),
        isNull,
      );

      fileGateway.fileToOpen = SelectedBackupFile(
        name: 'release-backup.json',
        contents: fileGateway.savedJson!,
      );
      await dataManagement.selectImport();
      expect(
        container.read(dataManagementControllerProvider).requireValue.preview,
        isNotNull,
      );
      expect(await dataManagement.confirmImport(), isTrue);

      schedule = await container.read(activeScheduleControllerProvider.future);
      expect(schedule.profile.id, 'release-profile');
      expect(
        schedule.day(CalendarDate(2026, 7, 18)).effectiveKind,
        DayKind.adjustedRest,
      );
      final restoredReminder = await container
          .read(settingsRepositoryProvider)
          .getReminderPreferences();
      expect(restoredReminder.dailyNextDayEnabled, isTrue);
      expect(restoredReminder.weeklyPreviewEnabled, isTrue);
    } finally {
      container.dispose();
      homeWidgetService.dispose();
      await database.close();
    }
  });
}

Future<void> _waitUntil(bool Function() condition) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    if (condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  throw TestFailure('等待跨模块刷新超时');
}

final class _MemoryDraftRepository implements OnboardingDraftRepository {
  OnboardingDraft? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<OnboardingDraft?> load() async => value;

  @override
  Future<void> save(OnboardingDraft value) async => this.value = value;
}

final class _FakeReminderPlatform implements ReminderPlatformAdapter {
  List<ScheduledReminder> current = [];

  @override
  Future<ReminderPermissionStatus> getPermissionStatus() async =>
      ReminderPermissionStatus.granted;

  @override
  Future<void> initialize({
    required void Function(String payload) onTap,
  }) async {}

  @override
  Future<int> pendingCount() async => current.length;

  @override
  Future<ReminderPermissionStatus> requestPermission() async =>
      ReminderPermissionStatus.granted;

  @override
  Future<int> replaceAll(
    List<ScheduledReminder> reminders, {
    required String timeZoneId,
  }) async {
    current = List.of(reminders);
    return current.length;
  }
}

final class _FakeHomeWidgetService implements HomeWidgetService {
  final StreamController<Uri?> _clicks = StreamController.broadcast();
  final List<HomeWidgetSnapshot> snapshots = [];

  @override
  bool get isSupported => true;

  @override
  Future<Uri?> initiallyLaunchedUri() async => null;

  @override
  Future<void> saveAndRefresh(HomeWidgetSnapshot snapshot) async {
    snapshots.add(snapshot);
  }

  @override
  Stream<Uri?> get widgetClicks => _clicks.stream;

  void dispose() => _clicks.close();
}

final class _MemoryBackupFileGateway implements BackupFileGateway {
  String? savedJson;
  SelectedBackupFile? fileToOpen;

  @override
  Future<SelectedBackupFile?> openJson() async => fileToOpen;

  @override
  Future<String?> saveJson({
    required String suggestedName,
    required String json,
  }) async {
    savedJson = json;
    return suggestedName;
  }
}
