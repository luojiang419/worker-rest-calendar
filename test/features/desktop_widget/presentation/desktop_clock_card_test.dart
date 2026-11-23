import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/core/theme/app_theme.dart';
import 'package:worker_rest_calendar/features/desktop_widget/domain/desktop_widget_snapshot.dart';
import 'package:worker_rest_calendar/features/desktop_widget/presentation/desktop_clock_card.dart';
import 'package:worker_rest_calendar/features/schedule/application/active_schedule_controller.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_engine.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_pattern.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

import '../../../helpers/test_models.dart';

void main() {
  testWidgets('时钟显示时间日期与排班状态并在跨午夜后校正', (tester) async {
    var now = DateTime(2026, 7, 16, 23, 59, 58);
    final schedule = _schedule();
    final snapshot = DesktopWidgetSnapshot.build(
      schedule,
      CalendarDate(2026, 7, 16),
    );
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 220);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          backgroundColor: Colors.transparent,
          body: DesktopClockCard(
            snapshot: snapshot,
            size: DesktopWidgetSize.medium,
            now: () => now,
            tickInterval: const Duration(milliseconds: 10),
          ),
        ),
      ),
    );

    expect(find.text('23:59'), findsOneWidget);
    expect(find.text('58'), findsOneWidget);
    expect(find.textContaining('7月16日'), findsOneWidget);
    expect(find.text(snapshot.today.label), findsOneWidget);

    now = DateTime(2026, 7, 17, 0, 0, 1);
    await tester.pump(const Duration(milliseconds: 20));

    expect(find.text('00:00'), findsOneWidget);
    expect(find.text('01'), findsOneWidget);
    expect(find.textContaining('7月17日'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('时钟在三种尺寸与 130% 字体下无溢出', (tester) async {
    final schedule = _schedule();
    final snapshot = DesktopWidgetSnapshot.build(
      schedule,
      CalendarDate(2026, 7, 16),
    );
    for (final size in DesktopWidgetSize.values) {
      final dimensions = switch (size) {
        DesktopWidgetSize.small => const Size(180, 220),
        DesktopWidgetSize.medium => const Size(360, 220),
        DesktopWidgetSize.large => const Size(420, 360),
      };
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = dimensions;
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(
            size: dimensions,
            textScaler: const TextScaler.linear(1.3),
          ),
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              body: DesktopClockCard(
                snapshot: snapshot,
                size: size,
                now: () => DateTime(2026, 7, 16, 12, 34, 56),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull, reason: size.name);
    }
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
  });
}

ActiveScheduleState _schedule() {
  final profile = testProfile();
  return ActiveScheduleState(
    profile: profile,
    engine: ScheduleEngine(
      pattern: AlternatingBigSmallWeekPattern(
        anchorDate: profile.anchorDate,
        anchorWeekType: profile.anchorWeekType!,
      ),
    ),
    manualOverrides: const [],
    holidayOverrides: const [],
  );
}
