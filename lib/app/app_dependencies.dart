import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:worker_rest_calendar/core/database/app_database.dart';
import 'package:worker_rest_calendar/core/database/database_connection.dart';
import 'package:worker_rest_calendar/features/onboarding/application/onboarding_draft_repository.dart';
import 'package:worker_rest_calendar/features/onboarding/data/shared_preferences_onboarding_draft_repository.dart';
import 'package:worker_rest_calendar/features/schedule/application/schedule_repository.dart';
import 'package:worker_rest_calendar/features/schedule/data/drift_schedule_repository.dart';
import 'package:worker_rest_calendar/features/settings/application/settings_repository.dart';
import 'package:worker_rest_calendar/features/settings/data/drift_settings_repository.dart';
import 'package:worker_rest_calendar/features/sync/application/backup_repository.dart';
import 'package:worker_rest_calendar/features/sync/application/sync_queue_repository.dart';
import 'package:worker_rest_calendar/features/sync/data/drift_sync_queue_repository.dart';
import 'package:worker_rest_calendar/features/sync/data/local_backup_repository.dart';

export 'package:worker_rest_calendar/core/date/current_date_controller.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = openAppDatabase();
  ref.onDispose(database.close);
  return database;
});

final scheduleRepositoryProvider = Provider<ScheduleRepository>(
  (ref) => DriftScheduleRepository(ref.watch(appDatabaseProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => DriftSettingsRepository(ref.watch(appDatabaseProvider)),
);

final appPreferencesProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(settingsRepositoryProvider).getAppPreferences(),
);

final backupRepositoryProvider = Provider<BackupRepository>(
  (ref) => LocalBackupRepository(
    database: ref.watch(appDatabaseProvider),
    scheduleRepository: ref.watch(scheduleRepositoryProvider),
    settingsRepository: ref.watch(settingsRepositoryProvider),
  ),
);

final syncQueueRepositoryProvider = Provider<SyncQueueRepository>(
  (ref) => DriftSyncQueueRepository(ref.watch(appDatabaseProvider)),
);

final onboardingDraftRepositoryProvider = Provider<OnboardingDraftRepository>(
  (ref) => const SharedPreferencesOnboardingDraftRepository(),
);

final profileIdProvider = Provider<String Function()>(
  (ref) =>
      () => const Uuid().v4(),
);

final dayOverrideIdProvider = Provider<String Function()>(
  (ref) =>
      () => const Uuid().v4(),
);

final utcNowProvider = Provider<DateTime Function()>(
  (ref) =>
      () => DateTime.now().toUtc(),
);
