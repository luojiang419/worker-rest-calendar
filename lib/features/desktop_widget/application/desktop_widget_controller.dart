import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_rest_calendar/app/app_dependencies.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/core/theme/app_visual_style.dart';
import 'package:worker_rest_calendar/core/theme/theme_controller.dart';
import 'package:worker_rest_calendar/features/desktop_widget/application/desktop_activation_service.dart';
import 'package:worker_rest_calendar/features/desktop_widget/application/desktop_tray_service.dart';
import 'package:worker_rest_calendar/features/desktop_widget/application/desktop_widget_display_mode.dart';
import 'package:worker_rest_calendar/features/desktop_widget/application/desktop_window_service.dart';
import 'package:worker_rest_calendar/features/desktop_widget/data/method_channel_desktop_activation_service.dart';
import 'package:worker_rest_calendar/features/desktop_widget/data/tray_manager_desktop_tray_service.dart';
import 'package:worker_rest_calendar/features/desktop_widget/data/window_manager_desktop_window_service.dart';
import 'package:worker_rest_calendar/features/home/application/home_navigation_controller.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

final desktopWindowServiceProvider = Provider<DesktopWindowService>(
  (ref) => WindowManagerDesktopWindowService(),
);

final desktopActivationServiceProvider = Provider<DesktopActivationService>(
  (ref) => MethodChannelDesktopActivationService(),
);

final desktopTrayServiceProvider = Provider<DesktopTrayService>(
  (ref) => TrayManagerDesktopTrayService(),
);

final desktopWidgetControllerProvider =
    AsyncNotifierProvider<DesktopWidgetController, DesktopWidgetState>(
      DesktopWidgetController.new,
    );

final class DesktopWidgetState {
  const DesktopWidgetState({
    required this.preferences,
    this.showFullApp = false,
    this.selectedDate,
  });

  final AppPreferences preferences;
  final bool showFullApp;
  final CalendarDate? selectedDate;

  DesktopWidgetState copyWith({
    AppPreferences? preferences,
    bool? showFullApp,
    CalendarDate? selectedDate,
  }) => DesktopWidgetState(
    preferences: preferences ?? this.preferences,
    showFullApp: showFullApp ?? this.showFullApp,
    selectedDate: selectedDate ?? this.selectedDate,
  );
}

final class DesktopWidgetController extends AsyncNotifier<DesktopWidgetState> {
  Future<void>? _exitOperation;

  DesktopWindowService get _window => ref.read(desktopWindowServiceProvider);
  DesktopTrayService get _tray => ref.read(desktopTrayServiceProvider);
  DesktopActivationService get _activation =>
      ref.read(desktopActivationServiceProvider);

  @override
  Future<DesktopWidgetState> build() async {
    final activation = _activation;
    final pendingActivations = await activation.initialize();
    ref.onDispose(() => unawaited(activation.dispose()));
    final initialActivation = pendingActivations.isEmpty
        ? null
        : pendingActivations.last;
    var preferences = await ref
        .watch(settingsRepositoryProvider)
        .getAppPreferences();
    if (preferences.desktopWidgetLocked &&
        preferences.desktopWidgetAlwaysOnTop) {
      preferences = preferences.copyWith(desktopWidgetAlwaysOnTop: false);
      await ref
          .read(settingsRepositoryProvider)
          .saveAppPreferences(preferences);
    }
    await _window.initialize(onCloseRequested: _handleWindowClose);
    final tray = _tray;
    await tray.initialize(
      onOpenApp: openFullApp,
      onExit: exit,
      onMenuAction: _handleMenuAction,
    );
    ref.onDispose(() => unawaited(tray.dispose()));
    if (_window.isSupported) {
      await tray.show();
      await tray.updateContextMenu(preferences);
      if (initialActivation == null) {
        await _window.showWidget(preferences.desktopWidgetSize);
        await _window.setAlwaysOnTop(preferences.desktopWidgetAlwaysOnTop);
        await _window.setDesktopLayer(preferences.desktopWidgetLocked);
        await _window.setOpacity(preferences.desktopWidgetOpacity);
        await _window.setLocked(preferences.desktopWidgetLocked);
      } else {
        await _window.setDesktopLayer(false);
        await _window.setAlwaysOnTop(false);
        await _window.setOpacity(1);
        await _window.showFullApp();
      }
    }
    ref
        .read(themeModeProvider.notifier)
        .setThemeMode(_themeMode(preferences.themeMode));
    ref
        .read(visualStyleProvider.notifier)
        .setVisualStyle(preferences.visualStyle);
    final initialState = DesktopWidgetState(
      preferences: preferences,
      showFullApp: initialActivation != null,
      selectedDate: initialActivation?.selectedDate,
    );
    final activationListener = Timer(
      Duration.zero,
      () => unawaited(activation.startListening(_handleActivation)),
    );
    ref.onDispose(activationListener.cancel);
    return initialState;
  }

