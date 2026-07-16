import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/onboarding/data/shared_preferences_onboarding_draft_repository.dart';
import 'package:worker_rest_calendar/features/onboarding/domain/onboarding_draft.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_pattern.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('草稿可跨 repository 实例恢复并清除', () async {
    const repository = SharedPreferencesOnboardingDraftRepository();
    final draft = OnboardingDraft(
      step: OnboardingStep.configuration,
      patternType: SchedulePatternType.customCycle,
      anchorDate: CalendarDate(2026, 7, 13),
      cycleDays: const [DayKind.work, DayKind.rest],
    );

    await repository.save(draft);
    final restored = await const SharedPreferencesOnboardingDraftRepository()
        .load();

    expect(restored?.step, OnboardingStep.configuration);
    expect(restored?.cycleDays, const [DayKind.work, DayKind.rest]);

    await repository.clear();
    expect(await repository.load(), isNull);
  });

  test('损坏草稿会被安全丢弃', () async {
    SharedPreferences.setMockInitialValues({
      'onboarding_draft_v1': '{not-json',
    });

    expect(
      await const SharedPreferencesOnboardingDraftRepository().load(),
      isNull,
    );
  });
}
