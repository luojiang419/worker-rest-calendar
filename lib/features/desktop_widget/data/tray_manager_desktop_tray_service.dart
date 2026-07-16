import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:worker_rest_calendar/core/theme/app_visual_style.dart';
import 'package:worker_rest_calendar/features/desktop_widget/application/desktop_tray_service.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

final class TrayManagerDesktopTrayService
    with TrayListener
    implements DesktopTrayService {
  TrayManagerDesktopTrayService({
    DateTime Function()? now,
    this.doubleClickInterval = const Duration(milliseconds: 500),
    bool? isSupported,
  }) : _now = now ?? DateTime.now,
       _isSupportedOverride = isSupported;

  final DateTime Function() _now;
  final Duration doubleClickInterval;
  final bool? _isSupportedOverride;
  Future<void> Function()? _onOpenApp;
  Future<void> Function()? _onExit;
  Future<void> Function(DesktopWidgetMenuAction action)? _onMenuAction;
  bool _initialized = false;
  DateTime? _lastLeftMouseDown;

  @override
  bool get isSupported => _isSupportedOverride ?? Platform.isWindows;

  @override
  Future<void> initialize({
    required Future<void> Function() onOpenApp,
    required Future<void> Function() onExit,
    required Future<void> Function(DesktopWidgetMenuAction action) onMenuAction,
  }) async {
    _onOpenApp = onOpenApp;
    _onExit = onExit;
    _onMenuAction = onMenuAction;
    if (!isSupported || _initialized) return;
    trayManager.addListener(this);
    _initialized = true;
  }

  @override
  Future<void> show() async {
    if (!isSupported) return;
    await trayManager.setIcon('assets/tray/app_icon.ico');
    await trayManager.setToolTip('工作日历');
  }

  @override
  Future<void> updateContextMenu(AppPreferences preferences) async {
    if (!isSupported) return;
    await trayManager.setContextMenu(desktopWidgetContextMenu(preferences));
  }

  @override
  Future<void> popUpContextMenu(AppPreferences preferences) async {
    if (!isSupported) return;
    await updateContextMenu(preferences);
    await trayManager.popUpContextMenu();
  }

  @override
  Future<void> hide() async {
    if (isSupported) await trayManager.destroy();
  }

  @override
  Future<void> dispose() async {
    if (!_initialized) return;
    trayManager.removeListener(this);
    _initialized = false;
    _onMenuAction = null;
    if (isSupported) await trayManager.destroy();
  }

  @override
  void onTrayIconMouseDown() {
    final now = _now();
    final previous = _lastLeftMouseDown;
    _lastLeftMouseDown = now;
    if (previous == null || now.difference(previous) > doubleClickInterval) {
      return;
    }
    _lastLeftMouseDown = null;
    final callback = _onOpenApp;
    if (callback != null) unawaited(callback());
  }

  @override
  void onTrayIconRightMouseDown() {
    unawaited(trayManager.popUpContextMenu());
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    final key = menuItem.key;
    if (key == null) return;
    final action = DesktopWidgetMenuAction.values
        .cast<DesktopWidgetMenuAction?>()
        .firstWhere((candidate) => candidate?.name == key, orElse: () => null);
    if (action == null) return;
    switch (action) {
      case DesktopWidgetMenuAction.openFullApp:
        final callback = _onOpenApp;
        if (callback != null) unawaited(callback());
      case DesktopWidgetMenuAction.exit:
        final callback = _onExit;
        if (callback != null) unawaited(callback());
      default:
        final callback = _onMenuAction;
        if (callback != null) unawaited(callback(action));
    }
  }
}