  Future<void> setSize(DesktopWidgetSize value) async {
    await _updatePreferences(
      state.requireValue.preferences.copyWith(desktopWidgetSize: value),
    );
    if (!state.requireValue.showFullApp) await _window.showWidget(value);
  }

  Future<void> setType(DesktopWidgetType value) => _updatePreferences(
    state.requireValue.preferences.copyWith(desktopWidgetType: value),
  );

  Future<void> setNote(String value) => _updatePreferences(
    state.requireValue.preferences.copyWith(desktopWidgetNote: value),
    refreshTray: false,
  );

  Future<void> setLargeDateShape(DesktopWidgetLargeDateShape value) =>
      _updatePreferences(
        state.requireValue.preferences.copyWith(
          desktopWidgetLargeDateShape: value,
        ),
      );

  Future<void> setTodayHighlightStyle(DesktopWidgetTodayHighlightStyle value) =>
      _updatePreferences(
        state.requireValue.preferences.copyWith(
          desktopWidgetTodayHighlightStyle: value,
        ),
      );

  Future<void> setOpacity(double value) async {
    final normalized = value.clamp(0.7, 1).toDouble();
    await _updatePreferences(
      state.requireValue.preferences.copyWith(desktopWidgetOpacity: normalized),
    );
    if (!state.requireValue.showFullApp) await _window.setOpacity(normalized);
  }

  Future<void> setAlwaysOnTop(bool value) async {
    if (value && state.requireValue.preferences.desktopWidgetLocked) return;
    await _updatePreferences(
      state.requireValue.preferences.copyWith(desktopWidgetAlwaysOnTop: value),
    );
    if (!state.requireValue.showFullApp) {
      if (value) await _window.setDesktopLayer(false);
      await _window.setAlwaysOnTop(value);
    }
  }

  Future<void> setLocked(bool value) async {
    final preferences = state.requireValue.preferences.copyWith(
      desktopWidgetLocked: value,
      desktopWidgetAlwaysOnTop: value
          ? false
          : state.requireValue.preferences.desktopWidgetAlwaysOnTop,
    );
    await _updatePreferences(preferences);
    if (!state.requireValue.showFullApp) {
      if (value) await _window.setAlwaysOnTop(false);
      await _window.setDesktopLayer(value);
      await _window.setLocked(value);
    }
  }

  Future<void> setTheme(AppThemePreference value) async {
    await _updatePreferences(
      state.requireValue.preferences.copyWith(themeMode: value),
    );
    ref.read(themeModeProvider.notifier).setThemeMode(_themeMode(value));
  }

  Future<void> setVisualStyle(AppVisualStyle value) async {
    await _updatePreferences(
      state.requireValue.preferences.copyWith(visualStyle: value),
    );
    ref.read(visualStyleProvider.notifier).setVisualStyle(value);
  }

