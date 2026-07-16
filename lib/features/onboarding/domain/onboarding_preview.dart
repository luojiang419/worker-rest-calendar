import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/onboarding/domain/onboarding_draft.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_pattern.dart';

final class OnboardingPreviewDay {
  const OnboardingPreviewDay({
    required this.date,
    required this.kind,
    this.weekType,
  });

  final CalendarDate date;
  final DayKind kind;
  final WeekType? weekType;
}

List<OnboardingPreviewDay> buildOnboardingPreview({
  required OnboardingDraft draft,
  required CalendarDate startDate,
  int dayCount = 30,
}) {
  final validationError = draft.validateForPreview();
  if (validationError != null) {
    throw StateError(validationError);
  }
  final pattern = schedulePatternFromDraft(draft);
  return List.generate(dayCount, (index) {
    final date = startDate.addDays(index);
    return OnboardingPreviewDay(
      date: date,
      kind: pattern.plannedKind(date),
      weekType: pattern.weekTypeFor(date),
    );
  }, growable: false);
}

SchedulePattern schedulePatternFromDraft(OnboardingDraft draft) {
  final type = draft.patternType;
  return switch (type) {
    SchedulePatternType.doubleRest => const FixedWeeklyPattern.doubleRest(),
    SchedulePatternType.singleRest => const FixedWeeklyPattern.singleRest(),
    SchedulePatternType.alternatingBigSmallWeek =>
      AlternatingBigSmallWeekPattern(
        anchorDate: draft.anchorDate!,
        anchorWeekType: draft.anchorWeekType!,
      ),
    SchedulePatternType.sixOnOneOff => CycleSchedulePattern.sixOnOneOff(
      anchorDate: draft.anchorDate!,
    ),
    SchedulePatternType.twoOnTwoOff => CycleSchedulePattern.twoOnTwoOff(
      anchorDate: draft.anchorDate!,
    ),
    SchedulePatternType.customCycle => CycleSchedulePattern.custom(
      anchorDate: draft.anchorDate!,
      cycleDays: draft.cycleDays,
    ),
    null => throw StateError('请先选择班制'),
  };
}
