import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/app/app.dart';
import 'package:worker_rest_calendar/app/app_dependencies.dart';
import 'package:worker_rest_calendar/core/database/app_database.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/desktop_widget/data/desktop_window_bootstrap.dart';
import 'package:worker_rest_calendar/features/holidays/application/holiday_data_providers.dart';
import 'package:worker_rest_calendar/features/holidays/application/holiday_data_source.dart';
import 'package:worker_rest_calendar/features/holidays/data/holiday_data_codec.dart';
import 'package:worker_rest_calendar/features/holidays/domain/holiday_data_bundle.dart';
import 'package:worker_rest_calendar/features/onboarding/application/onboarding_draft_repository.dart';
import 'package:worker_rest_calendar/features/onboarding/domain/onboarding_draft.dart';
import 'package:worker_rest_calendar/features/schedule/application/active_schedule_controller.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_pattern.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late HolidayDataBundle bundledHolidays;

  setUpAll(() async {
    bundledHolidays = const HolidayDataCodec().decode(
      await File('assets/holidays/cn_2026.json').readAsString(),
    );
  });

  testWidgets('首次设置双休并进入正式今日首页', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    final draftRepository = _MemoryDraftRepository();
    await _setWideTestSurface(tester);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          holidayDataSourceProvider.overrideWithValue(
            _MemoryHolidayDataSource(bundledHolidays),
          ),
          desktopWidgetPlatformProvider.overrideWithValue(false),
          onboardingDraftRepositoryProvider.overrideWithValue(draftRepository),
          currentDateProvider.overrideWithValue(
            () => CalendarDate(2026, 7, 13),
          ),
          profileIdProvider.overrideWithValue(() => 'widget-profile'),
        ],
        child: const WorkerRestCalendarApp(),
      ),
    );
    await _pumpUntilFound(tester, find.text('先告诉我你的休息节奏'));

    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).title, '工作日历');
    expect(find.text('先告诉我你的休息节奏'), findsOneWidget);
    await tester.tap(find.text('开始设置'));
    await _pumpUntilFound(tester, find.text('选择你的班制'));

    expect(find.text('选择你的班制'), findsOneWidget);
    await tester.tap(find.text('双休').first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('下一步'));
    await _pumpUntilFound(tester, find.text('未来 30 天预览'));

    expect(find.text('未来 30 天预览'), findsOneWidget);
    expect(find.text('7/13'), findsOneWidget);
    await tester.tap(find.text('确认并进入今日'));
    await _pumpUntilFound(tester, find.text('今天上班'));

    expect(find.text('今天上班'), findsOneWidget);
    expect(find.text('本周节奏'), findsOneWidget);
    expect(find.text('本月概览'), findsOneWidget);
    final profiles = await containerScheduleProfiles(database);
    expect(profiles, hasLength(1));
    expect(profiles.single.isActive, isTrue);
    final holidays = await database.select(database.holidayOverrides).get();
    expect(holidays, hasLength(39));
    final container = ProviderScope.containerOf(
      tester.element(find.byType(WorkerRestCalendarApp)),
    );
    final activeSchedule = await container.read(
      activeScheduleControllerProvider.future,
    );
    expect(
      activeSchedule.day(CalendarDate(2026, 10, 1)).effectiveKind,
      DayKind.adjustedRest,
    );
    expect(activeSchedule.day(CalendarDate(2026, 10, 1)).note, '国庆节');
    expect(
      activeSchedule.day(CalendarDate(2026, 10, 10)).effectiveKind,
      DayKind.adjustedWork,
    );
    expect(activeSchedule.day(CalendarDate(2026, 10, 10)).note, '国庆节调休上班');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await database.close();
  });

  testWidgets('应用中断后直接恢复到大小周配置步骤', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    final draftRepository = _MemoryDraftRepository()
      ..draft = OnboardingDraft(
        step: OnboardingStep.configuration,
        patternType: SchedulePatternType.alternatingBigSmallWeek,
        anchorDate: CalendarDate(2026, 7, 13),
      );
    await _setWideTestSurface(tester);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          holidayDataSourceProvider.overrideWithValue(
            _MemoryHolidayDataSource(bundledHolidays),
          ),
          desktopWidgetPlatformProvider.overrideWithValue(false),
          onboardingDraftRepositoryProvider.overrideWithValue(draftRepository),
          currentDateProvider.overrideWithValue(
            () => CalendarDate(2026, 7, 13),
          ),
          profileIdProvider.overrideWithValue(() => 'widget-profile'),
        ],
        child: const WorkerRestCalendarApp(),
      ),
    );
    await _pumpUntilFound(tester, find.text('确认本周大小周'));

    expect(find.text('确认本周大小周'), findsOneWidget);
    expect(find.text('本周是大周还是小周？'), findsOneWidget);
    expect(find.text('大周'), findsOneWidget);
    expect(find.text('小周'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await database.close();
  });
}

Future<List<ScheduleProfileRow>> containerScheduleProfiles(
  AppDatabase database,
) => database.select(database.scheduleProfiles).get();

Future<void> _setWideTestSurface(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1200, 1800);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 120; attempt++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  final texts = find
      .byType(Text)
      .evaluate()
      .map((element) => (element.widget as Text).data)
      .whereType<String>()
      .toList();
  throw TestFailure('等待目标组件超时：$finder；当前文本：$texts');
}

final class _MemoryDraftRepository implements OnboardingDraftRepository {
  OnboardingDraft? draft;

  @override
  Future<void> clear() async => draft = null;

  @override
  Future<OnboardingDraft?> load() async => draft;

  @override
  Future<void> save(OnboardingDraft value) async => draft = value;
}

final class _MemoryHolidayDataSource implements HolidayDataSource {
  const _MemoryHolidayDataSource(this.bundle);

  final HolidayDataBundle bundle;

  @override
  Future<HolidayDataBundle> load() async => bundle;
}
