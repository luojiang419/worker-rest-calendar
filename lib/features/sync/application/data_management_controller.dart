import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:worker_rest_calendar/app/app_dependencies.dart';
import 'package:worker_rest_calendar/features/home_widget/application/home_widget_sync_controller.dart';
import 'package:worker_rest_calendar/features/onboarding/application/onboarding_controller.dart';
import 'package:worker_rest_calendar/features/reminders/application/reminder_controller.dart';
import 'package:worker_rest_calendar/features/schedule/application/active_schedule_controller.dart';
import 'package:worker_rest_calendar/features/sync/application/backup_file_gateway.dart';
import 'package:worker_rest_calendar/features/sync/data/file_selector_backup_gateway.dart';
import 'package:worker_rest_calendar/features/sync/domain/backup_bundle.dart';

final cloudSyncEnabledProvider = Provider<bool>(
  (ref) => const bool.fromEnvironment('ENABLE_CLOUD_SYNC'),
);

final backupFileGatewayProvider = Provider<BackupFileGateway>(
  (ref) => const FileSelectorBackupGateway(),
);

final dataManagementControllerProvider =
    AsyncNotifierProvider<DataManagementController, DataManagementState>(
      DataManagementController.new,
    );

final class DataManagementState {
  const DataManagementState({
    required this.cloudSyncEnabled,
    required this.pendingSyncCount,
    this.selectedFileName,
    this.preview,
    this.bundle,
    this.busy = false,
    this.message,
  });

  final bool cloudSyncEnabled;
  final int pendingSyncCount;
  final String? selectedFileName;
  final ImportPreview? preview;
  final BackupBundle? bundle;
  final bool busy;
  final String? message;

  DataManagementState copyWith({
    String? selectedFileName,
    ImportPreview? preview,
    BackupBundle? bundle,
    bool? busy,
    String? message,
    bool clearImport = false,
  }) => DataManagementState(
    cloudSyncEnabled: cloudSyncEnabled,
    pendingSyncCount: pendingSyncCount,
    selectedFileName: clearImport
        ? null
        : selectedFileName ?? this.selectedFileName,
    preview: clearImport ? null : preview ?? this.preview,
    bundle: clearImport ? null : bundle ?? this.bundle,
    busy: busy ?? this.busy,
    message: message,
  );
}

final class DataManagementController
    extends AsyncNotifier<DataManagementState> {
  @override
  Future<DataManagementState> build() async => DataManagementState(
    cloudSyncEnabled: ref.watch(cloudSyncEnabledProvider),
    pendingSyncCount:
        (await ref.watch(syncQueueRepositoryProvider).getPending()).length,
  );

  Future<void> exportData() async {
    final current = state.requireValue;
    state = AsyncData(current.copyWith(busy: true));
    try {
      final now = ref.read(utcNowProvider)();
      final json = await ref
          .read(backupRepositoryProvider)
          .exportJson(exportedAt: now);
      final name =
          'worker-rest-calendar-${DateFormat('yyyyMMdd-HHmm').format(now.toLocal())}.json';
      final path = await ref
          .read(backupFileGatewayProvider)
          .saveJson(suggestedName: name, json: json);
      state = AsyncData(
        current.copyWith(message: path == null ? '已取消导出' : '备份已保存'),
      );
    } on Object {
      state = AsyncData(current.copyWith(message: '导出失败，请重试'));
    }
  }

  Future<void> selectImport() async {
    final current = state.requireValue;
    state = AsyncData(current.copyWith(busy: true, clearImport: true));
    try {
      final file = await ref.read(backupFileGatewayProvider).openJson();
      if (file == null) {
        state = AsyncData(current.copyWith(message: '已取消导入'));
        return;
      }
      final repository = ref.read(backupRepositoryProvider);
      final bundle = repository.parseJson(file.contents);
      final preview = await repository.previewImport(bundle);
      state = AsyncData(
        current.copyWith(
          selectedFileName: file.name,
          bundle: bundle,
          preview: preview,
          message: '请确认导入影响',
        ),
      );
    } on Object {
      state = AsyncData(
        current.copyWith(message: '备份文件无效或不兼容', clearImport: true),
      );
    }
  }

  Future<bool> confirmImport() async {
    final current = state.requireValue;
    final bundle = current.bundle;
    if (bundle == null) return false;
    state = AsyncData(current.copyWith(busy: true));
    try {
      await ref.read(backupRepositoryProvider).importBundle(bundle);
      _refreshConsumers();
      state = AsyncData(current.copyWith(message: '数据已恢复', clearImport: true));
      return true;
    } on Object {
      state = AsyncData(current.copyWith(message: '导入失败，原数据未改变'));
      return false;
    }
  }

  Future<bool> clearAllData() async {
    final current = state.requireValue;
    state = AsyncData(current.copyWith(busy: true));
    try {
      await ref.read(backupRepositoryProvider).clearAllData();
      _refreshConsumers();
      state = AsyncData(
        current.copyWith(message: '本地数据已清空', clearImport: true),
      );
      return true;
    } on Object {
      state = AsyncData(current.copyWith(message: '清空失败，请重试'));
      return false;
    }
  }

  Future<void> retrySync() async {
    final current = state.requireValue;
    final pending = await ref.read(syncQueueRepositoryProvider).getPending();
    state = AsyncData(
      DataManagementState(
        cloudSyncEnabled: current.cloudSyncEnabled,
        pendingSyncCount: pending.length,
        selectedFileName: current.selectedFileName,
        preview: current.preview,
        bundle: current.bundle,
        message: '云服务尚未配置，未发送网络请求',
      ),
    );
  }

  void _refreshConsumers() {
    ref.invalidate(activeScheduleControllerProvider);
    ref.invalidate(reminderControllerProvider);
    ref.invalidate(homeWidgetSyncControllerProvider);
    ref.invalidate(onboardingControllerProvider);
  }
}
