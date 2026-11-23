import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/onboarding/domain/onboarding_draft.dart';
import 'package:worker_rest_calendar/features/onboarding/domain/onboarding_preview.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_pattern.dart';

void main() {
  test('大小周连续 8 周严格交替且周六状态正确', () {
    final anchorMonday = CalendarDate(2026, 7, 13);
    final preview = buildOnboardingPreview(
      draft: OnboardingDraft(
        step: OnboardingStep.preview,
        patternType: SchedulePatternType.alternatingBigSmallWeek,
        anchorDate: anchorMonday,
        anchorWeekType: WeekType.big,
      ),
      startDate: anchorMonday,
      dayCount: 56,
    );

    for (var week = 0; week < 8; week++) {
      final expectedType = week.isEven ? WeekType.big : WeekType.small;
      expect(preview[week * 7].weekType, expectedType);
      expect(
        preview[week * 7 + 5].kind,
        expectedType == WeekType.big ? DayKind.rest : DayKind.work,
      );
      expect(preview[week * 7 + 6].kind, DayKind.rest);
    }
  });

  test('未来 30 天预览从指定日期开始且包含 30 项', () {
    final start = CalendarDate(2026, 7, 13);
    final preview = buildOnboardingPreview(
      draft: OnboardingDraft(
        patternType: SchedulePatternType.customCycle,
        anchorDate: start,
        cycleDays: const [DayKind.work, DayKind.rest],
      ),
      startDate: start,
    );

    expect(preview, hasLength(30));
    expect(preview.first.date, start);
    expect(preview.last.date, CalendarDate(2026, 8, 11));
    expect(preview.take(4).map((day) => day.kind), [
      DayKind.work,
      DayKind.rest,
      DayKind.work,
      DayKind.rest,
    ]);
  });
}
