import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/app/app_dependencies.dart';
import 'package:worker_rest_calendar/core/database/app_database.dart';
import 'package:worker_rest_calendar/core/theme/app_theme.dart';
import 'package:worker_rest_calendar/features/reminders/domain/reminder_preferences.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';
import 'package:worker_rest_calendar/features/sync/application/backup_file_gateway.dart';
import 'package:worker_rest_calendar/features/sync/application/data_management_controller.dart';
import 'package:worker_rest_calendar/features/sync/data/backup_codec.dart';
import 'package:worker_rest_calendar/features/sync/domain/backup_bundle.dart';
import 'package:worker_rest_calendar/features/sync/presentation/data_management_page.dart';

import '../../../helpers/test_models.dart';

void main() {
  testWidgets('支持导出并在导入前展示新增覆盖冲突预览', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final database = AppDatabase(NativeDatabase.memory());
    final json = const BackupCodec().encode(
      BackupBundle(
        schemaVersion: BackupBundle.currentSchemaVersion,
        profiles: [testProfile()],
        overrides: [testOverride()],
        reminderSettings: const ReminderPreferences(),
        appSettings: const AppPreferences(),
        exportedAt: DateTime.utc(2026, 7, 13),
      ),
    );
    final files = _FakeBackupFileGateway(json);
    addTearDown(database.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          backupFileGatewayProvider.overrideWithValue(files),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: const DataManagementPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('隐私说明'), findsOneWidget);
    expect(find.text('本地备份'), findsOneWidget);
    expect(find.textContaining('不需要网络或登录'), findsOneWidget);
    await tester.tap(find.text('导出 JSON 备份'));
    await tester.pumpAndSettle();
    expect(files.savedJson, isNotEmpty);
    expect(find.text('备份已保存'), findsOneWidget);

    await tester.tap(find.text('选择 JSON 并预览'));
    await tester.pumpAndSettle();

    expect(find.text('导入预览'), findsOneWidget);
    expect(find.text('backup.json'), findsOneWidget);
    expect(find.text('2 条'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

final class _FakeBackupFileGateway implements BackupFileGateway {
  _FakeBackupFileGateway(this.importJson);

  final String importJson;
  String savedJson = '';

  @override
  Future<SelectedBackupFile?> openJson() async =>
      SelectedBackupFile(name: 'backup.json', contents: importJson);

  @override
  Future<String?> saveJson({
    required String suggestedName,
    required String json,
  }) async {
    savedJson = json;
    return 'saved/$suggestedName';
  }
}
