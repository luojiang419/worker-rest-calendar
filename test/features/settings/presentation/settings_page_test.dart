import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/app/app_dependencies.dart';
import 'package:worker_rest_calendar/core/database/app_database.dart';
import 'package:worker_rest_calendar/core/theme/app_theme.dart';
import 'package:worker_rest_calendar/features/desktop_widget/application/desktop_activation_service.dart';
import 'package:worker_rest_calendar/features/desktop_widget/application/desktop_tray_service.dart';
import 'package:worker_rest_calendar/features/desktop_widget/application/desktop_widget_controller.dart';
import 'package:worker_rest_calendar/features/desktop_widget/application/desktop_window_service.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';
import 'package:worker_rest_calendar/features/settings/presentation/settings_page.dart';
import 'package:worker_rest_calendar/features/updater/application/update_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('设置页保存开机自启和上下滚动且完整主窗口不被摆件设置改变', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    final window = _FakeWindowService();
    var openedTheme = false;
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1010, 681);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          desktopWindowServiceProvider.overrideWithValue(window),
          desktopTrayServiceProvider.overrideWithValue(_FakeTrayService()),
          desktopActivationServiceProvider.overrideWithValue(
            _FakeActivationService(),
          ),
          updatePlatformSupportedProvider.overrideWithValue(false),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: SettingsPage(
            onOpenTheme: () => openedTheme = true,
            onOpenReminders: () {},
            onOpenDataManagement: () {},
          ),
        ),
      ),
    );
    await _pumpUntilFound(tester, find.text('开机自启'));

    expect(find.text('日历浏览'), findsOneWidget);
    await tester.tap(find.text('上下'));
    await tester.pumpAndSettle();
    var stored = await database.select(database.appSettings).getSingle();
    expect(stored.calendarScrollAxis, 'vertical');

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    stored = await database.select(database.appSettings).getSingle();
    expect(stored.desktopLaunchAtStartup, isTrue);
    expect(window.launchAtStartup, isTrue);

    await tester.ensureVisible(find.text('大'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('大'));
    await tester.pumpAndSettle();
    stored = await database.select(database.appSettings).getSingle();
    expect(stored.desktopWidgetSize, 'large');
    expect(window.widgetShowCount, 0);
    expect(window.opacity, 1);

    await tester.dragUntilVisible(
      find.text('外观与主题'),
      find.byType(ListView),
      const Offset(0, -300),
    );
    await tester.tap(find.text('外观与主题'));
    expect(openedTheme, isTrue);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await database.close();
  });
}

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 40; attempt++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('等待目标组件超时：$finder');
}

final class _FakeActivationService implements DesktopActivationService {
  @override
  Future<List<DesktopActivationIntent>> initialize() async => [
    DesktopActivationIntent(arguments: const []),
  ];

  @override
  Future<void> startListening(DesktopActivationHandler handler) async {}

  @override
  Future<void> dispose() async {}
}

final class _FakeTrayService implements DesktopTrayService {
  @override
  bool get isSupported => true;

  @override
  Future<void> initialize({
    required Future<void> Function() onOpenApp,
    required Future<void> Function() onExit,
    required Future<void> Function(DesktopWidgetMenuAction action) onMenuAction,
  }) async {}

  @override
  Future<void> show() async {}

  @override
  Future<void> updateContextMenu(AppPreferences preferences) async {}

  @override
  Future<void> popUpContextMenu(AppPreferences preferences) async {}

  @override
  Future<void> hide() async {}

  @override
  Future<void> dispose() async {}
}

final class _FakeWindowService implements DesktopWindowService {
  bool? launchAtStartup;
  var widgetShowCount = 0;
  var opacity = 1.0;

  @override
  bool get isSupported => true;

  @override
  Future<void> initialize({
    required Future<void> Function() onCloseRequested,
  }) async {}

  @override
  Future<void> showWidget(DesktopWidgetSize size) async {
    widgetShowCount++;
  }

  @override
  Future<void> showFullApp({bool configure = true}) async {}

  @override
  Future<void> setAlwaysOnTop(bool value) async {}

  @override
  Future<void> setDesktopLayer(bool value) async {}

  @override
  Future<void> setOpacity(double value) async => opacity = value;

  @override
  Future<void> setLocked(bool value) async {}

  @override
  Future<void> startDragging() async {}

  @override
  Future<void> setLaunchAtStartup(bool value) async {
    launchAtStartup = value;
  }

  @override
  Future<void> exit() async {}
}