  Future<void> setLaunchAtStartup(bool value) async {
    await _window.setLaunchAtStartup(value);
    await _updatePreferences(
      state.requireValue.preferences.copyWith(desktopLaunchAtStartup: value),
    );
  }

  Future<void> setCalendarScrollAxis(CalendarScrollAxis value) =>
      _updatePreferences(
        state.requireValue.preferences.copyWith(calendarScrollAxis: value),
      );

  Future<void> openFullApp({
    CalendarDate? selectedDate,
    HomeNavigationTarget? destination,
  }) async {
    final current = state.requireValue;
    if (current.showFullApp) {
      await _window.showFullApp(configure: false);
      _requestNavigation(selectedDate: selectedDate, destination: destination);
      return;
    }
    ref.read(desktopWidgetDisplayModeProvider.notifier).showFullApp();
    state = AsyncData(
      DesktopWidgetState(
        preferences: current.preferences,
        showFullApp: true,
        selectedDate: selectedDate,
      ),
    );
    await _window.setDesktopLayer(false);
    await _window.setAlwaysOnTop(false);
    await _window.setOpacity(1);
    await _window.showFullApp();
    _requestNavigation(destination: destination);
  }

  Future<void> returnToWidget() async {
    final preferences = await ref
        .read(settingsRepositoryProvider)
        .getAppPreferences();
    await _tray.show();
    await _tray.updateContextMenu(preferences);
    ref.read(desktopWidgetDisplayModeProvider.notifier).showWidget();
    state = AsyncData(DesktopWidgetState(preferences: preferences));
    ref
        .read(themeModeProvider.notifier)
        .setThemeMode(_themeMode(preferences.themeMode));
    ref
        .read(visualStyleProvider.notifier)
        .setVisualStyle(preferences.visualStyle);
    await _window.showWidget(preferences.desktopWidgetSize);
    await _window.setOpacity(preferences.desktopWidgetOpacity);
    await _window.setAlwaysOnTop(preferences.desktopWidgetAlwaysOnTop);
    await _window.setDesktopLayer(preferences.desktopWidgetLocked);
    await _window.setLocked(preferences.desktopWidgetLocked);
  }

  Future<void> startDragging() => _window.startDragging();

  Future<void> showContextMenu() =>
      _tray.popUpContextMenu(state.requireValue.preferences);

  Future<void> exit() => _exitOperation ??= _performExit();

  Future<void> _performExit() async {
    await Future.wait<void>([_tray.dispose(), _window.exit()]);
  }

  Future<void> _handleActivation(DesktopActivationIntent intent) =>
      openFullApp(selectedDate: intent.selectedDate);

  Future<void> _handleWindowClose() async {
    if (!state.hasValue || !state.requireValue.showFullApp) return;
    await returnToWidget();
  }

  void _requestNavigation({
    CalendarDate? selectedDate,
    HomeNavigationTarget? destination,
  }) {
    final navigation = ref.read(homeNavigationControllerProvider.notifier);
    if (selectedDate != null) {
      navigation.openDate(selectedDate);
    } else if (destination != null) {
      navigation.open(destination);
    }
  }

  Future<void> _updatePreferences(
    AppPreferences preferences, {
    bool refreshTray = true,
  }) async {
    await ref.read(settingsRepositoryProvider).saveAppPreferences(preferences);
    state = AsyncData(state.requireValue.copyWith(preferences: preferences));
    ref.invalidate(appPreferencesProvider);
    if (refreshTray && !state.requireValue.showFullApp) {
      await _tray.updateContextMenu(preferences);
    }
  }

