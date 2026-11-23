import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/app/app.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/core/theme/app_theme.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/core/theme/app_visual_style.dart';
import 'package:worker_rest_calendar/core/widgets/app_card.dart';
import 'package:worker_rest_calendar/features/desktop_widget/domain/desktop_widget_snapshot.dart';
import 'package:worker_rest_calendar/features/desktop_widget/presentation/desktop_widget_card.dart';
import 'package:worker_rest_calendar/features/schedule/application/active_schedule_controller.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_engine.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_pattern.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

import '../../../helpers/test_models.dart';

void main() {
  for (final visualStyle in AppVisualStyle.values) {
    for (final brightness in Brightness.values) {
      for (final size in DesktopWidgetSize.values) {
        testWidgets(
          '${visualStyle.name} ${brightness.name} ${size.name} 在 130% 字体下无溢出',
          (tester) async {
            final dimensions = switch (size) {
              DesktopWidgetSize.small => const Size(180, 220),
              DesktopWidgetSize.medium => const Size(360, 220),
              DesktopWidgetSize.large => const Size(420, 360),
            };
            tester.view.physicalSize = dimensions;
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            final profile = testProfile();
            final schedule = ActiveScheduleState(
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
            final snapshot = DesktopWidgetSnapshot.build(
              schedule,
              CalendarDate(2026, 7, 13),
            );

            await tester.pumpWidget(
              MaterialApp(
                theme: AppTheme.lightFor(visualStyle),
                darkTheme: AppTheme.darkFor(visualStyle),
                themeMode: brightness == Brightness.dark
                    ? ThemeMode.dark
                    : ThemeMode.light,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: const TextScaler.linear(1.3)),
                  child: child!,
                ),
                home: DesktopWidgetCard(
                  snapshot: snapshot,
                  size: size,
                  onOpenDate: (_) {},
                ),
              ),
            );

            expect(tester.takeException(), isNull);
            expect(
              find.byKey(ValueKey('desktop-widget-card-${visualStyle.name}')),
              findsOneWidget,
            );
            expect(
              find.text(switch (size) {
                DesktopWidgetSize.small => '今日状态',
                DesktopWidgetSize.medium => '本周节奏',
                DesktopWidgetSize.large => '2026年7月',
              }),
              findsOneWidget,
            );
            switch (size) {
              case DesktopWidgetSize.small:
                expect(find.textContaining('还要再上'), findsNothing);
              case DesktopWidgetSize.medium:
                expect(find.text('本周还要再上5天班'), findsOneWidget);
              case DesktopWidgetSize.large:
                expect(find.text('本月还要再上15天班'), findsOneWidget);
            }
          },
        );
      }
    }
  }

  testWidgets('拟物月历日期使用双向投影且今天使用主色渐变', (tester) async {
    await _pumpLargeCard(
      tester,
      visualStyle: AppVisualStyle.neumorphic,
      brightness: Brightness.light,
      todayHighlightStyle: DesktopWidgetTodayHighlightStyle.filled,
    );

    final ordinary = tester.widget<AnimatedContainer>(
      find.byKey(const ValueKey('desktop-widget-month-date-2026-07-14')),
    );
    final today = tester.widget<AnimatedContainer>(
      find.byKey(const ValueKey('desktop-widget-month-date-2026-07-13')),
    );
    final ordinaryDecoration = ordinary.decoration! as BoxDecoration;
    final todayDecoration = today.decoration! as BoxDecoration;

    expect(ordinaryDecoration.boxShadow, hasLength(2));
    expect(todayDecoration.gradient, isA<LinearGradient>());
  });

  testWidgets('大号日期可在圆角矩形与圆形之间切换', (tester) async {
    await _pumpLargeCard(
      tester,
      visualStyle: AppVisualStyle.classic,
      brightness: Brightness.dark,
    );

    var date = tester.widget<AnimatedContainer>(
      find.byKey(const ValueKey('desktop-widget-month-date-2026-07-14')),
    );
    var decoration = date.decoration! as BoxDecoration;
    expect(decoration.shape, BoxShape.rectangle);
    expect(decoration.borderRadius, isNotNull);

    await _pumpLargeCard(
      tester,
      visualStyle: AppVisualStyle.classic,
      brightness: Brightness.dark,
      largeDateShape: DesktopWidgetLargeDateShape.circle,
    );

    date = tester.widget<AnimatedContainer>(
      find.byKey(const ValueKey('desktop-widget-month-date-2026-07-14')),
    );
    decoration = date.decoration! as BoxDecoration;
    expect(decoration.shape, BoxShape.circle);
    expect(decoration.borderRadius, isNull);
  });

  testWidgets('中号今天保持原底色并使用动态微光描边', (tester) async {
    await _pumpMediumCard(
      tester,
      visualStyle: AppVisualStyle.classic,
      brightness: Brightness.dark,
    );

    final ordinary = tester.widget<AnimatedContainer>(
      find.byKey(const ValueKey('desktop-widget-week-date-2026-07-14')),
    );
    var today = tester.widget<AnimatedContainer>(
      find.byKey(const ValueKey('desktop-widget-week-date-2026-07-13')),
    );
    final ordinaryDecoration = ordinary.decoration! as BoxDecoration;
    var decoration = today.decoration! as BoxDecoration;
    final tokens = AppTokens.resolve(AppVisualStyle.classic, Brightness.dark);

    expect(decoration.shape, BoxShape.rectangle);
    expect(decoration.borderRadius, isNotNull);
    expect(decoration.color, ordinaryDecoration.color);
    expect(decoration.gradient, isNull);
    expect(decoration.boxShadow, isNotEmpty);
    expect(decoration.border?.top.color, isNot(tokens.colors.border));

    final initialBorderWidth = decoration.border!.top.width;
    final initialGlowBlur = decoration.boxShadow!.last.blurRadius;
    await tester.pump(
      Duration(milliseconds: tokens.motion.ambient.inMilliseconds ~/ 2),
    );
    today = tester.widget<AnimatedContainer>(
      find.byKey(const ValueKey('desktop-widget-week-date-2026-07-13')),
    );
    decoration = today.decoration! as BoxDecoration;
    expect(decoration.border!.top.width, isNot(initialBorderWidth));
    expect(decoration.boxShadow!.last.blurRadius, isNot(initialGlowBlur));
  });

  testWidgets('中号可切换回填充高亮', (tester) async {
    await _pumpMediumCard(
      tester,
      visualStyle: AppVisualStyle.classic,
      brightness: Brightness.dark,
      todayHighlightStyle: DesktopWidgetTodayHighlightStyle.filled,
    );

    final ordinary = tester.widget<AnimatedContainer>(
      find.byKey(const ValueKey('desktop-widget-week-date-2026-07-14')),
    );
    final today = tester.widget<AnimatedContainer>(
      find.byKey(const ValueKey('desktop-widget-week-date-2026-07-13')),
    );
    final ordinaryDecoration = ordinary.decoration! as BoxDecoration;
    final todayDecoration = today.decoration! as BoxDecoration;

    expect(todayDecoration.color, isNot(ordinaryDecoration.color));
    expect(todayDecoration.boxShadow, isNotEmpty);
  });

  testWidgets('系统减少动态效果时微光保持静态', (tester) async {
    await _pumpMediumCard(
      tester,
      visualStyle: AppVisualStyle.classic,
      brightness: Brightness.dark,
      disableAnimations: true,
    );

    var today = tester.widget<AnimatedContainer>(
      find.byKey(const ValueKey('desktop-widget-week-date-2026-07-13')),
    );
    var decoration = today.decoration! as BoxDecoration;
    final initialBorderWidth = decoration.border!.top.width;
    final initialGlowBlur = decoration.boxShadow!.last.blurRadius;
    await tester.pump(const Duration(seconds: 2));
    today = tester.widget<AnimatedContainer>(
      find.byKey(const ValueKey('desktop-widget-week-date-2026-07-13')),
    );
    decoration = today.decoration! as BoxDecoration;

    expect(decoration.border!.top.width, initialBorderWidth);
    expect(decoration.boxShadow!.last.blurRadius, initialGlowBlur);
  });

  testWidgets('扁平月历日期不使用投影', (tester) async {
    await _pumpLargeCard(
      tester,
      visualStyle: AppVisualStyle.flat,
      brightness: Brightness.dark,
    );

    final date = tester.widget<AnimatedContainer>(
      find.byKey(const ValueKey('desktop-widget-month-date-2026-07-14')),
    );
    final decoration = date.decoration! as BoxDecoration;
    expect(decoration.boxShadow, isEmpty);
  });

  testWidgets('暗色摆件安全边距保持透明而不是主题背景矩形', (tester) async {
    await _pumpLargeCard(
      tester,
      visualStyle: AppVisualStyle.classic,
      brightness: Brightness.dark,
      transparentBackdrop: true,
    );

    final backdrop = tester.widget<ColoredBox>(
      find.byKey(const ValueKey('app-theme-backdrop-transparent')),
    );
    expect(backdrop.color, Colors.transparent);

    final safeArea = tester.widget<Padding>(
      find.byKey(const ValueKey('desktop-widget-shadow-safe-area')),
    );
    expect(safeArea.padding, const EdgeInsets.all(8));
  });

  for (final visualStyle in AppVisualStyle.values) {
    testWidgets('${visualStyle.name} 摆件外层无描边并保留圆角投影', (tester) async {
      await _pumpLargeCard(
        tester,
        visualStyle: visualStyle,
        brightness: Brightness.dark,
      );

      final card = tester.widget<AppCard>(
        find.byKey(ValueKey('desktop-widget-card-${visualStyle.name}')),
      );
      expect(card.showBorder, isFalse);
      expect(card.borderColor, isNull);

      final tokens = AppTokens.resolve(visualStyle, Brightness.dark);
      final expectedShadows = tokens.shadows.medium.isEmpty
          ? AppTokens.resolve(
              AppVisualStyle.classic,
              Brightness.dark,
            ).shadows.medium
          : tokens.shadows.medium;
      expect(card.boxShadow, expectedShadows);
      expect(card.boxShadow, isNotEmpty);
      final decoration = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byKey(
                ValueKey('desktop-widget-card-${visualStyle.name}'),
              ),
              matching: find.byType(Container),
            ),
          )
          .map((container) => container.decoration)
          .whereType<BoxDecoration>()
          .singleWhere(
            (decoration) =>
                decoration.borderRadius ==
                BorderRadius.circular(tokens.radius.lg),
          );
      expect(decoration.border, isNull);
      expect(decoration.borderRadius, isNotNull);
      expect(decoration.boxShadow, expectedShadows);
    });
  }
}

