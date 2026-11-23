import 'package:worker_rest_calendar/core/database/app_database.dart';
import 'package:worker_rest_calendar/features/schedule/application/schedule_repository.dart';
import 'package:worker_rest_calendar/features/schedule/domain/stored_day_override.dart';
import 'package:worker_rest_calendar/features/settings/application/settings_repository.dart';
import 'package:worker_rest_calendar/features/sync/application/backup_repository.dart';
import 'package:worker_rest_calendar/features/sync/data/backup_codec.dart';
import 'package:worker_rest_calendar/features/sync/domain/backup_bundle.dart';

final class LocalBackupRepository implements BackupRepository {
  const LocalBackupRepository({
    required AppDatabase database,
    required ScheduleRepository scheduleRepository,
    required SettingsRepository settingsRepository,
    BackupCodec codec = const BackupCodec(),
  }) : _database = database,
       _scheduleRepository = scheduleRepository,
       _settingsRepository = settingsRepository,
       _codec = codec;

  final AppDatabase _database;
  final ScheduleRepository _scheduleRepository;
  final SettingsRepository _settingsRepository;
  final BackupCodec _codec;

  @override
  Future<String> exportJson({required DateTime exportedAt}) async {
    final profiles = await _scheduleRepository.getProfiles(
      includeDeleted: true,
    );
    final overrides = <StoredDayOverride>[];
    for (final profile in profiles) {
      overrides.addAll(
        await _scheduleRepository.getDayOverrides(
          profile.id,
          includeDeleted: true,
        ),
      );
    }

    return _codec.encode(
      BackupBundle(
        schemaVersion: BackupBundle.currentSchemaVersion,
        profiles: profiles,
        overrides: overrides,
        reminderSettings: await _settingsRepository.getReminderPreferences(),
        appSettings: await _settingsRepository.getAppPreferences(),
        exportedAt: exportedAt,
      ),
    );
  }

  @override
  BackupBundle parseJson(String source) => _codec.decode(source);

  @override
  Future<ImportPreview> previewImport(BackupBundle bundle) async {
    final existingProfiles = {
      for (final profile in await _scheduleRepository.getProfiles(
        includeDeleted: true,
      ))
        profile.id: profile,
    };
    final existingOverrides = <String, StoredDayOverride>{};
    final existingOverrideDates = <String, StoredDayOverride>{};
    for (final profile in existingProfiles.values) {
      for (final override in await _scheduleRepository.getDayOverrides(
        profile.id,
        includeDeleted: true,
      )) {
        existingOverrides[override.id] = override;
        existingOverrideDates['${override.profileId}/${override.date}'] =
            override;
      }
    }

    var newRecords = 0;
    var overwrittenRecords = 0;
    var conflictingRecords = 0;
    for (final incoming in bundle.profiles) {
      final existing = existingProfiles[incoming.id];
      if (existing == null) {
        newRecords++;
      } else if (existing.updatedAt.isAfter(incoming.updatedAt)) {
        conflictingRecords++;
      } else {
        overwrittenRecords++;
      }
    }
    for (final incoming in bundle.overrides) {
      final byId = existingOverrides[incoming.id];
      final byDate =
          existingOverrideDates['${incoming.profileId}/${incoming.date}'];
      final existing = byId ?? byDate;
      if (existing == null) {
        newRecords++;
      } else if (existing.id != incoming.id ||
          existing.updatedAt.isAfter(incoming.updatedAt)) {
        conflictingRecords++;
      } else {
        overwrittenRecords++;
      }
    }

    return ImportPreview(
      newRecords: newRecords,
      overwrittenRecords: overwrittenRecords,
      conflictingRecords: conflictingRecords,
      settingsWillChange: true,
    );
  }

  @override
  Future<void> importBundle(BackupBundle bundle) {
    if (bundle.schemaVersion != BackupBundle.currentSchemaVersion) {
      throw StateError('导入 bundle 未通过 schema 校验');
    }

    return _database.transaction(() async {
      final existingProfiles = {
        for (final profile in await _scheduleRepository.getProfiles(
          includeDeleted: true,
        ))
          profile.id: profile,
      };
      final existingOverrides = <String, StoredDayOverride>{};
      for (final profile in existingProfiles.values) {
        for (final override in await _scheduleRepository.getDayOverrides(
          profile.id,
          includeDeleted: true,
        )) {
          existingOverrides['${override.profileId}/${override.date}'] =
              override;
        }
      }
      for (final profile in bundle.profiles) {
        final existing = existingProfiles[profile.id];
        if (existing != null && existing.updatedAt.isAfter(profile.updatedAt)) {
          continue;
        }
        await _scheduleRepository.saveProfile(profile);
      }
      for (final override in bundle.overrides) {
        final existing =
            existingOverrides['${override.profileId}/${override.date}'];
        if (existing != null &&
            existing.updatedAt.isAfter(override.updatedAt)) {
          continue;
        }
        await _scheduleRepository.saveDayOverride(override);
      }
      await _settingsRepository.saveReminderPreferences(
        bundle.reminderSettings,
      );
      await _settingsRepository.saveAppPreferences(bundle.appSettings);
    });
  }

  @override
  Future<void> clearAllData() => _database.transaction(() async {
    await _database.delete(_database.syncQueue).go();
    await _database.delete(_database.dayOverrides).go();
    await _database.delete(_database.scheduleProfiles).go();
    await _database.delete(_database.reminderSettings).go();
    await _database.delete(_database.appSettings).go();
    await _database
        .into(_database.reminderSettings)
        .insert(const ReminderSettingsCompanion());
    await _database
        .into(_database.appSettings)
        .insert(const AppSettingsCompanion());
  });
}
