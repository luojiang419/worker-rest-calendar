import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'package:worker_rest_calendar/features/desktop_widget/data/window_manager_desktop_window_service.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Windows 系统关闭请求返回摆件并在恢复后移除任务栏按钮', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await windowManager.ensureInitialized();
    await windowManager.waitUntilReadyToShow();
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('窗口关闭回归验证'))),
    );

    final service = WindowManagerDesktopWindowService();
    var closeRequests = 0;
    var returningToWidget = false;
    await service.initialize(
      onCloseRequested: () async {
        closeRequests++;
        await service.showWidget(DesktopWidgetSize.small);
        returningToWidget = false;
      },
    );

    for (final minimized in [false, true]) {
      await service.showFullApp();
      expect(await windowManager.isSkipTaskbar(), isFalse);
      if (minimized) await windowManager.minimize();
      returningToWidget = true;
      // window_manager posts WM_SYSCOMMAND / SC_CLOSE, as does the taskbar.
      await windowManager.close();
      for (var attempt = 0; attempt < 100 && returningToWidget; attempt++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(returningToWidget, isFalse);
      expect(closeRequests, minimized ? 2 : 1);
      expect(await windowManager.isVisible(), isTrue);
      expect(await windowManager.isMinimized(), isFalse);
      expect(await windowManager.isSkipTaskbar(), isTrue);
      expect(await windowManager.getSize(), const Size(180, 220));
    }
    // Leave process teardown to the integration test runner so it can report.
    await windowManager.setPreventClose(false);
  }, skip: !Platform.isWindows);
}
