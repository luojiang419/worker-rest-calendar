import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_rest_calendar/app/app_dependencies.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/onboarding/domain/onboarding_draft.dart';
import 'package:worker_rest_calendar/features/onboarding/domain/onboarding_preview.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_pattern.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_profile.dart';

final onboardingControllerProvider =
    AsyncNotifierProvider<OnboardingController, OnboardingState>(
      OnboardingController.new,
    );

final class OnboardingState {
  const OnboardingState({required this.draft, this.isCompleted = false});

  const OnboardingState.completed()
    : draft = const OnboardingDraft(),
      isCompleted = true;

  final OnboardingDraft draft;
  final bool isCompleted;

  List<OnboardingPreviewDay> preview(CalendarDate startDate) =>
      buildOnboardingPreview(draft: draft, startDate: startDate);
}

final class OnboardingController extends AsyncNotifier<OnboardingState> {
  var _isCompleting = false;

  @override
  Future<OnboardingState> build() async {
    final preferences = await ref
        .watch(settingsRepositoryProvider)
        .getAppPreferences();
    if (preferences.firstLaunchCompleted) {
      return const OnboardingState.completed();
    }
    final draft = await ref.watch(onboardingDraftRepositoryProvider).load();
    return OnboardingState(draft: draft ?? const OnboardingDraft());
  }

  Future<void> start() => _saveDraft(
    state.requireValue.draft.copyWith(step: OnboardingStep.pattern),
  );

  Future<void> selectPattern(SchedulePatternType type) {
    final today = ref.read(todayProvider);
    final cycleDays = switch (type) {
      SchedulePatternType.customCycle => const [DayKind.work, DayKind.rest],
      _ => const <DayKind>[],
    };
    return _saveDraft(
      state.requireValue.draft.copyWith(
        patternType: type,
        anchorDate: switch (type) {
          SchedulePatternType.alternatingBigSmallWeek => today.monday,
          _ => today,
        },
        clearAnchorWeekType: true,
        cycleDays: cycleDays,
      ),
    );
  }

  Future<String?> continueFromPattern() async {
    final draft = state.requireValue.draft;
    if (draft.patternType == null) {
      return '请先选择班制';
    }
    await _saveDraft(
      draft.copyWith(
        step: draft.needsConfiguration
            ? OnboardingStep.configuration
            : OnboardingStep.preview,
      ),
    );
    return null;
  }

  Future<void> setAnchorDate(CalendarDate date) =>
      _saveDraft(state.requireValue.draft.copyWith(anchorDate: date));

  Future<void> setAnchorWeekType(WeekType type) =>
      _saveDraft(state.requireValue.draft.copyWith(anchorWeekType: type));

  Future<void> setCustomCycleLength(int length) {
    if (length < 1 || length > 56) {
      throw RangeError.range(length, 1, 56, 'length');
    }
    final current = state.requireValue.draft.cycleDays;
    final updated = List<DayKind>.generate(
      length,
      (index) => index < current.length ? current[index] : DayKind.work,
    );
    return _saveDraft(state.requireValue.draft.copyWith(cycleDays: updated));
  }

  Future<void> setCustomCycleDay(int index, DayKind kind) {
    if (!kind.isBaseKind) {
      throw ArgumentError.value(kind, 'kind', '循环只能包含工作或休息');
    }
    final updated = List<DayKind>.of(state.requireValue.draft.cycleDays);
    if (index < 0 || index >= updated.length) {
      throw RangeError.index(index, updated, 'index');
    }
    updated[index] = kind;
    return _saveDraft(state.requireValue.draft.copyWith(cycleDays: updated));
  }

  Future<String?> continueFromConfiguration() async {
    final draft = state.requireValue.draft;
    final error = draft.validateForPreview();
    if (error != null) {
      return error;
    }
    await _saveDraft(draft.copyWith(step: OnboardingStep.preview));
    return null;
  }

  Future<void> goBack() async {
    final draft = state.requireValue.draft;
    final target = switch (draft.step) {
      OnboardingStep.welcome => OnboardingStep.welcome,
      OnboardingStep.pattern => OnboardingStep.welcome,
      OnboardingStep.configuration => OnboardingStep.pattern,
      OnboardingStep.preview =>
        draft.needsConfiguration
            ? OnboardingStep.configuration
            : OnboardingStep.pattern,
    };
    await _saveDraft(draft.copyWith(step: target));
  }

  Future<String?> complete() async {
    if (_isCompleting) {
      return '正在保存，请稍候';
    }
    final current = state.requireValue;
    final error = current.draft.validateForPreview();
    if (error != null) {
      return error;
    }

    _isCompleting = true;
    try {
      final draft = current.draft;
      final now = DateTime.now().toUtc();
      final profile = ScheduleProfile(
        id: ref.read(profileIdProvider)(),
        name: _profileName(draft.patternType!),
        patternType: draft.patternType!,
        anchorDate: draft.anchorDate ?? ref.read(todayProvider),
        anchorWeekType: draft.anchorWeekType,
        cycleDays: draft.cycleDays,
        holidayOverridesEnabled: true,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      await ref.read(scheduleRepositoryProvider).saveProfile(profile);
      final settingsRepository = ref.read(settingsRepositoryProvider);
      final preferences = await settingsRepository.getAppPreferences();
      await settingsRepository.saveAppPreferences(
        preferences.copyWith(firstLaunchCompleted: true),
      );
      await ref.read(onboardingDraftRepositoryProvider).clear();
      state = const AsyncData(OnboardingState.completed());
      return null;
    } finally {
      _isCompleting = false;
    }
  }

  Future<void> _saveDraft(OnboardingDraft draft) async {
    await ref.read(onboardingDraftRepositoryProvider).save(draft);
    state = AsyncData(OnboardingState(draft: draft));
  }

  String _profileName(SchedulePatternType type) => switch (type) {
    SchedulePatternType.doubleRest => '双休',
    SchedulePatternType.singleRest => '单休',
    SchedulePatternType.alternatingBigSmallWeek => '大小周',
    SchedulePatternType.sixOnOneOff => '做六休一',
    SchedulePatternType.twoOnTwoOff => '做二休二',
    SchedulePatternType.customCycle => '自定义循环',
  };
}
