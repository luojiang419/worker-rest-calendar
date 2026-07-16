import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker_rest_calendar/features/onboarding/application/onboarding_draft_repository.dart';
import 'package:worker_rest_calendar/features/onboarding/domain/onboarding_draft.dart';

final class SharedPreferencesOnboardingDraftRepository
    implements OnboardingDraftRepository {
  const SharedPreferencesOnboardingDraftRepository();

  static const _key = 'onboarding_draft_v1';

  @override
  Future<OnboardingDraft?> load() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_key);
    if (encoded == null) {
      return null;
    }
    try {
      return OnboardingDraft.fromJson(
        (jsonDecode(encoded) as Map<Object?, Object?>).cast<String, Object?>(),
      );
    } on Object {
      await preferences.remove(_key);
      return null;
    }
  }

  @override
  Future<void> save(OnboardingDraft draft) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key, draft.encode());
  }

  @override
  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_key);
  }
}
