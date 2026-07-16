import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/app/app_dependencies.dart';
import 'package:worker_rest_calendar/core/database/app_database.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/core/theme/app_visual_style.dart';
import 'package:worker_rest_calendar/core/theme/theme_controller.dart';
import 'package:worker_rest_calendar/features/desktop_widget/application/desktop_activation_service.dart';
import 'package:worker_rest_calendar/features/desktop_widget/application/desktop_tray_service.dart';
import 'package:worker_rest_calendar/features/desktop_widget/application/desktop_widget_controller.dart';
import 'package:worker_rest_calendar/features/desktop_widget/application/desktop_widget_display_mode.dart';
import 'package:worker_rest_calendar/features/desktop_widget/application/desktop_window_service.dart';
import 'package:worker_rest_calendar/features/home/application/home_navigation_controller.dart';
import 'package:worker_rest_calendar/features/settings/data/drift_settings_repository.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

void main() {
  test('锁定摆件时关闭置顶、进入桌面层并在完整应用往返后恢复', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final repository = DriftSettingsRepository(database);
    final activation = _FakeDesktopActivationService();
    final window = _FakeDesktopWindowService();
    final tray = _FakeDesktopTrayService();
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        desktopActivationServiceProvider.overrideWithValue(activation),
        desktopWindowServiceProvider.overrideWithValue(window),
        desktopTrayServiceProvider.overrideWithValue(tray),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await database.close();
    });

    await container.read(desktopWidgetControllerProvider.future);
    container.read(desktopWidgetDisplayModeProvider.notifier).showWidget();
    expect(tray.visible, isTrue);
    expect(tray.lastPreferences?.visualStyle, AppVisualStyle.classic);
    final controller = container.read(desktopWidgetControllerProvider.notifier);
    await controller.showContextMenu();
    expect(tray.popupCount, 1);

    await tray.select(DesktopWidgetMenuAction.visualGlass);
    await tray.select(DesktopWidgetMenuAction.themeDark);
    expect(container.read(visualStyleProvider), AppVisualStyle.glass);
    expect(container.read(themeModeProvider), ThemeMode.dark);
    await controller.setSize(DesktopWidgetSize.large);
    await tray.select(DesktopWidgetMenuAction.largeDateCircle);
    await tray.select(DesktopWidgetMenuAction.todayFilled);
    await controller.setOpacity(0.8);
    await controller.setAlwaysOnTop(true);
    await controller.setLocked(true);
    await controller.setAlwaysOnTop(true);

    var stored = await repository.getAppPreferences();
    expect(stored.desktopWidgetSize, DesktopWidgetSize.large);
    expect(
      stored.desktopWidgetLargeDateShape,
      DesktopWidgetLargeDateShape.circle,
    );
    expect(
      stored.desktopWidgetTodayHighlightStyle,
      DesktopWidgetTodayHighlightStyle.filled,
    );
    expect(stored.desktopWidgetOpacity, 0.8);
    expect(stored.desktopWidgetLocked, isTrue);
    expect(stored.desktopWidgetAlwaysOnTop, isFalse);
    expect(window.lastSize, DesktopWidgetSize.large);
    expect(window.opacity, 0.8);
    expect(window.locked, isTrue);
    expect(window.alwaysOnTop, isFalse);
    expect(window.desktopLayer, isTrue);

    await activation.waitUntilListening();
    await activation.emit(
      DesktopActivationIntent(
        arguments: const ['restcalendar://date/2026-07-18'],
      ),
    );
    expect(
      container.read(desktopWidgetDisplayModeProvider),
      DesktopWidgetDisplayMode.fullApp,
    );
    expect(
      container.read(desktopWidgetControllerProvider).requireValue.selectedDate,
      CalendarDate(2026, 7, 18),
    );
    expect(window.fullAppShown, isTrue);
    expect(window.desktopLayer, isFalse);
    expect(window.alwaysOnTop, isFalse);
    expect(tray.visible, isTrue);

    await activation.emit(
      DesktopActivationIntent(
        arguments: const ['restcalendar://date/2026-07-19'],
      ),
    );
    expect(window.fullAppShowCount, 2);
    expect(window.lastFullAppConfigure, isFalse);
    expect(
      container.read(homeNavigationControllerProvider)?.selectedDate,
      CalendarDate(2026, 7, 19),
    );

    await repository.saveAppPreferences(
      stored.copyWith(
        themeMode: AppThemePreference.light,
        visualStyle: AppVisualStyle.paper,
      ),
    );

    await window.requestClose();
    expect(
      container.read(desktopWidgetDisplayModeProvider),
      DesktopWidgetDisplayMode.widget,
    );
    stored = await repository.getAppPreferences();
    expect(stored.desktopWidgetLocked, isTrue);
    expect(window.lastSize, DesktopWidgetSize.large);
    expect(window.opacity, 0.8);
    expect(window.locked, isTrue);
    expect(window.desktopLayer, isTrue);
    expect(tray.visible, isTrue);
    expect(container.read(themeModeProvider), ThemeMode.light);
    expect(container.read(visualStyleProvider), AppVisualStyle.paper);
    expect(tray.lastPreferences?.visualStyle, AppVisualStyle.paper);

    await tray.select(DesktopWidgetMenuAction.openStatistics);
    expect(
      container.read(homeNavigationControllerProvider)?.target,
      HomeNavigationTarget.statistics,
    );
    expect(tray.visible, isTrue);
    await tray.select(DesktopWidgetMenuAction.showWidget);
    expect(
      container.read(desktopWidgetControllerProvider).requireValue.showFullApp,
      isFalse,
    );

    await controller.exit();
    expect(tray.disposed, isTrue);
    expect(window.exited, isTrue);
  });

  test('启动期激活参数在控制器就绪前保留并直接打开目标日期', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final activation = _FakeDesktopActivationService(
      initial: [
        DesktopActivationIntent(
          arguments: const ['--url=restcalendar://date/2026-07-20'],
        ),
      ],
    );
    final window = _FakeDesktopWindowService();
    final tray = _FakeDesktopTrayService();
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        desktopActivationServiceProvider.overrideWithValue(activation),
        desktopWindowServiceProvider.overrideWithValue(window),
        desktopTrayServiceProvider.overrideWithValue(tray),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await database.close();
    });

    final state = await container.read(desktopWidgetControllerProvider.future);

    expect(state.showFullApp, isTrue);
    expect(state.selectedDate, CalendarDate(2026, 7, 20));
    expect(window.fullAppShown, isTrue);
    expect(window.lastSize, isNull);
    expect(tray.visible, isTrue);
  });

  test('退出立即并行关闭窗口且连续触发只执行一次', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final disposeBarrier = Completer<void>();
    final tray = _FakeDesktopTrayService(disposeBarrier: disposeBarrier);
    final window = _FakeDesktopWindowService();
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        desktopActivationServiceProvider.overrideWithValue(
          _FakeDesktopActivationService(),
        ),
        desktopWindowServiceProvider.overrideWithValue(window),
        desktopTrayServiceProvider.overrideWithValue(tray),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await database.close();
    });

    await container.read(desktopWidgetControllerProvider.future);
    final controller = container.read(desktopWidgetControllerProvider.notifier);
    final firstExit = controller.exit();
    final repeatedExit = controller.exit();
    await Future<void>.delayed(Duration.zero);

    expect(identical(firstExit, repeatedExit), isTrue);
    expect(tray.disposeCallCount, 1);
    expect(window.exitCallCount, 1);
    expect(window.exited, isTrue);

    disposeBarrier.complete();
    await firstExit;
  });
}

