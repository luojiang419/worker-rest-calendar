import 'package:drift/native.dart';
import 'package:test/test.dart';
import 'package:worker_rest_calendar/core/database/app_database.dart';
import 'package:worker_rest_calendar/core/theme/app_visual_style.dart';
import 'package:worker_rest_calendar/features/reminders/domain/reminder_preferences.dart';
import 'package:worker_rest_calendar/features/settings/data/drift_settings_repository.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

void main() {
  test('应用设置和提醒设置支持默认值、保存和监听', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftSettingsRepository(database);

    expect(
      (await repository.getAppPreferences()).themeMode,
      AppThemePreference.system,
    );
    expect(
      (await repository.getAppPreferences()).desktopWidgetLargeDateShape,
      DesktopWidgetLargeDateShape.roundedRectangle,
    );
    expect(
      (await repository.getAppPreferences()).desktopWidgetTodayHighlightStyle,
      DesktopWidgetTodayHighlightStyle.glowOutline,
    );
    expect(
      (await repository.getAppPreferences()).calendarScrollAxis,
      CalendarScrollAxis.horizontal,
    );
    expect(
      (await repository.getReminderPreferences()).dailyNextDayEnabled,
      isFalse,
    );

    await repository.saveAppPreferences(
      const AppPreferences(
        themeMode: AppThemePreference.dark,
        visualStyle: AppVisualStyle.paper,
        firstLaunchCompleted: true,
        desktopWidgetLargeDateShape: DesktopWidgetLargeDateShape.circle,
        desktopWidgetTodayHighlightStyle:
            DesktopWidgetTodayHighlightStyle.filled,
        desktopWidgetOpacity: 0.8,
        desktopLaunchAtStartup: true,
        calendarScrollAxis: CalendarScrollAxis.vertical,
      ),
    );
    await repository.saveReminderPreferences(
      const ReminderPreferences(
        dailyNextDayEnabled: true,
        dailyNextDayTime: '21:30',
        timeZoneId: 'Asia/Shanghai',
      ),
    );

    final app = await repository.getAppPreferences();
    final reminders = await repository.getReminderPreferences();
    expect(app.themeMode, AppThemePreference.dark);
    expect(app.visualStyle, AppVisualStyle.paper);
    expect(app.firstLaunchCompleted, isTrue);
    expect(app.desktopWidgetLargeDateShape, DesktopWidgetLargeDateShape.circle);
    expect(
      app.desktopWidgetTodayHighlightStyle,
      DesktopWidgetTodayHighlightStyle.filled,
    );
    expect(app.desktopWidgetOpacity, 0.8);
    expect(app.desktopLaunchAtStartup, isTrue);
    expect(app.calendarScrollAxis, CalendarScrollAxis.vertical);
    expect(reminders.dailyNextDayEnabled, isTrue);
    expect(reminders.dailyNextDayTime, '21:30');
    expect(reminders.timeZoneId, 'Asia/Shanghai');
  });
}
