import 'package:drift/native.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/app/app_dependencies.dart';
import 'package:worker_rest_calendar/core/database/app_database.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/core/theme/app_theme.dart';
import 'package:worker_rest_calendar/core/widgets/app_card.dart';
import 'package:worker_rest_calendar/features/calendar/application/calendar_controller.dart';
import 'package:worker_rest_calendar/features/home/presentation/home_page.dart';
import 'package:worker_rest_calendar/features/schedule/data/drift_schedule_repository.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/settings/data/drift_settings_repository.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

import '../../../helpers/test_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('首页与日历一致，保存覆盖实时生效，删除后恢复基础状态', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    final repository = DriftScheduleRepository(database);
    await repository.saveProfile(testProfile());
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 1800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          currentDateProvider.overrideWithValue(
            () => CalendarDate(2026, 7, 11),
          ),
          dayOverrideIdProvider.overrideWithValue(() => 'ui-override'),
          utcNowProvider.overrideWithValue(() => DateTime.utc(2026, 7, 11, 8)),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const HomePage()),
      ),
    );
    await _pumpUntilFound(tester, find.text('今天休息'));

    expect(find.text('今天休息'), findsOneWidget);
    await tester.tap(find.text('日历').last);
    await tester.pumpAndSettle();
    expect(find.text('2026年7月'), findsOneWidget);

    final todayCell = find.bySemanticsLabel(RegExp(r'2026年7月11日 周六，休息，今天'));
    expect(todayCell, findsOneWidget);
    await tester.tap(todayCell);
    await tester.pumpAndSettle();
    expect(find.text('编辑当天'), findsOneWidget);

    await tester.tap(find.text('编辑当天'));
    await tester.pumpAndSettle();
    expect(find.text('编辑 2026年7月11日 周六'), findsOneWidget);
    await tester.tap(find.text('调休上班'));
    await tester.enterText(find.byType(TextField).at(0), '60');
    await tester.enterText(find.byType(TextField).at(1), '临时值班');
    await tester.tap(find.text('保存当天调整'));
    await tester.pumpAndSettle();

    var stored = await repository.getDayOverrides('profile-1');
    expect(stored, hasLength(1));
    expect(stored.single.kind, DayKind.adjustedWork);
    expect(stored.single.overtimeMinutes, 60);
    expect(stored.single.note, '临时值班');
    expect(
      find.bySemanticsLabel(RegExp(r'7月11日.*调休上班.*已手动调整')),
      findsOneWidget,
    );

    await tester.tap(find.bySemanticsLabel(RegExp(r'7月11日.*调休上班.*已手动调整')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除当天调整'));
    await tester.pumpAndSettle();
    expect(find.text('删除当天调整后，将恢复为基础班制计算结果。'), findsOneWidget);
    await tester.tap(find.text('删除').last);
    await tester.pumpAndSettle();

    stored = await repository.getDayOverrides('profile-1');
    expect(stored, isEmpty);
    expect(
      find.bySemanticsLabel(RegExp(r'2026年7月11日 周六，休息，今天')),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await database.close();
  });

  testWidgets('886x563 低高度桌面月历完整显示六行且不越出窗口', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    await DriftScheduleRepository(database).saveProfile(testProfile());
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(886, 563);
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
        child: MaterialApp(theme: AppTheme.dark, home: const HomePage()),
      ),
    );
    await _pumpUntilFound(tester, find.text('今天上班'));
    await tester.tap(find.text('日历'));
    await tester.pumpAndSettle();

    final finalCell = find.bySemanticsLabel(RegExp(r'2026年8月9日'));
    expect(finalCell, findsOneWidget);
    final calendarCard = find.byType(AppCard);
    expect(calendarCard, findsOneWidget);
    expect(
      tester.getRect(calendarCard).bottom,
      lessThanOrEqualTo(tester.view.physicalSize.height),
    );
    expect(
      tester.getRect(calendarCard).bottom,
      greaterThanOrEqualTo(tester.view.physicalSize.height - 12),
    );
    expect(
      tester.getRect(finalCell).bottom,
      lessThanOrEqualTo(tester.getRect(calendarCard).bottom),
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await database.close();
  });

  testWidgets('横向月历按像素自由滚动并可停在两个月之间', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    await DriftScheduleRepository(database).saveProfile(testProfile());
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 1000);
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
        child: MaterialApp(theme: AppTheme.light, home: const HomePage()),
      ),
    );
    await _pumpUntilFound(tester, find.text('今天上班'));
    await tester.tap(find.text('日历'));
    await tester.pumpAndSettle();

    final pager = find.byKey(const ValueKey('calendar-month-pager'));
    expect(pager, findsOneWidget);
    final pageView = tester.widget<PageView>(pager);
    final pageController = pageView.controller!;
    final initialPage = pageController.page!;
    expect(pageView.scrollDirection, Axis.horizontal);
    expect(pageView.pageSnapping, isFalse);
    expect(pageView.physics, isA<ClampingScrollPhysics>());

    await tester.sendEventToBinding(
      PointerScrollEvent(
        position: tester.getCenter(pager),
        scrollDelta: const Offset(0, 120),
      ),
    );
    await tester.pumpAndSettle();
    expect(pageController.page, greaterThan(initialPage));
    expect(pageController.page, lessThan(initialPage + 0.5));
    expect(find.text('2026年7月'), findsOneWidget);
    expect(
      tester
          .widget<AnimatedOpacity>(
            find.byKey(const ValueKey('calendar-month-page-2026-7')),
          )
          .opacity,
      1,
    );
    expect(
      tester
          .widget<AnimatedOpacity>(
            find.byKey(const ValueKey('calendar-month-page-2026-8')),
          )
          .opacity,
      0.58,
    );

    await tester.timedDrag(
      pager,
      const Offset(-520, 0),
      const Duration(seconds: 1),
    );
    await tester.pumpAndSettle();
    expect(pageController.page, greaterThan(initialPage + 0.5));
    expect(pageController.page, lessThan(initialPage + 1));
    expect(find.text('2026年8月'), findsOneWidget);
    expect(
      tester
          .widget<AnimatedOpacity>(
            find.byKey(const ValueKey('calendar-month-page-2026-7')),
          )
          .opacity,
      0.58,
    );
    expect(
      tester
          .widget<AnimatedOpacity>(
            find.byKey(const ValueKey('calendar-month-page-2026-8')),
          )
          .opacity,
      1,
    );

    await tester.tap(find.byTooltip('下一个月'));
    await tester.pumpAndSettle();
    expect(find.text('2026年9月'), findsOneWidget);
    expect(pageController.page, initialPage + 2);

    await tester.tap(find.text('回到今天'));
    await tester.pumpAndSettle();
    expect(find.text('2026年7月'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(r'2026年7月13日.*今天')), findsOneWidget);
    final container = ProviderScope.containerOf(tester.element(pager));
    expect(
      container.read(calendarControllerProvider).selectedDate,
      CalendarDate(2026, 7, 13),
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await database.close();
  });

  testWidgets('设置为上下后月历纵向自由滚动且不吸附整月', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    await DriftScheduleRepository(database).saveProfile(testProfile());
    await DriftSettingsRepository(database).saveAppPreferences(
      const AppPreferences(
        firstLaunchCompleted: true,
        calendarScrollAxis: CalendarScrollAxis.vertical,
      ),
    );
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 1000);
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
        child: MaterialApp(theme: AppTheme.dark, home: const HomePage()),
      ),
    );
    await _pumpUntilFound(tester, find.text('今天上班'));
    await tester.tap(find.text('日历'));
    await tester.pumpAndSettle();

    final pager = find.byKey(const ValueKey('calendar-month-pager'));
    final pageView = tester.widget<PageView>(pager);
    final pageController = pageView.controller!;
    final initialPage = pageController.page!;
    expect(pageView.scrollDirection, Axis.vertical);
    expect(pageView.pageSnapping, isFalse);
    expect(pageView.physics, isA<ClampingScrollPhysics>());

    await tester.sendEventToBinding(
      PointerScrollEvent(
        position: tester.getCenter(pager),
        scrollDelta: const Offset(0, 140),
      ),
    );
    await tester.pumpAndSettle();

    expect(pageController.page, greaterThan(initialPage));
    expect(pageController.page, lessThan(initialPage + 0.5));
    expect(find.text('2026年7月'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('calendar-month-page-2026-8')),
      findsOneWidget,
    );
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
