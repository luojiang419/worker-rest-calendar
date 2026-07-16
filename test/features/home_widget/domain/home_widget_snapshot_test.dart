import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/home_widget/domain/home_widget_snapshot.dart';
import 'package:worker_rest_calendar/features/schedule/application/active_schedule_controller.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_engine.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_pattern.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

import '../../../helpers/test_models.dart';

void main() {
  test('生成可跨天使用的 62 天及 3 个月原生快照', () {
    final snapshot = _buildSnapshot();

    expect(snapshot.days, hasLength(62));
    expect(snapshot.days.first.date, CalendarDate(2026, 7, 13));
    expect(snapshot.days.first.kind, DayKind.work);
    expect(snapshot.days.first.weekType, WeekType.small);
    expect(snapshot.days.first.daysToNextRest, 6);
    expect(snapshot.days.first.week, hasLength(7));
    expect(snapshot.months, hasLength(3));
    expect(snapshot.months.first.days, hasLength(42));
    expect(snapshot.months.first.days.first.date, CalendarDate(2026, 6, 29));
  });

  test('JSON 往返保留协议版本、主题与日期状态', () {
    final source = _buildSnapshot();
    final decoded = HomeWidgetSnapshot.fromJsonString(source.toJsonString());

    expect(decoded.generatedAt, source.generatedAt);
    expect(decoded.theme, AppThemePreference.dark);
    expect(decoded.days[6].date, CalendarDate(2026, 7, 19));
    expect(decoded.days[6].kind, DayKind.rest);
    expect(decoded.months[1].month, CalendarDate(2026, 8, 1));
  });

  test('拒绝未知协议版本', () {
    expect(
      () => HomeWidgetSnapshot.fromJsonString(
        '{"version":2,"generatedAt":"2026-07-13T00:00:00Z",'
        '"theme":"system","days":[],"months":[]}',
      ),
      throwsFormatException,
    );
  });
}

HomeWidgetSnapshot _buildSnapshot() {
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
  return HomeWidgetSnapshot.build(
    schedule: schedule,
    today: CalendarDate(2026, 7, 13),
    generatedAt: DateTime.utc(2026, 7, 13, 8),
    theme: AppThemePreference.dark,
  );
}
