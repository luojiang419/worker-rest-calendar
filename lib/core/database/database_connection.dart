import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:worker_rest_calendar/core/database/app_database.dart';
import 'package:worker_rest_calendar/core/database/database_migration_backup.dart';

AppDatabase openAppDatabase() {
  return AppDatabase(
    LazyDatabase(() async {
      final directory = await getApplicationSupportDirectory();
      final file = File(p.join(directory.path, 'worker_rest_calendar.sqlite'));
      await backupDatabaseBeforeMigration(file, currentSchemaVersion: 2);
      return NativeDatabase.createInBackground(file);
    }),
  );
}
