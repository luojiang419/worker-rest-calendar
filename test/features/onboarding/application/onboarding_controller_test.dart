import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/app/app_dependencies.dart';
import 'package:worker_rest_calendar/core/database/app_database.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/onboarding/application/onboarding_controller.dart';
import 'package:worker_rest_calendar/features/onboarding/application/onboarding_draft_repository.dart';
import 'package:worker_rest_calendar/features/onboarding/domain/onboarding_draft.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_pattern.dart';

void main() {
  late AppDatabase database;
  late _MemoryDraftRepository draftRepository;
  late ProviderContainer container;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    draftRepository = _MemoryDraftRepository();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        onboardingDraftRepositoryProvider.overrideWithValue(draftRepository),
        currentDateProvider.overrideWithValue(() => CalendarDate(2026, 7, 15)),
        profileIdProvider.overrideWithValue(() => 'onboarding-profile'),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  test('恢复中断草稿', () async {
    draftRepository.draft = OnboardingDraft(
      step: OnboardingStep.configuration,
      patternType: SchedulePatternType.alternatingBigSmallWeek,
      anchorDate: CalendarDate(2026, 7, 13),
    );

    final state = await container.read(onboardingControllerProvider.future);

    expect(state.draft.step, OnboardingStep.configuration);
    expect(
      state.draft.patternType,
      SchedulePatternType.alternatingBigSmallWeek,
    );
  });

  test('完成后创建唯一 active profile、更新首次启动并清除草稿', () async {
    await container.read(onboardingControllerProvider.future);
    final controller = container.read(onboardingControllerProvider.notifier);

    await controller.start();
    await controller.selectPattern(SchedulePatternType.doubleRest);
    expect(await controller.continueFromPattern(), isNull);
    expect(await controller.complete(), isNull);

    final profiles = await container
        .read(scheduleRepositoryProvider)
        .getProfiles();
    final preferences = await container
        .read(settingsRepositoryProvider)
        .getAppPreferences();
    final state = container.read(onboardingControllerProvider).requireValue;

    expect(profiles, hasLength(1));
    expect(profiles.single.id, 'onboarding-profile');
    expect(profiles.single.isActive, isTrue);
    expect(profiles.single.patternType, SchedulePatternType.doubleRest);
    expect(preferences.firstLaunchCompleted, isTrue);
    expect(draftRepository.draft, isNull);
    expect(state.isCompleted, isTrue);
  });

  test('自定义循环可扩展到 56 天且无休息日时不能进入预览', () async {
    await container.read(onboardingControllerProvider.future);
    final controller = container.read(onboardingControllerProvider.notifier);

    await controller.start();
    await controller.selectPattern(SchedulePatternType.customCycle);
    await controller.continueFromPattern();
    await controller.setCustomCycleLength(56);
    for (var index = 0; index < 56; index++) {
      await controller.setCustomCycleDay(index, DayKind.work);
    }

    final state = container.read(onboardingControllerProvider).requireValue;
    expect(state.draft.cycleDays, hasLength(56));
    expect(await controller.continueFromConfiguration(), contains('至少有一个休息日'));
  });
}

final class _MemoryDraftRepository implements OnboardingDraftRepository {
  OnboardingDraft? draft;

  @override
  Future<void> clear() async => draft = null;

  @override
  Future<OnboardingDraft?> load() async => draft;

  @override
  Future<void> save(OnboardingDraft value) async => draft = value;
}
