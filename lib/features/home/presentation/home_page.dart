import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_rest_calendar/app/app_dependencies.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/core/theme/theme_controller.dart';
import 'package:worker_rest_calendar/features/calendar/application/calendar_controller.dart';
import 'package:worker_rest_calendar/features/calendar/presentation/calendar_page.dart';
import 'package:worker_rest_calendar/features/calendar/presentation/day_sheets.dart';
import 'package:worker_rest_calendar/features/home/application/home_navigation_controller.dart';
import 'package:worker_rest_calendar/features/home/presentation/theme_picker_sheet.dart';
import 'package:worker_rest_calendar/features/home/presentation/today_page.dart';
import 'package:worker_rest_calendar/features/home_widget/application/home_widget_sync_controller.dart';
import 'package:worker_rest_calendar/features/reminders/application/reminder_controller.dart';
import 'package:worker_rest_calendar/features/reminders/presentation/reminder_settings_page.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';
import 'package:worker_rest_calendar/features/settings/presentation/settings_page.dart';
import 'package:worker_rest_calendar/features/statistics/presentation/statistics_page.dart';
import 'package:worker_rest_calendar/features/sync/presentation/data_management_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key, this.initialDate, this.onReturnToWidget});

  final CalendarDate? initialDate;
  final VoidCallback? onReturnToWidget;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  var _selectedIndex = 0;
  CalendarDate? _scheduledHomeWidgetDate;
  int? _scheduledNavigationRequestId;

  @override
  void initState() {
    super.initState();
    final initialDate = widget.initialDate;
    if (initialDate != null) {
      _selectedIndex = 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openDateFromToday(initialDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final useNavigationRail = MediaQuery.sizeOf(context).width >= 840;
    ref.watch(reminderControllerProvider);
    ref.listen(notificationTargetDateProvider, (previous, next) {
      if (next != null && previous != next) {
        _openNotificationDate(next);
      }
    });
    final navigationRequest = ref.watch(homeNavigationControllerProvider);
    if (navigationRequest != null &&
        navigationRequest.id != _scheduledNavigationRequestId) {
      _scheduledNavigationRequestId = navigationRequest.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _handleNavigationRequest(navigationRequest);
        ref
            .read(homeNavigationControllerProvider.notifier)
            .clear(navigationRequest.id);
        _scheduledNavigationRequestId = null;
      });
    }
    final homeWidgetTarget = ref.watch(homeWidgetTargetDateProvider);
    if (homeWidgetTarget != null &&
        homeWidgetTarget != _scheduledHomeWidgetDate) {
      _scheduledHomeWidgetDate = homeWidgetTarget;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(homeWidgetTargetDateProvider.notifier).clear();
        _scheduledHomeWidgetDate = null;
        if (mounted) _openDateFromToday(homeWidgetTarget);
      });
    }
    final content = IndexedStack(
      index: _selectedIndex,
      children: [
        TodayPage(
          onEditToday: () => showDayEditorSheet(
            context: context,
            ref: ref,
            date: ref.read(todayProvider),
          ),
          onOpenDate: _openDateFromToday,
          onOpenReminders: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => const ReminderSettingsPage(),
            ),
          ),
          onOpenDataManagement: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => const DataManagementPage(),
            ),
          ),
          onOpenTheme: useNavigationRail ? null : _showThemePicker,
        ),
        CalendarPage(
          onOpenDay: (date) =>
              showDayDetailsSheet(context: context, ref: ref, date: date),
          onEditDay: (date) =>
              showDayEditorSheet(context: context, ref: ref, date: date),
        ),
        const StatisticsPage(),
        if (_selectedIndex == 3)
          SettingsPage(
            onOpenTheme: _showThemePicker,
            onOpenReminders: _openReminderSettings,
            onOpenDataManagement: _openDataManagement,
          )
        else
          const SizedBox.shrink(),
      ],
    );
    return Scaffold(
      body: useNavigationRail
          ? Row(
              children: [
                _DesktopNavigation(
                  selectedIndex: _selectedIndex,
                  onSelected: _selectDestination,
                  onReturnToWidget: widget.onReturnToWidget,
                  onSelectTheme: _showThemePicker,
                  onOpenSettings: () => _selectDestination(3),
                ),
                Expanded(child: content),
              ],
            )
          : content,
      bottomNavigationBar: useNavigationRail
          ? null
          : Container(
              decoration: BoxDecoration(
                color: tokens.colors.surface,
                border: Border(top: BorderSide(color: tokens.colors.border)),
                boxShadow: tokens.shadows.medium,
              ),
              child: NavigationBar(
                selectedIndex: _selectedIndex,
                backgroundColor: tokens.colors.surface,
                indicatorColor: tokens.colors.primary.withValues(alpha: 0.14),
                onDestinationSelected: _selectDestination,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.today_outlined),
                    selectedIcon: Icon(Icons.today_rounded),
                    label: '今天',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.calendar_month_outlined),
                    selectedIcon: Icon(Icons.calendar_month_rounded),
                    label: '日历',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.bar_chart_outlined),
                    selectedIcon: Icon(Icons.bar_chart_rounded),
                    label: '统计',
                  ),
                ],
              ),
            ),
    );
  }

  void _selectDestination(int index) => setState(() => _selectedIndex = index);

  void _openReminderSettings() => Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (context) => const ReminderSettingsPage()),
  );

  void _openDataManagement() => Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (context) => const DataManagementPage()),
  );

  Future<void> _showThemePicker() async {
    final repository = ref.read(settingsRepositoryProvider);
    final preferences = await repository.getAppPreferences();
    if (!mounted) return;
    await showThemePickerSheet(
      context: context,
      preferences: preferences,
      onChanged: _saveThemePreferences,
    );
  }

  void _saveThemePreferences(AppPreferences preferences) {
    unawaited(
      ref.read(settingsRepositoryProvider).saveAppPreferences(preferences),
    );
    ref
        .read(themeModeProvider.notifier)
        .setThemeMode(_themeMode(preferences.themeMode));
    ref
        .read(visualStyleProvider.notifier)
        .setVisualStyle(preferences.visualStyle);
  }

  ThemeMode _themeMode(AppThemePreference preference) => switch (preference) {
    AppThemePreference.system => ThemeMode.system,
    AppThemePreference.light => ThemeMode.light,
    AppThemePreference.dark => ThemeMode.dark,
  };

  void _openDateFromToday(CalendarDate date) {
    ref.read(calendarControllerProvider.notifier).selectDate(date);
    setState(() => _selectedIndex = 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        showDayDetailsSheet(context: context, ref: ref, date: date);
      }
    });
  }

  void _openNotificationDate(CalendarDate date) {
    ref.read(calendarControllerProvider.notifier).selectDate(date);
    setState(() => _selectedIndex = 1);
    ref.read(notificationTargetDateProvider.notifier).clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        showDayDetailsSheet(context: context, ref: ref, date: date);
      }
    });
  }

  void _handleNavigationRequest(HomeNavigationRequest request) {
    final selectedDate = request.selectedDate;
    if (selectedDate != null) {
      _openDateFromToday(selectedDate);
      return;
    }
    switch (request.target) {
      case HomeNavigationTarget.today:
        setState(() => _selectedIndex = 0);
      case HomeNavigationTarget.calendar:
        setState(() => _selectedIndex = 1);
      case HomeNavigationTarget.statistics:
        setState(() => _selectedIndex = 2);
      case HomeNavigationTarget.reminderSettings:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => const ReminderSettingsPage(),
          ),
        );
      case HomeNavigationTarget.dataManagement:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => const DataManagementPage(),
          ),
        );
      case null:
        return;
    }
  }
}

