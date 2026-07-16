import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/core/theme/app_theme.dart';
import 'package:worker_rest_calendar/core/theme/app_visual_style.dart';
import 'package:worker_rest_calendar/features/desktop_widget/domain/desktop_widget_snapshot.dart';
import 'package:worker_rest_calendar/features/desktop_widget/presentation/desktop_clock_card.dart';
import 'package:worker_rest_calendar/features/desktop_widget/presentation/desktop_focus_card.dart';
import 'package:worker_rest_calendar/features/desktop_widget/presentation/desktop_note_card.dart';
import 'package:worker_rest_calendar/features/schedule/application/active_schedule_controller.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_engine.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_pattern.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

import '../../../helpers/test_models.dart';

void main() {
  testWidgets('新增摆件适配五种视觉风格与明暗主题', (tester) async {
    const dimensions = Size(360, 220);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = dimensions;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final snapshot = DesktopWidgetSnapshot.build(
      _schedule(),
      CalendarDate(2026, 7, 16),
    );

    for (final style in AppVisualStyle.values) {
      for (final brightness in Brightness.values) {
        for (final type in const [
          DesktopWidgetType.clock,
          DesktopWidgetType.note,
          DesktopWidgetType.focus,
        ]) {
          final cardName = type.name;
          final card = switch (type) {
            DesktopWidgetType.clock => DesktopClockCard(
              snapshot: snapshot,
              size: DesktopWidgetSize.medium,
              now: () => DateTime(2026, 7, 16, 12, 34, 56),
            ),
            DesktopWidgetType.note => DesktopNoteCard(
              note: '保持专注，也要记得休息。',
              size: DesktopWidgetSize.medium,
              positionLocked: false,
              onChanged: (_) {},
              onStartDragging: () {},
            ),
            DesktopWidgetType.focus => const DesktopFocusCard(
              size: DesktopWidgetSize.medium,
            ),
            DesktopWidgetType.schedule => throw StateError('本测试仅验证新增摆件'),
          };
          await tester.pumpWidget(
            ProviderScope(
              child: MediaQuery(
                data: const MediaQueryData(
                  size: dimensions,
                  textScaler: TextScaler.linear(1.3),
                ),
                child: MaterialApp(
                  theme: AppTheme.lightFor(style),
                  darkTheme: AppTheme.darkFor(style),
                  themeMode: brightness == Brightness.light
                      ? ThemeMode.light
                      : ThemeMode.dark,
                  home: Scaffold(body: card),
                ),
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 250));

          expect(
            tester.takeException(),
            isNull,
            reason: '${style.name} ${brightness.name} $cardName',
          );
          expect(
            find.byKey(ValueKey('desktop-$cardName-card-${style.name}')),
            findsOneWidget,
          );
        }
      }
    }
    await tester.pumpWidget(const SizedBox.shrink());
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
