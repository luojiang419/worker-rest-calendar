import 'package:worker_rest_calendar/core/theme/app_visual_style.dart';

enum AppThemePreference { system, light, dark }

enum DesktopWidgetSize { small, medium, large }

enum DesktopWidgetLargeDateShape { roundedRectangle, circle }

enum DesktopWidgetTodayHighlightStyle { glowOutline, filled }

enum CalendarScrollAxis { horizontal, vertical }

final class AppPreferences {
  const AppPreferences({
    this.themeMode = AppThemePreference.system,
    this.visualStyle = AppVisualStyle.classic,
    this.locale = 'zh_CN',
    this.firstLaunchCompleted = false,
    this.desktopWidgetSize = DesktopWidgetSize.small,
    this.desktopWidgetLargeDateShape =
        DesktopWidgetLargeDateShape.roundedRectangle,
    this.desktopWidgetTodayHighlightStyle =
        DesktopWidgetTodayHighlightStyle.glowOutline,
    this.desktopWidgetOpacity = 1,
    this.desktopWidgetAlwaysOnTop = false,
    this.desktopWidgetLocked = false,
    this.desktopLaunchAtStartup = false,
    this.calendarScrollAxis = CalendarScrollAxis.horizontal,
  });

  final AppThemePreference themeMode;
  final AppVisualStyle visualStyle;
  final String locale;
  final bool firstLaunchCompleted;
  final DesktopWidgetSize desktopWidgetSize;
  final DesktopWidgetLargeDateShape desktopWidgetLargeDateShape;
  final DesktopWidgetTodayHighlightStyle desktopWidgetTodayHighlightStyle;
  final double desktopWidgetOpacity;
  final bool desktopWidgetAlwaysOnTop;
  final bool desktopWidgetLocked;
  final bool desktopLaunchAtStartup;
  final CalendarScrollAxis calendarScrollAxis;

  AppPreferences copyWith({
    AppThemePreference? themeMode,
    AppVisualStyle? visualStyle,
    String? locale,
    bool? firstLaunchCompleted,
    DesktopWidgetSize? desktopWidgetSize,
    DesktopWidgetLargeDateShape? desktopWidgetLargeDateShape,
    DesktopWidgetTodayHighlightStyle? desktopWidgetTodayHighlightStyle,
    double? desktopWidgetOpacity,
    bool? desktopWidgetAlwaysOnTop,
    bool? desktopWidgetLocked,
    bool? desktopLaunchAtStartup,
    CalendarScrollAxis? calendarScrollAxis,
  }) => AppPreferences(
    themeMode: themeMode ?? this.themeMode,
    visualStyle: visualStyle ?? this.visualStyle,
    locale: locale ?? this.locale,
    firstLaunchCompleted: firstLaunchCompleted ?? this.firstLaunchCompleted,
    desktopWidgetSize: desktopWidgetSize ?? this.desktopWidgetSize,
    desktopWidgetLargeDateShape:
        desktopWidgetLargeDateShape ?? this.desktopWidgetLargeDateShape,
    desktopWidgetTodayHighlightStyle:
        desktopWidgetTodayHighlightStyle ??
        this.desktopWidgetTodayHighlightStyle,
    desktopWidgetOpacity: desktopWidgetOpacity ?? this.desktopWidgetOpacity,
    desktopWidgetAlwaysOnTop:
        desktopWidgetAlwaysOnTop ?? this.desktopWidgetAlwaysOnTop,
    desktopWidgetLocked: desktopWidgetLocked ?? this.desktopWidgetLocked,
    desktopLaunchAtStartup:
        desktopLaunchAtStartup ?? this.desktopLaunchAtStartup,
    calendarScrollAxis: calendarScrollAxis ?? this.calendarScrollAxis,
  );
}
