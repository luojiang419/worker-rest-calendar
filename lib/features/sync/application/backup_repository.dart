import 'package:worker_rest_calendar/features/sync/domain/backup_bundle.dart';

abstract interface class BackupRepository {
  Future<String> exportJson({required DateTime exportedAt});

  BackupBundle parseJson(String source);

  Future<ImportPreview> previewImport(BackupBundle bundle);

  Future<void> importBundle(BackupBundle bundle);

  Future<void> clearAllData();
}