class _DesktopNavigation extends StatelessWidget {
  const _DesktopNavigation({
    required this.selectedIndex,
    required this.onSelected,
    required this.onReturnToWidget,
    required this.onSelectTheme,
    required this.onOpenSettings,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback? onReturnToWidget;
  final VoidCallback onSelectTheme;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      decoration: BoxDecoration(
        color: tokens.colors.surface,
        border: Border(right: BorderSide(color: tokens.colors.border)),
        boxShadow: tokens.shadows.low,
      ),
      child: SafeArea(
        child: SizedBox(
          width: 76,
          child: Column(
            children: [
              Expanded(
                child: NavigationRail(
                  selectedIndex: selectedIndex < 3 ? selectedIndex : null,
                  backgroundColor: tokens.colors.surface,
                  indicatorColor: tokens.colors.primary.withValues(alpha: 0.14),
                  labelType: NavigationRailLabelType.all,
                  groupAlignment: -0.78,
                  minWidth: 76,
                  onDestinationSelected: onSelected,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.today_outlined),
                      selectedIcon: Icon(Icons.today_rounded),
                      label: Text('今天'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.calendar_month_outlined),
                      selectedIcon: Icon(Icons.calendar_month_rounded),
                      label: Text('日历'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.bar_chart_outlined),
                      selectedIcon: Icon(Icons.bar_chart_rounded),
                      label: Text('统计'),
                    ),
                  ],
                ),
              ),
              if (onReturnToWidget != null) ...[
                IconButton.filledTonal(
                  tooltip: '返回桌面摆件',
                  onPressed: onReturnToWidget,
                  icon: const Icon(Icons.widgets_outlined),
                ),
                SizedBox(height: tokens.spacing.xs),
              ],
              IconButton.filledTonal(
                tooltip: '选择主题',
                onPressed: onSelectTheme,
                icon: const Icon(Icons.palette_outlined),
              ),
              SizedBox(height: tokens.spacing.xs),
              Padding(
                padding: EdgeInsets.only(bottom: tokens.spacing.sm),
                child: selectedIndex == 3
                    ? IconButton.filled(
                        tooltip: '设置',
                        onPressed: onOpenSettings,
                        icon: const Icon(Icons.settings_rounded),
                      )
                    : IconButton.filledTonal(
                        tooltip: '设置',
                        onPressed: onOpenSettings,
                        icon: const Icon(Icons.settings_outlined),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
