import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/app/app_dependencies.dart';
import 'package:worker_rest_calendar/core/database/app_database.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/core/theme/app_theme.dart';
import 'package:worker_rest_calendar/core/theme/app_visual_style.dart';
import 'package:worker_rest_calendar/core/theme/theme_controller.dart';
import 'package:worker_rest_calendar/features/home/application/home_navigation_controller.dart';
import 'package:worker_rest_calendar/features/home/presentation/home_page.dart';
import 'package:worker_rest_calendar/features/home/presentation/today_page.dart';
import 'package:worker_rest_calendar/features/home/presentation/widgets/month_summary_card.dart';
import 'package:worker_rest_calendar/features/home/presentation/widgets/next_rest_countdown_card.dart';
import 'package:worker_rest_calendar/features/home_widget/application/home_widget_sync_controller.dart';
import 'package:worker_rest_calendar/features/schedule/application/schedule_repository.dart';
import 'package:worker_rest_calendar/features/schedule/data/drift_schedule_repository.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_profile.dart';
import 'package:worker_rest_calendar/features/schedule/domain/stored_day_override.dart';
import 'package:worker_rest_calendar/features/schedule/domain/stored_holiday_override.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

import '../../../helpers/test_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('今日首页展示 loading 状态', (tester) async {
    final pending = Completer<ScheduleProfile?>();
    await _pumpTodayPage(
      tester,
      repository: _TestScheduleRepository(() => pending.future),
    );

    expect(find.text('正在计算今天的安排'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    pending.complete();
  });

  testWidgets('今日首页展示 empty 状态', (tester) async {
    await _pumpTodayPage(
      tester,
      repository: _TestScheduleRepository(() async => null),
    );
    await _pumpUntilFound(tester, find.text('还没有设置班制'));

    expect(find.text('先选一个工作节奏，日历就会自动生成'), findsOneWidget);
  });

  testWidgets('今日首页展示 error 状态', (tester) async {
    await _pumpTodayPage(
      tester,
      repository: _TestScheduleRepository(
        () async => throw Exception('database unavailable'),
      ),
    );
    await _pumpUntilFound(tester, find.text('今日状态加载失败'));

    expect(find.text('请稍后重试'), findsOneWidget);
  });

  testWidgets('持续打开应用跨日后今日状态自动更新', (tester) async {
    var now = DateTime(2026, 7, 10, 23, 59, 30);
    final scheduler = _FakeCurrentDateTimerScheduler();
    final database = AppDatabase(NativeDatabase.memory());
    await DriftScheduleRepository(database).saveProfile(testProfile());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          localNowProvider.overrideWithValue(() => now),
          currentDateProvider.overrideWithValue(
            () => CalendarDate.fromDateTime(now),
          ),
          currentDateTimerFactoryProvider.overrideWithValue(scheduler.create),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: TodayPage(onEditToday: () {}, onOpenDate: (_) {}),
          ),
        ),
      ),
    );
    await _pumpUntilFound(tester, find.text('今天上班'));

    now = DateTime(2026, 7, 11, 0, 0, 0, 100);
    scheduler.fire();
    await tester.pump();

    expect(find.text('今天休息'), findsOneWidget);
    expect(find.text('今天上班'), findsNothing);
  });

  testWidgets('下次休息卡展示休息前的实际剩余工作日', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    await DriftScheduleRepository(database).saveProfile(
      testProfile().copyWith(
        anchorDate: CalendarDate(2026, 7, 13),
        anchorWeekType: WeekType.big,
      ),
    );
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          currentDateProvider.overrideWithValue(
            () => CalendarDate(2026, 7, 14),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: TodayPage(onEditToday: () {}, onOpenDate: (_) {}),
          ),
        ),
      ),
    );
    await _pumpUntilFound(tester, find.text('再上 3 天班'));

    expect(find.text('再上 3 天班'), findsOneWidget);
    expect(find.text('再上 4 天班'), findsNothing);
    expect(find.text('下次休息：7月18日 周六'), findsOneWidget);
  });

  testWidgets('暗黑主题和 130% 字体下首页与日历无溢出', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    await DriftScheduleRepository(database).saveProfile(testProfile());
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          currentDateProvider.overrideWithValue(
            () => CalendarDate(2026, 7, 11),
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
          home: const HomePage(),
        ),
      ),
    );
    await _pumpUntilFound(tester, find.text('今天休息'));
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('日历').last);
    await tester.pumpAndSettle();
    expect(find.text('2026年7月'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await database.close();
  });

  testWidgets('1086x680 桌面布局首屏完整显示四块核心内容', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    await DriftScheduleRepository(database).saveProfile(testProfile());
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1086, 680);
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
    await _pumpUntilFound(tester, find.text('本月概览'));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('今天上班'), findsOneWidget);
    expect(find.byType(NextRestCountdownCard), findsOneWidget);
    expect(find.text('本周节奏'), findsOneWidget);
    expect(find.text('本月概览'), findsOneWidget);
    expect(
      tester.getRect(find.byType(MonthSummaryCard)).bottom,
      lessThanOrEqualTo(tester.view.physicalSize.height),
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await database.close();
  });

  testWidgets('外部导航请求可打开统计、提醒设置和数据与同步', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    await DriftScheduleRepository(database).saveProfile(testProfile());
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1086, 680);
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
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HomePage)),
    );

    container
        .read(homeNavigationControllerProvider.notifier)
        .open(HomeNavigationTarget.statistics);
    await tester.pumpAndSettle();
    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).selectedIndex,
      2,
    );

    container
        .read(homeNavigationControllerProvider.notifier)
        .open(HomeNavigationTarget.reminderSettings);
    await tester.pumpAndSettle();
    expect(find.text('提醒设置'), findsOneWidget);
    Navigator.of(tester.element(find.text('提醒设置'))).pop();
    await tester.pumpAndSettle();

    container
        .read(homeNavigationControllerProvider.notifier)
        .open(HomeNavigationTarget.dataManagement);
    await tester.pumpAndSettle();
    expect(find.text('数据与同步'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await database.close();
  });

  testWidgets('320x568 和 130% 字体可滚动查看全部内容且不被导航遮挡', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    await DriftScheduleRepository(database).saveProfile(testProfile());
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
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

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    final todayList = find.descendant(
      of: find.byType(TodayPage),
      matching: find.byType(ListView),
    );
    await tester.dragUntilVisible(
      find.byType(MonthSummaryCard),
      todayList,
      const Offset(0, -240),
    );
    await tester.pumpAndSettle();

    final monthRect = tester.getRect(find.byType(MonthSummaryCard));
    final navigationTop = tester.getRect(find.byType(NavigationBar)).top;
    expect(monthRect.top, greaterThanOrEqualTo(0));
    expect(monthRect.bottom, lessThanOrEqualTo(navigationTop));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await database.close();
  });

  testWidgets('桌面主题入口可选外观模式和视觉风格并持久化', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    await DriftScheduleRepository(database).saveProfile(testProfile());
    var returnedToWidget = false;
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1086, 680);
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
        child: _ThemeHarness(onReturnToWidget: () => returnedToWidget = true),
      ),
    );
    await _pumpUntilFound(tester, find.byTooltip('选择主题'));

    final button = find.byTooltip('选择主题');
    final settingsButton = find.byTooltip('设置');
    final returnButton = find.byTooltip('返回桌面摆件');
    expect(button, findsOneWidget);
    expect(settingsButton, findsOneWidget);
    expect(returnButton, findsOneWidget);
    expect(
      tester.getRect(returnButton).bottom,
      lessThan(tester.getRect(button).top),
    );
    expect(
      tester.getRect(button).bottom,
      lessThan(tester.getRect(settingsButton).top),
    );
    expect(tester.getRect(settingsButton).bottom, lessThanOrEqualTo(680));
    await tester.tap(returnButton);
    expect(returnedToWidget, isTrue);
    await tester.tap(button);
    await _pumpUntilFound(tester, find.text('选择主题'));
    await tester.pumpAndSettle();
    expect(find.text('经典精致'), findsOneWidget);
    expect(find.text('现代扁平'), findsOneWidget);
    expect(find.text('柔和拟物'), findsOneWidget);
    expect(find.text('通透玻璃'), findsOneWidget);
    expect(find.text('静谧纸感'), findsOneWidget);

    await tester.ensureVisible(find.text('暗色'));
    await tester.tap(find.text('暗色'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('通透玻璃'));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(HomePage)),
    );
    expect(container.read(themeModeProvider), ThemeMode.dark);
    expect(container.read(visualStyleProvider), AppVisualStyle.glass);
    expect(
      (await container.read(settingsRepositoryProvider).getAppPreferences())
          .themeMode,
      AppThemePreference.dark,
    );
    expect(
      (await container.read(settingsRepositoryProvider).getAppPreferences())
          .visualStyle,
      AppVisualStyle.glass,
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await database.close();
  });

  testWidgets('主屏小组件日期深链打开对应日期详情', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    await DriftScheduleRepository(database).saveProfile(testProfile());
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
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HomePage)),
    );

    container
        .read(homeWidgetTargetDateProvider.notifier)
        .open(CalendarDate(2026, 7, 19));
    await tester.pumpAndSettle();

    expect(find.text('2026年7月19日 周日'), findsOneWidget);
    expect(find.text('休息'), findsWidgets);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await database.close();
  });
}

