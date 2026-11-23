import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/app/app_dependencies.dart';
import 'package:worker_rest_calendar/core/database/app_database.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/core/theme/theme_controller.dart';
import 'package:worker_rest_calendar/features/home_widget/application/home_widget_service.dart';
import 'package:worker_rest_calendar/features/home_widget/application/home_widget_sync_controller.dart';
import 'package:worker_rest_calendar/features/home_widget/domain/home_widget_snapshot.dart';
import 'package:worker_rest_calendar/features/schedule/application/active_schedule_controller.dart';
import 'package:worker_rest_calendar/features/schedule/data/drift_schedule_repository.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

import '../../../helpers/test_models.dart';

void main() {
  test('保存快照、前台刷新并接收指定日期深链', () async {
    final service = _FakeHomeWidgetService(
      initialUri: Uri.parse('workerrestcalendar://open?date=2026-07-19'),
    );
    final database = AppDatabase(NativeDatabase.memory());
    await DriftScheduleRepository(database).saveProfile(testProfile());
    final container = ProviderContainer(
      overrides: [
        homeWidgetServiceProvider.overrideWithValue(service),
        appDatabaseProvider.overrideWithValue(database),
        currentDateProvider.overrideWithValue(() => CalendarDate(2026, 7, 13)),
        utcNowProvider.overrideWithValue(() => DateTime.utc(2026, 7, 13, 8)),
        dayOverrideIdProvider.overrideWithValue(() => 'home-widget-override'),
      ],
    );
    addTearDown(() async {
      container.dispose();
      service.dispose();
      await database.close();
    });

    await container.read(homeWidgetSyncControllerProvider.future);

    expect(service.snapshots, hasLength(1));
    expect(service.snapshots.single.days, hasLength(62));
    expect(
      container.read(homeWidgetTargetDateProvider),
      CalendarDate(2026, 7, 19),
    );

    service.clicks.add(Uri.parse('workerrestcalendar://open?date=2026-07-20'));
    await Future<void>.delayed(Duration.zero);
    expect(
      container.read(homeWidgetTargetDateProvider),
      CalendarDate(2026, 7, 20),
    );

    container.read(homeWidgetSyncControllerProvider.notifier).refresh();
    await container.read(homeWidgetSyncControllerProvider.future);
    expect(service.snapshots, hasLength(2));

    await container
        .read(activeScheduleControllerProvider.notifier)
        .saveManualOverride(
          date: CalendarDate(2026, 7, 13),
          kind: DayKind.adjustedRest,
          overtimeMinutes: 0,
        );
    await container.read(homeWidgetSyncControllerProvider.future);
    expect(service.snapshots, hasLength(3));
    expect(service.snapshots.last.days.first.kind, DayKind.adjustedRest);

    container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
    await container.read(homeWidgetSyncControllerProvider.future);
    expect(service.snapshots, hasLength(4));
    expect(service.snapshots.last.theme, AppThemePreference.dark);
  });
}

final class _FakeHomeWidgetService implements HomeWidgetService {
  _FakeHomeWidgetService({this.initialUri});

  final Uri? initialUri;
  final StreamController<Uri?> clicks = StreamController.broadcast();
  final List<HomeWidgetSnapshot> snapshots = [];

  @override
  bool get isSupported => true;

  @override
  Stream<Uri?> get widgetClicks => clicks.stream;

  @override
  Future<Uri?> initiallyLaunchedUri() async => initialUri;

  @override
  Future<void> saveAndRefresh(HomeWidgetSnapshot snapshot) async {
    snapshots.add(snapshot);
  }

  void dispose() => clicks.close();
}
