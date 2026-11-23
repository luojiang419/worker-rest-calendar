import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/core/widgets/app_button.dart';
import 'package:worker_rest_calendar/core/widgets/app_card.dart';
import 'package:worker_rest_calendar/core/widgets/app_state_view.dart';
import 'package:worker_rest_calendar/features/sync/application/data_management_controller.dart';
import 'package:worker_rest_calendar/features/sync/domain/backup_bundle.dart';

class DataManagementPage extends ConsumerWidget {
  const DataManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dataManagementControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('数据与同步')),
      body: state.when(
        loading: () => const Center(child: AppLoadingState(label: '正在读取本地数据')),
        error: (error, stackTrace) => Center(
          child: AppErrorState(
            title: '数据管理加载失败',
            message: '请稍后重试',
            onRetry: () => ref.invalidate(dataManagementControllerProvider),
          ),
        ),
        data: (value) => _DataManagementBody(state: value),
      ),
    );
  }
}

class _DataManagementBody extends ConsumerWidget {
  const _DataManagementBody({required this.state});

  final DataManagementState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final controller = ref.read(dataManagementControllerProvider.notifier);
    return ListView(
      padding: EdgeInsets.all(tokens.spacing.lg),
      children: [
        if (state.message != null) ...[
          Semantics(
            liveRegion: true,
            child: Text(
              state.message!,
              textAlign: TextAlign.center,
              style: TextStyle(color: tokens.colors.textSecondary),
            ),
          ),
          SizedBox(height: tokens.spacing.lg),
        ],
        AppCard(
          semanticLabel: '隐私说明',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('隐私说明', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: tokens.spacing.sm),
              Text(
                '班制、请假和备注默认只保存在本机。应用无需登录；云同步默认关闭，开启功能开关也不会在未配置服务端时上传数据。提醒文案不会包含备注。',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: tokens.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: tokens.spacing.lg),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('本地备份', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: tokens.spacing.sm),
              Text(
                '备份包含班制、单日调整、提醒和可迁移设置，不包含账号或密钥。',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: tokens.colors.textSecondary,
                ),
              ),
              SizedBox(height: tokens.spacing.lg),
              AppButton.primary(
                label: '导出 JSON 备份',
                icon: Icons.file_download_outlined,
                expand: true,
                onPressed: state.busy ? null : controller.exportData,
              ),
              SizedBox(height: tokens.spacing.sm),
              AppButton.secondary(
                label: '选择 JSON 并预览',
                icon: Icons.file_upload_outlined,
                expand: true,
                onPressed: state.busy ? null : controller.selectImport,
              ),
            ],
          ),
        ),
        if (state.preview != null) ...[
          SizedBox(height: tokens.spacing.lg),
          _ImportPreviewCard(
            fileName: state.selectedFileName ?? '备份文件',
            preview: state.preview!,
            busy: state.busy,
            onConfirm: () => _confirmImport(context, controller),
          ),
        ],
        SizedBox(height: tokens.spacing.lg),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('云同步', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: tokens.spacing.sm),
              Text(
                state.cloudSyncEnabled
                    ? '本地待同步 ${state.pendingSyncCount} 项。服务端需要单独配置后才会联网。'
                    : '当前已关闭。应用保持本地优先，不需要网络或登录。',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: tokens.colors.textSecondary,
                ),
              ),
              if (state.cloudSyncEnabled) ...[
                SizedBox(height: tokens.spacing.lg),
                AppButton.secondary(
                  label: '重试同步',
                  icon: Icons.sync_outlined,
                  expand: true,
                  onPressed: state.busy ? null : controller.retrySync,
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: tokens.spacing.lg),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('危险操作', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: tokens.spacing.sm),
              const Text('清空会删除本机班制、单日调整、提醒设置和同步队列。建议先导出备份。'),
              SizedBox(height: tokens.spacing.lg),
              AppButton.danger(
                label: '清空本地数据',
                icon: Icons.delete_forever_outlined,
                expand: true,
                onPressed: state.busy
                    ? null
                    : () => _confirmClear(context, controller),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmImport(
    BuildContext context,
    DataManagementController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认导入备份？'),
        content: const Text('导入将在一个事务中完成；如果中途失败，原数据不会改变。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认导入'),
          ),
        ],
      ),
    );
    if (confirmed == true) await controller.confirmImport();
  }

  Future<void> _confirmClear(
    BuildContext context,
    DataManagementController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空全部本地数据？'),
        content: const Text('此操作不可撤销。请确认你已经导出需要保留的备份。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: context.tokens.colors.danger,
            ),
            child: const Text('清空'),
          ),
        ],
      ),
    );
    if (confirmed == true &&
        await controller.clearAllData() &&
        context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
}

class _ImportPreviewCard extends StatelessWidget {
  const _ImportPreviewCard({
    required this.fileName,
    required this.preview,
    required this.busy,
    required this.onConfirm,
  });

  final String fileName;
  final ImportPreview preview;
  final bool busy;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('导入预览', style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: tokens.spacing.xs),
          Text(fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
          SizedBox(height: tokens.spacing.lg),
          _PreviewRow(label: '新增', value: preview.newRecords),
          _PreviewRow(label: '覆盖', value: preview.overwrittenRecords),
          _PreviewRow(label: '冲突', value: preview.conflictingRecords),
          _PreviewRow(label: '设置变更', value: preview.settingsWillChange ? 1 : 0),
          SizedBox(height: tokens.spacing.lg),
          AppButton.primary(
            label: '确认导入',
            expand: true,
            onPressed: busy ? null : onConfirm,
          ),
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: context.tokens.spacing.xs),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text('$value 条'),
      ],
    ),
  );
}
