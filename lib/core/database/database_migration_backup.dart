import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

Future<File?> backupDatabaseBeforeMigration(
  File file, {
  required int currentSchemaVersion,
}) async {
  if (!await file.exists()) {
    return null;
  }

  final connection = sqlite3.open(file.path, mode: OpenMode.readOnly);
  final version = connection.userVersion;
  connection.dispose();
  if (version <= 0 || version >= currentSchemaVersion) {
    return null;
  }

  final backup = File('${file.path}.migration-v$version.bak');
  if (!await backup.exists()) {
    await file.copy(backup.path);
  }
  return backup;
}
