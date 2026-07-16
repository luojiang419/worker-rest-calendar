import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:window_manager/window_manager.dart';
import 'package:worker_rest_calendar/features/desktop_widget/application/desktop_window_service.dart';
import 'package:worker_rest_calendar/features/desktop_widget/data/desktop_window_bootstrap.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

void main() {
  test('Windows 首次启动使用完整应用尺寸而不是小号挂件尺寸', () {
    final options = desktopInitialWindowOptions(
      isWindows: true,
      hasStoredPosition: true,
    );

    expect(options.size, desktopFullAppWindowSize);
    expect(options.minimumSize, desktopFullAppMinimumSize);
    expect(options.title, '工作日历');
    expect(options.titleBarStyle, TitleBarStyle.normal);
    expect(options.center, isTrue);
    expect(options.backgroundColor, Colors.transparent);
    expect(
      options.size,
      isNot(desktopWidgetWindowSize(DesktopWidgetSize.small)),
    );
  });

  test('非 Windows 桌面端保持原有小号挂件启动参数', () {
    final options = desktopInitialWindowOptions(
      isWindows: false,
      hasStoredPosition: true,
    );

    expect(options.size, desktopWidgetWindowSize(DesktopWidgetSize.small));
    expect(options.minimumSize, isNull);
    expect(options.titleBarStyle, TitleBarStyle.hidden);
    expect(options.center, isFalse);
    expect(options.backgroundColor, Colors.transparent);
  });
}
