import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/core/theme/app_visual_style.dart';
import 'package:worker_rest_calendar/features/desktop_widget/application/desktop_tray_service.dart';
import 'package:worker_rest_calendar/features/desktop_widget/data/tray_manager_desktop_tray_service.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

void main() {
  test('原生菜单使用分组子菜单并覆盖全部可执行动作', () {
    final menu = desktopWidgetContextMenu(
      const AppPreferences(
        themeMode: AppThemePreference.dark,
        visualStyle: AppVisualStyle.glass,
        desktopWidgetSize: DesktopWidgetSize.large,
        desktopWidgetLargeDateShape: DesktopWidgetLargeDateShape.circle,
        desktopWidgetTodayHighlightStyle:
            DesktopWidgetTodayHighlightStyle.filled,
        desktopWidgetOpacity: 0.8,
        desktopWidgetLocked: true,
        desktopLaunchAtStartup: true,
      ),
    );

    expect(
      menu.items
          ?.where((item) => item.type == 'submenu')
          .map((item) => item.label),
      ['快捷打开', '摆件尺寸', '大号日期样式', '当日突出样式', '显示层级', '透明度', '外观模式', '视觉风格'],
    );
    for (final action in DesktopWidgetMenuAction.values) {
      expect(menu.getMenuItem(action.name), isNotNull, reason: action.name);
    }
    expect(
      menu.getMenuItem(DesktopWidgetMenuAction.large.name)?.checked,
      isTrue,
    );
    expect(
      menu.getMenuItem(DesktopWidgetMenuAction.opacity80.name)?.checked,
      isTrue,
    );
    expect(
      menu.getMenuItem(DesktopWidgetMenuAction.largeDateCircle.name)?.checked,
      isTrue,
    );
    expect(
      menu.getMenuItem(DesktopWidgetMenuAction.todayFilled.name)?.checked,
      isTrue,
    );
    expect(
      menu.getMenuItem(DesktopWidgetMenuAction.themeDark.name)?.checked,
      isTrue,
    );
    expect(
      menu.getMenuItem(DesktopWidgetMenuAction.visualGlass.name)?.checked,
      isTrue,
    );
    expect(
      menu.getMenuItem(DesktopWidgetMenuAction.lock.name)?.checked,
      isTrue,
    );
    expect(
      menu.getMenuItem(DesktopWidgetMenuAction.alwaysOnTop.name)?.disabled,
      isTrue,
    );
    expect(
      menu.getMenuItem(DesktopWidgetMenuAction.launchAtStartup.name)?.checked,
      isTrue,
    );
  });

  test('托盘左键单击无动作且双击才打开主窗口', () async {
    var now = DateTime(2026, 7, 13, 12);
    var openCount = 0;
    final service = TrayManagerDesktopTrayService(
      now: () => now,
      isSupported: false,
    );
    await service.initialize(
      onOpenApp: () async => openCount += 1,
      onExit: () async {},
      onMenuAction: (_) async {},
    );

    service.onTrayIconMouseDown();
    expect(openCount, 0);
    now = now.add(const Duration(milliseconds: 600));
    service.onTrayIconMouseDown();
    expect(openCount, 0);
    now = now.add(const Duration(milliseconds: 100));
    service.onTrayIconMouseDown();
    await Future<void>.delayed(Duration.zero);

    expect(openCount, 1);
  });
}