@visibleForTesting
Menu desktopWidgetContextMenu(AppPreferences preferences) => Menu(
  items: [
    MenuItem(key: DesktopWidgetMenuAction.openFullApp.name, label: '打开/置前主窗口'),
    _submenu('快捷打开', [
      MenuItem(key: DesktopWidgetMenuAction.openToday.name, label: '今天'),
      MenuItem(key: DesktopWidgetMenuAction.openCalendar.name, label: '日历'),
      MenuItem(key: DesktopWidgetMenuAction.openStatistics.name, label: '统计'),
      MenuItem.separator(),
      MenuItem(
        key: DesktopWidgetMenuAction.openReminderSettings.name,
        label: '提醒设置',
      ),
      MenuItem(
        key: DesktopWidgetMenuAction.openDataManagement.name,
        label: '数据与同步',
      ),
    ]),
    MenuItem(key: DesktopWidgetMenuAction.showWidget.name, label: '显示桌面摆件'),
    MenuItem.separator(),
    _submenu('摆件尺寸', [
      _checked(
        DesktopWidgetMenuAction.small,
        '小号',
        preferences.desktopWidgetSize == DesktopWidgetSize.small,
      ),
      _checked(
        DesktopWidgetMenuAction.medium,
        '中号',
        preferences.desktopWidgetSize == DesktopWidgetSize.medium,
      ),
      _checked(
        DesktopWidgetMenuAction.large,
        '大号',
        preferences.desktopWidgetSize == DesktopWidgetSize.large,
      ),
    ]),
    _submenu('大号日期样式', [
      _checked(
        DesktopWidgetMenuAction.largeDateRoundedRectangle,
        '圆角矩形',
        preferences.desktopWidgetLargeDateShape ==
            DesktopWidgetLargeDateShape.roundedRectangle,
      ),
      _checked(
        DesktopWidgetMenuAction.largeDateCircle,
        '圆形',
        preferences.desktopWidgetLargeDateShape ==
            DesktopWidgetLargeDateShape.circle,
      ),
    ]),
    _submenu('当日突出样式', [
      _checked(
        DesktopWidgetMenuAction.todayGlowOutline,
        '动态微光描边',
        preferences.desktopWidgetTodayHighlightStyle ==
            DesktopWidgetTodayHighlightStyle.glowOutline,
      ),
      _checked(
        DesktopWidgetMenuAction.todayFilled,
        '填充高亮',
        preferences.desktopWidgetTodayHighlightStyle ==
            DesktopWidgetTodayHighlightStyle.filled,
      ),
    ]),
    _submenu('显示层级', [
      _checked(
        DesktopWidgetMenuAction.lock,
        '锁定位置（桌面层）',
        preferences.desktopWidgetLocked,
      ),
      _checked(
        DesktopWidgetMenuAction.alwaysOnTop,
        '窗口置顶',
        preferences.desktopWidgetAlwaysOnTop,
        disabled: preferences.desktopWidgetLocked,
      ),
    ]),
    _submenu('透明度', [
      _checked(
        DesktopWidgetMenuAction.opacity70,
        '70%',
        preferences.desktopWidgetOpacity == 0.7,
      ),
      _checked(
        DesktopWidgetMenuAction.opacity80,
        '80%',
        preferences.desktopWidgetOpacity == 0.8,
      ),
      _checked(
        DesktopWidgetMenuAction.opacity90,
        '90%',
        preferences.desktopWidgetOpacity == 0.9,
      ),
      _checked(
        DesktopWidgetMenuAction.opacity100,
        '100%',
        preferences.desktopWidgetOpacity == 1,
      ),
    ]),
    _submenu('外观模式', [
      _checked(
        DesktopWidgetMenuAction.themeSystem,
        '跟随系统',
        preferences.themeMode == AppThemePreference.system,
      ),
      _checked(
        DesktopWidgetMenuAction.themeLight,
        '浅色',
        preferences.themeMode == AppThemePreference.light,
      ),
      _checked(
        DesktopWidgetMenuAction.themeDark,
        '暗黑',
        preferences.themeMode == AppThemePreference.dark,
      ),
    ]),
    _submenu('视觉风格', [
      _checked(
        DesktopWidgetMenuAction.visualClassic,
        '经典精致',
        preferences.visualStyle == AppVisualStyle.classic,
      ),
      _checked(
        DesktopWidgetMenuAction.visualFlat,
        '现代扁平',
        preferences.visualStyle == AppVisualStyle.flat,
      ),
      _checked(
        DesktopWidgetMenuAction.visualNeumorphic,
        '柔和拟物',
        preferences.visualStyle == AppVisualStyle.neumorphic,
      ),
      _checked(
        DesktopWidgetMenuAction.visualGlass,
        '通透玻璃',
        preferences.visualStyle == AppVisualStyle.glass,
      ),
      _checked(
        DesktopWidgetMenuAction.visualPaper,
        '静谧纸感',
        preferences.visualStyle == AppVisualStyle.paper,
      ),
    ]),
    MenuItem.separator(),
    _checked(
      DesktopWidgetMenuAction.launchAtStartup,
      '开机启动',
      preferences.desktopLaunchAtStartup,
    ),
    MenuItem(key: DesktopWidgetMenuAction.exit.name, label: '退出'),
  ],
);

MenuItem _submenu(String label, List<MenuItem> items) => MenuItem.submenu(
  label: label,
  submenu: Menu(items: items),
);

MenuItem _checked(
  DesktopWidgetMenuAction action,
  String label,
  bool checked, {
  bool disabled = false,
}) => MenuItem.checkbox(
  key: action.name,
  label: label,
  checked: checked,
  disabled: disabled,
);
