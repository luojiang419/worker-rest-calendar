import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/app/app_dependencies.dart';
import 'package:worker_rest_calendar/core/database/app_database.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/core/theme/app_theme.dart';
import 'package:worker_rest_calendar/core/widgets/app_card.dart';
import 'package:worker_rest_calendar/features/schedule/data/drift_schedule_repository.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_pattern.dart';
import 'package:worker_rest_calendar/features/statistics/presentation/statistics_page.dart';

import '../../../helpers/test_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('统计页显示可信月度口径并支持月份切换', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    final repository = DriftScheduleRepository(database);
    await repository.saveProfile(
      testProfile().copyWith(
        patternType: SchedulePatternType.doubleRest,
        clearAnchorWeekType: true,
      ),
    );
    await repository.saveDayOverride(
      testOverride(
        id: 'leave',
        date: CalendarDate(2026, 7, 6),
        kind: DayKind.leave,
      ),
    );
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          currentDateProvider.overrideWithValue(
            () => CalendarDate(2026, 7, 13),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: const Scaffold(body: StatisticsPage()),
        ),
      ),
    );
    await _pumpUntilFound(tester, find.text('2026年7月'));

    expect(find.text('计划工作'), findsOneWidget);
    expect(find.text('23天'), findsOneWidget);
    expect(find.text('实际工作'), findsOneWidget);
    expect(find.text('22天'), findsOneWidget);
    expect(find.text('请假'), findsOneWidget);
    expect(find.text('1天'), findsOneWidget);
    expect(find.text('连续工作'), findsOneWidget);
    expect(find.text('2026 年度节奏'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('下个月'));
    await tester.pumpAndSettle();
    expect(find.text('2026年8月'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await database.close();
  });

  testWidgets('1010x681 桌面统计卡片自动重排并铺满窗口', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    await DriftScheduleRepository(database).saveProfile(testProfile());
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1010, 681);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          currentDateProvider.overrideWithValue(
            () => CalendarDate(2026, 7, 13),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(body: StatisticsPage()),
        ),
      ),
    );
    await _pumpUntilFound(tester, find.text('2026 年度节奏'));

    final overviewCard = find.ancestor(
      of: find.text('月度概览'),
      matching: find.byType(AppCard),
    );
    final streakCard = find.ancestor(
      of: find.text('连续工作'),
      matching: find.byType(AppCard),
    );
    final annualCard = find.ancestor(
      of: find.text('2026 年度节奏'),
      matching: find.byType(AppCard),
    );
    expect(overviewCard, findsOneWidget);
    expect(streakCard, findsOneWidget);
    expect(annualCard, findsOneWidget);
    expect(
      tester.getTopLeft(overviewCard).dy,
      tester.getTopLeft(streakCard).dy,
    );
    expect(tester.getRect(annualCard).bottom, lessThanOrEqualTo(681));
    expect(tester.getRect(annualCard).bottom, greaterThanOrEqualTo(669));
    expect(tester.takeException(), isNull);

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
