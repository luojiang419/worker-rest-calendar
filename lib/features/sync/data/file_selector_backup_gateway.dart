import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:worker_rest_calendar/features/sync/application/backup_file_gateway.dart';

final class FileSelectorBackupGateway implements BackupFileGateway {
  const FileSelectorBackupGateway();

  static const _jsonType = XTypeGroup(
    label: 'JSON 备份',
    extensions: ['json'],
    mimeTypes: ['application/json'],
  );

  @override
  Future<String?> saveJson({
    required String suggestedName,
    required String json,
  }) async {
    final location = await getSaveLocation(
      suggestedName: suggestedName,
      acceptedTypeGroups: const [_jsonType],
      confirmButtonText: '保存备份',
    );
    if (location == null) return null;
    final file = XFile.fromData(
      utf8.encode(json),
      name: suggestedName,
      mimeType: 'application/json',
    );
    await file.saveTo(location.path);
    return location.path;
  }

  @override
  Future<SelectedBackupFile?> openJson() async {
    final file = await openFile(
      acceptedTypeGroups: const [_jsonType],
      confirmButtonText: '选择备份',
    );
    if (file == null) return null;
    return SelectedBackupFile(
      name: file.name,
      contents: await file.readAsString(),
    );
  }
}