final class _FakeDesktopActivationService implements DesktopActivationService {
  _FakeDesktopActivationService({this.initial = const []});

  final List<DesktopActivationIntent> initial;
  DesktopActivationHandler? _handler;
  bool disposed = false;

  @override
  Future<List<DesktopActivationIntent>> initialize() async => initial;

  @override
  Future<void> startListening(DesktopActivationHandler handler) async {
    _handler = handler;
  }

  Future<void> waitUntilListening() async {
    for (var attempt = 0; attempt < 100; attempt++) {
      if (_handler != null) return;
      await Future<void>.delayed(Duration.zero);
    }
    fail('桌面激活监听器未启动');
  }

  Future<void> emit(DesktopActivationIntent intent) => _handler!(intent);

  @override
  Future<void> dispose() async {
    disposed = true;
    _handler = null;
  }
}

final class _FakeDesktopTrayService implements DesktopTrayService {
  _FakeDesktopTrayService({this.disposeBarrier});

  final Completer<void>? disposeBarrier;
  bool visible = false;
  bool disposed = false;
  int disposeCallCount = 0;
  Future<void> Function()? onOpenApp;
  Future<void> Function()? onExit;
  Future<void> Function(DesktopWidgetMenuAction action)? onMenuAction;
  AppPreferences? lastPreferences;
  int popupCount = 0;

  @override
  bool get isSupported => true;

  @override
  Future<void> initialize({
    required Future<void> Function() onOpenApp,
    required Future<void> Function() onExit,
    required Future<void> Function(DesktopWidgetMenuAction action) onMenuAction,
  }) async {
    this.onOpenApp = onOpenApp;
    this.onExit = onExit;
    this.onMenuAction = onMenuAction;
  }

  @override
  Future<void> show() async => visible = true;

  @override
  Future<void> hide() async => visible = false;

  @override
  Future<void> updateContextMenu(AppPreferences preferences) async {
    lastPreferences = preferences;
  }

  @override
  Future<void> popUpContextMenu(AppPreferences preferences) async {
    lastPreferences = preferences;
    popupCount += 1;
  }

  Future<void> select(DesktopWidgetMenuAction action) async {
    await onMenuAction!(action);
  }

  @override
  Future<void> dispose() async {
    disposeCallCount += 1;
    visible = false;
    disposed = true;
    await disposeBarrier?.future;
  }
}

final class _FakeDesktopWindowService implements DesktopWindowService {
  DesktopWidgetSize? lastSize;
  double? opacity;
  bool? locked;
  bool? alwaysOnTop;
  bool? desktopLayer;
  bool fullAppShown = false;
  int fullAppShowCount = 0;
  bool? lastFullAppConfigure;
  bool exited = false;
  int exitCallCount = 0;
  Future<void> Function()? onCloseRequested;

  @override
  bool get isSupported => true;

  @override
  Future<void> initialize({
    required Future<void> Function() onCloseRequested,
  }) async {
    this.onCloseRequested = onCloseRequested;
  }

  @override
  Future<void> showWidget(DesktopWidgetSize size) async => lastSize = size;

  @override
  Future<void> showFullApp({bool configure = true}) async {
    fullAppShown = true;
    fullAppShowCount += 1;
    lastFullAppConfigure = configure;
  }

  Future<void> requestClose() => onCloseRequested!();

  @override
  Future<void> setAlwaysOnTop(bool value) async => alwaysOnTop = value;

  @override
  Future<void> setDesktopLayer(bool value) async => desktopLayer = value;

  @override
  Future<void> setOpacity(double value) async => opacity = value;

  @override
  Future<void> setLocked(bool value) async => locked = value;

  @override
  Future<void> startDragging() async {}

  @override
  Future<void> setLaunchAtStartup(bool value) async {}

  @override
  Future<void> exit() async {
    exitCallCount += 1;
    exited = true;
  }
}
