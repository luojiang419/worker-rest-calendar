import 'package:worker_rest_calendar/features/schedule/domain/schedule_error.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_pattern.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_profile.dart';

SchedulePattern buildPatternFromProfile(
  ScheduleProfile profile,
) => switch (profile.patternType) {
  SchedulePatternType.doubleRest => const FixedWeeklyPattern.doubleRest(),
  SchedulePatternType.singleRest => const FixedWeeklyPattern.singleRest(),
  SchedulePatternType.alternatingBigSmallWeek => AlternatingBigSmallWeekPattern(
    anchorDate: profile.anchorDate,
    anchorWeekType:
        profile.anchorWeekType ?? (throw const InvalidPattern('大小周班制缺少锚点周类型')),
  ),
  SchedulePatternType.sixOnOneOff => CycleSchedulePattern.sixOnOneOff(
    anchorDate: profile.anchorDate,
  ),
  SchedulePatternType.twoOnTwoOff => CycleSchedulePattern.twoOnTwoOff(
    anchorDate: profile.anchorDate,
  ),
  SchedulePatternType.customCycle => CycleSchedulePattern.custom(
    anchorDate: profile.anchorDate,
    cycleDays: profile.cycleDays,
  ),
};
