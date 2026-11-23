import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/core/theme/app_theme.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/features/calendar/presentation/calendar_day_cell.dart';
import 'package:worker_rest_calendar/features/schedule/application/day_presentation.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_override.dart';

void main() {
  testWidgets('法定节假日日历格显示官方名称和完整语义', (tester) async {
    final day = DayPresentation(
      date: CalendarDate(2026, 10, 10),
      plannedKind: DayKind.rest,
      effectiveKind: DayKind.adjustedWork,
      label: '调休上班',
      shortLabel: '调班',
      weekType: null,
      overtimeMinutes: 0,
      appliedOverrideSource: DayOverrideSource.holiday,
      note: '国庆节调休上班',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: SizedBox(
            width: 160,
            height: 80,
            child: CalendarDayCell(
              day: day,
              isToday: false,
              isSelected: false,
              isInDisplayedMonth: true,
              onTap: () {},
              onLongPress: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('国庆节调休上班'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'2026年10月10日.*调休上班.*国庆节调休上班')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('休息日和法定节假日比普通工作日更突出', (tester) async {
    DayPresentation day({
      required int dayOfMonth,
      required DayKind kind,
      DayOverrideSource? source,
      String? note,
    }) => DayPresentation(
      date: CalendarDate(2026, 10, dayOfMonth),
      plannedKind: kind,
      effectiveKind: kind,
      label: kind == DayKind.rest ? '休息' : '工作',
      shortLabel: kind == DayKind.rest ? '休' : '班',
      weekType: null,
      overtimeMinutes: 0,
      appliedOverrideSource: source,
      note: note,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: Row(
            children: [
              for (final item in [
                day(dayOfMonth: 8, kind: DayKind.work),
                day(dayOfMonth: 9, kind: DayKind.rest),
                day(
                  dayOfMonth: 10,
                  kind: DayKind.work,
                  source: DayOverrideSource.holiday,
                  note: '国庆节调休上班',
                ),
              ])
                Expanded(
                  child: SizedBox(
                    height: 80,
                    child: CalendarDayCell(
                      day: item,
                      isToday: false,
                      isSelected: false,
                      isInDisplayedMonth: true,
                      onTap: () {},
                      onLongPress: () {},
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    final decorations = tester
        .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
        .map((widget) => widget.decoration! as BoxDecoration)
        .toList();
    expect(decorations, hasLength(3));
    expect(decorations[1].color!.a, greaterThan(decorations[0].color!.a));
    expect(decorations[2].color!.a, greaterThan(decorations[1].color!.a));
    expect(decorations[0].boxShadow, isEmpty);
    expect(decorations[1].boxShadow, isNotEmpty);
    expect(decorations[2].boxShadow, isNotEmpty);
  });

  testWidgets('今天在浅色和暗黑主题下显示主色微光边缘', (tester) async {
    final day = DayPresentation(
      date: CalendarDate(2026, 7, 13),
      plannedKind: DayKind.work,
      effectiveKind: DayKind.work,
      label: '工作',
      shortLabel: '班',
      weekType: null,
      overtimeMinutes: 0,
      appliedOverrideSource: null,
    );

    Future<BoxDecoration> pumpCell(
      ThemeData theme, {
      required bool isToday,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: SizedBox(
              width: 160,
              height: 80,
              child: CalendarDayCell(
                day: day,
                isToday: isToday,
                isSelected: false,
                isInDisplayedMonth: true,
                onTap: () {},
                onLongPress: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return tester
              .widget<AnimatedContainer>(find.byType(AnimatedContainer))
              .decoration!
          as BoxDecoration;
    }

    final regularDecoration = await pumpCell(AppTheme.light, isToday: false);
    expect(regularDecoration.boxShadow, isEmpty);

    final lightDecoration = await pumpCell(AppTheme.light, isToday: true);
    expect(lightDecoration.boxShadow, AppTokens.light.shadows.todayGlow);

    final darkDecoration = await pumpCell(AppTheme.dark, isToday: true);
    expect(darkDecoration.boxShadow, AppTokens.dark.shadows.todayGlow);
    expect(tester.takeException(), isNull);
  });
}