Future<void> _pumpLargeCard(
  WidgetTester tester, {
  required AppVisualStyle visualStyle,
  required Brightness brightness,
  bool transparentBackdrop = false,
  DesktopWidgetLargeDateShape largeDateShape =
      DesktopWidgetLargeDateShape.roundedRectangle,
  DesktopWidgetTodayHighlightStyle todayHighlightStyle =
      DesktopWidgetTodayHighlightStyle.glowOutline,
}) async {
  tester.view.physicalSize = const Size(420, 360);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final profile = testProfile();
  final schedule = ActiveScheduleState(
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
  final snapshot = DesktopWidgetSnapshot.build(
    schedule,
    CalendarDate(2026, 7, 13),
  );

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightFor(visualStyle),
      darkTheme: AppTheme.darkFor(visualStyle),
      themeMode: brightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light,
      home: AppThemeBackdrop(
        transparent: transparentBackdrop,
        child: DesktopWidgetCard(
          snapshot: snapshot,
          size: DesktopWidgetSize.large,
          largeDateShape: largeDateShape,
          todayHighlightStyle: todayHighlightStyle,
          onOpenDate: (_) {},
        ),
      ),
    ),
  );
}

Future<void> _pumpMediumCard(
  WidgetTester tester, {
  required AppVisualStyle visualStyle,
  required Brightness brightness,
  DesktopWidgetTodayHighlightStyle todayHighlightStyle =
      DesktopWidgetTodayHighlightStyle.glowOutline,
  bool disableAnimations = false,
}) async {
  tester.view.physicalSize = const Size(360, 220);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final profile = testProfile();
  final schedule = ActiveScheduleState(
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
  final snapshot = DesktopWidgetSnapshot.build(
    schedule,
    CalendarDate(2026, 7, 13),
  );

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightFor(visualStyle),
      darkTheme: AppTheme.darkFor(visualStyle),
      themeMode: brightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(disableAnimations: disableAnimations),
        child: child!,
      ),
      home: DesktopWidgetCard(
        snapshot: snapshot,
        size: DesktopWidgetSize.medium,
        todayHighlightStyle: todayHighlightStyle,
        onOpenDate: (_) {},
      ),
    ),
  );
}
