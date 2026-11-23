import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_rest_calendar/app/app_dependencies.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/core/theme/theme_controller.dart';
import 'package:worker_rest_calendar/features/home_widget/application/home_widget_service.dart';
import 'package:worker_rest_calendar/features/home_widget/data/plugin_home_widget_service.dart';
import 'package:worker_rest_calendar/features/home_widget/domain/home_widget_snapshot.dart';
import 'package:worker_rest_calendar/features/schedule/application/active_schedule_controller.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

final homeWidgetServiceProvider = Provider<HomeWidgetService>(
  (ref) => const PluginHomeWidgetService(),
);

final homeWidgetTargetDateProvider =
    NotifierProvider<HomeWidgetTargetDateController, CalendarDate?>(
      HomeWidgetTargetDateController.new,
    );

final homeWidgetSyncControllerProvider =
    AsyncNotifierProvider<HomeWidgetSyncController, DateTime?>(
      HomeWidgetSyncController.new,
    );

final class HomeWidgetTargetDateController extends Notifier<CalendarDate?> {
  @override
  CalendarDate? build() => null;

  void open(CalendarDate date) => state = date;

  void clear() => state = null;
}

final class HomeWidgetSyncController extends AsyncNotifier<DateTime?> {
  StreamSubscription<Uri?>? _clickSubscription;

  @override
  Future<DateTime?> build() async {
    final service = ref.watch(homeWidgetServiceProvider);
    if (!service.isSupported) return null;

    _clickSubscription = service.widgetClicks.listen(_handleUri);
    ref.onDispose(() => _clickSubscription?.cancel());
    _handleUri(await service.initiallyLaunchedUri());

    final schedule = await ref.watch(activeScheduleControllerProvider.future);
    final theme = ref.watch(themeModeProvider);
    final generatedAt = ref.read(utcNowProvider)();
    final snapshot = HomeWidgetSnapshot.build(
      schedule: schedule,
      today: ref.watch(todayProvider),
      generatedAt: generatedAt,
      theme: _themePreference(theme),
    );
    await service.saveAndRefresh(snapshot);
    return generatedAt;
  }

  void refresh() => ref.invalidateSelf();

  void _handleUri(Uri? uri) {
    if (uri == null || uri.scheme != 'workerrestcalendar') return;
    final value = uri.queryParameters['date'];
    if (value == null) return;
    try {
      ref
          .read(homeWidgetTargetDateProvider.notifier)
          .open(CalendarDate.parse(value));
    } on FormatException {
      return;
    } on ArgumentError {
      return;
    }
  }

  AppThemePreference _themePreference(ThemeMode mode) => switch (mode) {
    ThemeMode.system => AppThemePreference.system,
    ThemeMode.light => AppThemePreference.light,
    ThemeMode.dark => AppThemePreference.dark,
  };
}
