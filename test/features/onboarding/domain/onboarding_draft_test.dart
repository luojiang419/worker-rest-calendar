import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/onboarding/domain/onboarding_draft.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_pattern.dart';

void main() {
  group('OnboardingDraft', () {
    test('可完整序列化并恢复大小周草稿', () {
      final draft = OnboardingDraft(
        step: OnboardingStep.preview,
        patternType: SchedulePatternType.alternatingBigSmallWeek,
        anchorDate: CalendarDate(2026, 7, 13),
        anchorWeekType: WeekType.big,
      );

      final restored = OnboardingDraft.fromJson(draft.toJson());

      expect(restored.step, OnboardingStep.preview);
      expect(restored.patternType, SchedulePatternType.alternatingBigSmallWeek);
      expect(restored.anchorDate, CalendarDate(2026, 7, 13));
      expect(restored.anchorWeekType, WeekType.big);
      expect(restored.validateForPreview(), isNull);
    });

    test('自定义循环限制为 1–56 天且必须包含休息日', () {
      final base = OnboardingDraft(
        patternType: SchedulePatternType.customCycle,
        anchorDate: CalendarDate(2026, 7, 13),
      );

      expect(base.validateForPreview(), contains('1–56'));
      expect(
        base.copyWith(cycleDays: const [DayKind.work]).validateForPreview(),
        contains('至少有一个休息日'),
      );
      expect(
        base
            .copyWith(cycleDays: List.filled(57, DayKind.rest))
            .validateForPreview(),
        contains('1–56'),
      );
      expect(
        base
            .copyWith(cycleDays: const [DayKind.work, DayKind.rest])
            .validateForPreview(),
        isNull,
      );
    });

    test('大小周必须同时提供周一锚点与周类型', () {
      const draft = OnboardingDraft(
        patternType: SchedulePatternType.alternatingBigSmallWeek,
      );

      expect(draft.validateForPreview(), contains('锚点'));
      expect(
        draft
            .copyWith(anchorDate: CalendarDate(2026, 7, 13))
            .validateForPreview(),
        contains('大周还是小周'),
      );
    });
  });
}
