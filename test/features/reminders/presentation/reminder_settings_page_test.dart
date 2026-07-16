import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/app/app_dependencies.dart';
import 'package:worker_rest_calendar/core/database/app_database.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/core/theme/app_theme.dart';
import 'package:worker_rest_calendar/features/home/presentation/home_page.dart';
import 'package:worker_rest_calendar/features/reminders/application/reminder_controller.dart';
import 'package:worker_rest_calendar/features/reminders/application/reminder_platform_adapter.dart';
import 'package:worker_rest_calendar/features/reminders/domain/scheduled_reminder.dart';
import 'package:worker_rest_calendar/features/schedule/data/drift_schedule_repository.dart';
import 'package:worker_rest_calendar/features/settings/data/drift_settings_repository.dart';

import '../../../helpers/test_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('权限引导、提醒保存和通知点击日期详情完整可用', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    await DriftScheduleRepository(database).saveProfile(testProfile());
    final platform = _FakeReminderPlatform();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          reminderPlatformAdapterProvider.overrideWithValue(platform),
          currentDateProvider.overrideWithValue(
            () => CalendarDate(2026, 7, 13),
          ),
          localNowProvider.overrideWithValue(() => DateTime(2026, 7, 13, 10)),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: const HomePage(),
        ),
      ),
    );
    await _pumpUntilFound(tester, find.text('今天上班'));

    await tester.tap(find.byTooltip('提醒设置'));
    await tester.pumpAndSettle();
    expect(find.text('通知权限未开启或已被系统关闭'), findsOneWidget);
    await tester.tap(find.text('授权通知'));
    await tester.pumpAndSettle();
    expect(find.text('通知已开启'), findsOneWidget);

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    final preferences = await DriftSettingsRepository(
      database,
    ).getReminderPreferences();
    expect(preferences.dailyNextDayEnabled, isTrue);
    expect(platform.current, isNotEmpty);

    await tester.pageBack();
    await tester.pumpAndSettle();
    platform.tap('restcalendar://date/2026-07-18');
    await tester.pumpAndSettle();
    expect(find.text('2026年7月18日 周六'), findsOneWidget);
    expect(find.text('编辑当天'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await database.close();
  });
}

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 40; attempt++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  throw TestFailure('等待目标组件超时：$finder');
}

final class _FakeReminderPlatform implements ReminderPlatformAdapter {
  ReminderPermissionStatus status = ReminderPermissionStatus.systemDisabled;
  void Function(String payload)? _onTap;
  List<ScheduledReminder> current = [];

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
    status = ReminderPermissionStatus.granted;
    return status;
  }

  @override
  Future<int> replaceAll(
    List<ScheduledReminder> reminders, {
    required String timeZoneId,
  }) async {
    current = List.of(reminders);
    return current.length;
  }

  void tap(String payload) => _onTap?.call(payload);
}
