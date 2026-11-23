import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/core/theme/app_theme.dart';
import 'package:worker_rest_calendar/features/desktop_widget/domain/desktop_widget_snapshot.dart';
import 'package:worker_rest_calendar/features/desktop_widget/presentation/desktop_widget_card.dart';
import 'package:worker_rest_calendar/features/holidays/data/holiday_data_codec.dart';
import 'package:worker_rest_calendar/features/schedule/application/active_schedule_controller.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_override.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_engine.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_pattern.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

import '../../../helpers/test_models.dart';

void main() {
  for (final dark in [false, true]) {
    for (final shape in DesktopWidgetLargeDateShape.values) {
      testWidgets('摆件显示 2027 劳动节及补班 $dark $shape', (tester) async {
        tester.view.physicalSize = const Size(420, 360);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final bundle = const HolidayDataCodec().decode(
          File('assets/holidays/cn_2027.json').readAsStringSync(),
        );
        final schedule = ActiveScheduleState(
          profile: testProfile(),
          engine: ScheduleEngine(
            pattern: const FixedWeeklyPattern.doubleRest(),
            holidayOverrides: {
              for (final d in bundle.overrides)
                d.date: DayOverride(kind: d.kind, note: d.title),
            },
          ),
          manualOverrides: const [],
          holidayOverrides: bundle.overrides,
        );
        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? AppTheme.dark : AppTheme.light,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.3)),
              child: child!,
            ),
            home: DesktopWidgetCard(
              snapshot: DesktopWidgetSnapshot.build(
                schedule,
                CalendarDate(2027, 5, 1),
              ),
              size: DesktopWidgetSize.large,
              largeDateShape: shape,
              onOpenDate: (_) {},
            ),
          ),
        );
        expect(find.text('劳动节'), findsNWidgets(5));
        expect(find.text('调班'), findsOneWidget);
        expect(find.byTooltip('2027年5月8日 周六，调休上班，劳动节调休上班'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
