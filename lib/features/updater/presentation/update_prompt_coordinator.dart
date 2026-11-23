import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_rest_calendar/features/desktop_widget/application/desktop_widget_controller.dart';
import 'package:worker_rest_calendar/features/updater/application/update_controller.dart';

final class UpdatePromptCoordinator extends ConsumerStatefulWidget {
  const UpdatePromptCoordinator({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<UpdatePromptCoordinator> createState() =>
      _UpdatePromptCoordinatorState();
}

final class _UpdatePromptCoordinatorState
    extends ConsumerState<UpdatePromptCoordinator> {
  String? _shownVersion;
  var _dialogVisible = false;
  var _startupScheduled = false;
  var _deferredInstallScheduled = false;

  @override
  Widget build(BuildContext context) {
    final updateState = ref.watch(updateControllerProvider);
    if (!_startupScheduled && updateState.hasValue) {
      _startupScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          unawaited(
            ref.read(updateControllerProvider.notifier).startStartupCheck(),
          );
        }
      });
    }
    ref.listen(updateControllerProvider, (previous, next) {
      final value = next.value;
      final pending = value?.pending;
      if (value?.status != UpdateControllerStatus.ready || pending == null) {
        return;
      }
      if (value!.settings.deferredVersion == pending.version) {
        if (!_deferredInstallScheduled) {
          _deferredInstallScheduled = true;
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _installDeferred(),
          );
        }
        return;
      }
      if (_dialogVisible || _shownVersion == pending.version.toString()) return;
      _shownVersion = pending.version.toString();
      WidgetsBinding.instance.addPostFrameCallback((_) => _showPrompt());
    });
    return widget.child;
  }

  Future<void> _installDeferred() async {
    if (!mounted) return;
    try {
      await ref.read(updateControllerProvider.notifier).installPending();
      await ref.read(desktopWidgetControllerProvider.notifier).exit();
    } catch (_) {
      _deferredInstallScheduled = false;
    }
  }

  Future<void> _showPrompt() async {
    final value = ref.read(updateControllerProvider).value;
    final pending = value?.pending;
    if (!mounted || pending == null || _dialogVisible) return;
    _dialogVisible = true;
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('更新已下载完成'),
          content: Text('新版本 ${pending.version} 已准备好。可以现在更新并重启，也可以安排到下次启动时更新。'),
          actions: [
            TextButton(
              onPressed: () async {
                await ref
                    .read(updateControllerProvider.notifier)
                    .deferPending();
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              },
              child: const Text('下次启动更新'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  await ref
                      .read(updateControllerProvider.notifier)
                      .installPending();
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                  await ref
                      .read(desktopWidgetControllerProvider.notifier)
                      .exit();
                } catch (_) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(content: Text('更新程序启动失败，请稍后重试')),
                    );
                  }
                }
              },
              child: const Text('立即更新'),
            ),
          ],
        ),
      );
    } finally {
      _dialogVisible = false;
    }
  }
}
