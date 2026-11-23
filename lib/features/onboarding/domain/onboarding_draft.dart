import 'dart:convert';

import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_pattern.dart';

enum OnboardingStep { welcome, pattern, configuration, preview }

final class OnboardingDraft {
  const OnboardingDraft({
    this.step = OnboardingStep.welcome,
    this.patternType,
    this.anchorDate,
    this.anchorWeekType,
    this.cycleDays = const [],
  });

  factory OnboardingDraft.fromJson(Map<String, Object?> json) {
    final rawCycleDays = json['cycleDays'];
    return OnboardingDraft(
      step: OnboardingStep.values.byName(json['step']! as String),
      patternType: json['patternType'] == null
          ? null
          : SchedulePatternType.values.byName(json['patternType']! as String),
      anchorDate: json['anchorDate'] == null
          ? null
          : CalendarDate.parse(json['anchorDate']! as String),
      anchorWeekType: json['anchorWeekType'] == null
          ? null
          : WeekType.values.byName(json['anchorWeekType']! as String),
      cycleDays: rawCycleDays is List<Object?>
          ? rawCycleDays
                .cast<String>()
                .map(DayKind.values.byName)
                .toList(growable: false)
          : const [],
    );
  }

  final OnboardingStep step;
  final SchedulePatternType? patternType;
  final CalendarDate? anchorDate;
  final WeekType? anchorWeekType;
  final List<DayKind> cycleDays;

  bool get needsConfiguration => switch (patternType) {
    SchedulePatternType.alternatingBigSmallWeek ||
    SchedulePatternType.sixOnOneOff ||
    SchedulePatternType.twoOnTwoOff ||
    SchedulePatternType.customCycle => true,
    SchedulePatternType.doubleRest || SchedulePatternType.singleRest => false,
    null => false,
  };

  String? validateForPreview() {
    final type = patternType;
    if (type == null) {
      return '请先选择班制';
    }
    if (type == SchedulePatternType.alternatingBigSmallWeek) {
      if (anchorDate == null) {
        return '请选择大小周锚点';
      }
      if (anchorWeekType == null) {
        return '请选择本周是大周还是小周';
      }
    }
    if (_isCycle(type) && anchorDate == null) {
      return '请选择循环起始日';
    }
    if (type == SchedulePatternType.customCycle) {
      if (cycleDays.isEmpty || cycleDays.length > 56) {
        return '自定义循环长度必须在 1–56 天之间';
      }
      if (cycleDays.any((kind) => !kind.isBaseKind)) {
        return '自定义循环只能包含工作或休息';
      }
      if (cycleDays.every((kind) => kind != DayKind.rest)) {
        return '自定义循环中必须至少有一个休息日';
      }
    }
    return null;
  }

  OnboardingDraft copyWith({
    OnboardingStep? step,
    SchedulePatternType? patternType,
    bool clearPatternType = false,
    CalendarDate? anchorDate,
    bool clearAnchorDate = false,
    WeekType? anchorWeekType,
    bool clearAnchorWeekType = false,
    List<DayKind>? cycleDays,
  }) => OnboardingDraft(
    step: step ?? this.step,
    patternType: clearPatternType ? null : patternType ?? this.patternType,
    anchorDate: clearAnchorDate ? null : anchorDate ?? this.anchorDate,
    anchorWeekType: clearAnchorWeekType
        ? null
        : anchorWeekType ?? this.anchorWeekType,
    cycleDays: List.unmodifiable(cycleDays ?? this.cycleDays),
  );

  Map<String, Object?> toJson() => {
    'step': step.name,
    'patternType': patternType?.name,
    'anchorDate': anchorDate?.toString(),
    'anchorWeekType': anchorWeekType?.name,
    'cycleDays': cycleDays.map((kind) => kind.name).toList(growable: false),
  };

  String encode() => jsonEncode(toJson());

  static bool _isCycle(SchedulePatternType type) => switch (type) {
    SchedulePatternType.sixOnOneOff ||
    SchedulePatternType.twoOnTwoOff ||
    SchedulePatternType.customCycle => true,
    _ => false,
  };
}