class _ThemeHarness extends ConsumerWidget {
  const _ThemeHarness({this.onReturnToWidget});

  final VoidCallback? onReturnToWidget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = ref.watch(visualStyleProvider);
    return MaterialApp(
      theme: AppTheme.lightFor(style),
      darkTheme: AppTheme.darkFor(style),
      themeMode: ref.watch(themeModeProvider),
      home: HomePage(onReturnToWidget: onReturnToWidget),
    );
  }
}

Future<void> _pumpTodayPage(
  WidgetTester tester, {
  required ScheduleRepository repository,
}) => tester.pumpWidget(
  ProviderScope(
    overrides: [
      scheduleRepositoryProvider.overrideWithValue(repository),
      currentDateProvider.overrideWithValue(() => CalendarDate(2026, 7, 11)),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      home: TodayPage(onEditToday: () {}, onOpenDate: (_) {}),
    ),
  ),
);

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 40; attempt++) {
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

final class _TestScheduleRepository implements ScheduleRepository {
  const _TestScheduleRepository(this._getActiveProfile);

  final Future<ScheduleProfile?> Function() _getActiveProfile;

  @override
  Future<ScheduleProfile?> getActiveProfile() => _getActiveProfile();

  @override
  Stream<ScheduleProfile?> watchActiveProfile() => const Stream.empty();

  @override
  Future<List<StoredDayOverride>> getDayOverrides(
    String profileId, {
    bool includeDeleted = false,
  }) async => const [];

  @override
  Future<List<StoredHolidayOverride>> getHolidayOverrides(
    String region,
  ) async => const [];

  @override
  Future<ScheduleProfile?> getProfile(String id) async => null;

  @override
  Future<List<ScheduleProfile>> getProfiles({
    bool includeDeleted = false,
  }) async => const [];

  @override
  Future<void> saveDayOverride(StoredDayOverride override) =>
      throw UnimplementedError();

  @override
  Future<void> saveHolidayOverrides(List<StoredHolidayOverride> overrides) =>
      throw UnimplementedError();

  @override
  Future<void> saveProfile(ScheduleProfile profile) =>
      throw UnimplementedError();

  @override
  Future<void> setActiveProfile(String id, {required DateTime updatedAt}) =>
      throw UnimplementedError();

  @override
  Future<void> softDeleteDayOverride({
    required String profileId,
    required CalendarDate date,
    required DateTime deletedAt,
  }) => throw UnimplementedError();

  @override
  Future<void> softDeleteProfile(String id, {required DateTime deletedAt}) =>
      throw UnimplementedError();
}

final class _FakeCurrentDateTimerScheduler {
  void Function()? _callback;
  _FakeCurrentDateTimer? _timer;

  Timer create(Duration delay, void Function() callback) {
    _callback = callback;
    return _timer = _FakeCurrentDateTimer();
  }

  void fire() {
    final callback = _callback!;
    _timer!._complete();
    callback();
  }
}

final class _FakeCurrentDateTimer implements Timer {
  var _isActive = true;

  @override
  bool get isActive => _isActive;

  @override
  int get tick => _isActive ? 0 : 1;

  @override
  void cancel() => _isActive = false;

  void _complete() => _isActive = false;
}
