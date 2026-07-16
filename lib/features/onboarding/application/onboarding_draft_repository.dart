import 'package:worker_rest_calendar/features/onboarding/domain/onboarding_draft.dart';

abstract interface class OnboardingDraftRepository {
  Future<OnboardingDraft?> load();

  Future<void> save(OnboardingDraft draft);

  Future<void> clear();
}