  Future<void> _handleMenuAction(DesktopWidgetMenuAction action) async {
    final preferences = state.requireValue.preferences;
    switch (action) {
      case DesktopWidgetMenuAction.openFullApp:
        await openFullApp();
      case DesktopWidgetMenuAction.openToday:
        await openFullApp(destination: HomeNavigationTarget.today);
      case DesktopWidgetMenuAction.openCalendar:
        await openFullApp(destination: HomeNavigationTarget.calendar);
      case DesktopWidgetMenuAction.openStatistics:
        await openFullApp(destination: HomeNavigationTarget.statistics);
      case DesktopWidgetMenuAction.openReminderSettings:
        await openFullApp(destination: HomeNavigationTarget.reminderSettings);
      case DesktopWidgetMenuAction.openDataManagement:
        await openFullApp(destination: HomeNavigationTarget.dataManagement);
      case DesktopWidgetMenuAction.showWidget:
        await returnToWidget();
      case DesktopWidgetMenuAction.typeSchedule:
        await setType(DesktopWidgetType.schedule);
      case DesktopWidgetMenuAction.typeClock:
        await setType(DesktopWidgetType.clock);
      case DesktopWidgetMenuAction.typeNote:
        await setType(DesktopWidgetType.note);
      case DesktopWidgetMenuAction.typeFocus:
        await setType(DesktopWidgetType.focus);
      case DesktopWidgetMenuAction.small:
        await setSize(DesktopWidgetSize.small);
      case DesktopWidgetMenuAction.medium:
        await setSize(DesktopWidgetSize.medium);
      case DesktopWidgetMenuAction.large:
        await setSize(DesktopWidgetSize.large);
      case DesktopWidgetMenuAction.largeDateRoundedRectangle:
        await setLargeDateShape(DesktopWidgetLargeDateShape.roundedRectangle);
      case DesktopWidgetMenuAction.largeDateCircle:
        await setLargeDateShape(DesktopWidgetLargeDateShape.circle);
      case DesktopWidgetMenuAction.todayGlowOutline:
        await setTodayHighlightStyle(
          DesktopWidgetTodayHighlightStyle.glowOutline,
        );
      case DesktopWidgetMenuAction.todayFilled:
        await setTodayHighlightStyle(DesktopWidgetTodayHighlightStyle.filled);
      case DesktopWidgetMenuAction.lock:
        await setLocked(!preferences.desktopWidgetLocked);
      case DesktopWidgetMenuAction.alwaysOnTop:
        await setAlwaysOnTop(!preferences.desktopWidgetAlwaysOnTop);
      case DesktopWidgetMenuAction.opacity70:
        await setOpacity(0.7);
      case DesktopWidgetMenuAction.opacity80:
        await setOpacity(0.8);
      case DesktopWidgetMenuAction.opacity90:
        await setOpacity(0.9);
      case DesktopWidgetMenuAction.opacity100:
        await setOpacity(1);
      case DesktopWidgetMenuAction.themeSystem:
        await setTheme(AppThemePreference.system);
      case DesktopWidgetMenuAction.themeLight:
        await setTheme(AppThemePreference.light);
      case DesktopWidgetMenuAction.themeDark:
        await setTheme(AppThemePreference.dark);
      case DesktopWidgetMenuAction.visualClassic:
        await setVisualStyle(AppVisualStyle.classic);
      case DesktopWidgetMenuAction.visualFlat:
        await setVisualStyle(AppVisualStyle.flat);
      case DesktopWidgetMenuAction.visualNeumorphic:
        await setVisualStyle(AppVisualStyle.neumorphic);
      case DesktopWidgetMenuAction.visualGlass:
        await setVisualStyle(AppVisualStyle.glass);
      case DesktopWidgetMenuAction.visualPaper:
        await setVisualStyle(AppVisualStyle.paper);
      case DesktopWidgetMenuAction.launchAtStartup:
        await setLaunchAtStartup(!preferences.desktopLaunchAtStartup);
      case DesktopWidgetMenuAction.exit:
        await exit();
    }
  }

  ThemeMode _themeMode(AppThemePreference value) => switch (value) {
    AppThemePreference.system => ThemeMode.system,
    AppThemePreference.light => ThemeMode.light,
    AppThemePreference.dark => ThemeMode.dark,
  };
}
