import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/core/theme/app_theme.dart';
import 'package:worker_rest_calendar/features/desktop_widget/presentation/desktop_focus_card.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

void main() {
  testWidgets('专注卡片可开始、暂停和重置', (tester) async {
    await _pumpFocus(tester, DesktopWidgetSize.medium);
    expect(find.text('25:00'), findsOneWidget);
    expect(find.text('准备开始'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('desktop-focus-toggle')));
    await tester.pump();
    expect(find.text('保持专注'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('desktop-focus-toggle')));
    await tester.pump();
    expect(find.text('已暂停'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('desktop-focus-reset')));
    await tester.pump();
    expect(find.text('准备开始'), findsOneWidget);
  });

  testWidgets('专注卡片三种尺寸与 130% 字体下无溢出', (tester) async {
    for (final size in DesktopWidgetSize.values) {
      await _pumpFocus(tester, size, textScale: 1.3);
      expect(tester.takeException(), isNull, reason: size.name);
    }
  });
}

Future<void> _pumpFocus(
  WidgetTester tester,
  DesktopWidgetSize size, {
  double textScale = 1,
}) async {
  final dimensions = switch (size) {
    DesktopWidgetSize.small => const Size(180, 220),
    DesktopWidgetSize.medium => const Size(360, 220),
    DesktopWidgetSize.large => const Size(420, 360),
  };
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = dimensions;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(
    ProviderScope(
      child: MediaQuery(
        data: MediaQueryData(
          size: dimensions,
          textScaler: TextScaler.linear(textScale),
        ),
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(body: DesktopFocusCard(size: size)),
        ),
      ),
    ),
  );
}
