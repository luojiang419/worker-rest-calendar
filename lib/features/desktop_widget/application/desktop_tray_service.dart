import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

enum DesktopWidgetMenuAction {
  openFullApp,
  openToday,
  openCalendar,
  openStatistics,
  openReminderSettings,
  openDataManagement,
  showWidget,
  small,
  medium,
  large,
  largeDateRoundedRectangle,
  largeDateCircle,
  todayGlowOutline,
  todayFilled,
  lock,
  alwaysOnTop,
  opacity70,
  opacity80,
  opacity90,
  opacity100,
  themeSystem,
  themeLight,
  themeDark,
  visualClassic,
  visualFlat,
  visualNeumorphic,
  visualGlass,
  visualPaper,
  launchAtStartup,
  exit,
}

abstract interface class DesktopTrayService {
  bool get isSupported;

  Future<void> initialize({
    required Future<void> Function() onOpenApp,
    required Future<void> Function() onExit,
    required Future<void> Function(DesktopWidgetMenuAction action) onMenuAction,
  });

  Future<void> show();

  Future<void> updateContextMenu(AppPreferences preferences);

  Future<void> popUpContextMenu(AppPreferences preferences);

  Future<void> hide();

  Future<void> dispose();
}
