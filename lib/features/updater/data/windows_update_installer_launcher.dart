import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:worker_rest_calendar/features/updater/application/update_installer_launcher.dart';
import 'package:worker_rest_calendar/features/updater/domain/update_models.dart';

typedef DetachedProcessStarter =
    Future<void> Function(String executable, List<String> arguments);

final class WindowsUpdateInstallerLauncher implements UpdateInstallerLauncher {
  WindowsUpdateInstallerLauncher({
    String? executablePath,
    int? processId,
    DetachedProcessStarter? startDetached,
  }) : _executablePath = executablePath ?? Platform.resolvedExecutable,
       _processId = processId ?? pid,
       _startDetached = startDetached ?? _startDetachedProcess;

  static const helperName = 'worker_rest_calendar_updater.exe';

  final String _executablePath;
  final int _processId;
  final DetachedProcessStarter _startDetached;

  @override
  Future<void> launch(PendingUpdate pending) async {
    if (!Platform.isWindows) {
      throw UnsupportedError('当前平台不支持 Windows 自动安装');
    }
    final sourceHelper = File(
      path.join(path.dirname(_executablePath), helperName),
    );
    if (!await sourceHelper.exists()) {
      throw StateError('独立更新程序不存在：${sourceHelper.path}');
    }
    final installer = File(pending.installerPath);
    if (!await installer.exists()) {
      throw StateError('待安装更新包不存在：${installer.path}');
    }
    final sessionDirectory = Directory(
      path.join(installer.parent.path, 'helper-${pending.version}'),
    );
    await sessionDirectory.create(recursive: true);
    final helper = await sourceHelper.copy(
      path.join(sessionDirectory.path, helperName),
    );
    final logPath = path.join(
      installer.parent.path,
      'updater-${pending.version}.log',
    );
    await _startDetached(helper.path, [
      '--old-pid=$_processId',
      '--installer=${installer.path}',
      '--install-dir=${path.dirname(_executablePath)}',
      '--app-exe=$_executablePath',
      '--log=$logPath',
    ]);
  }

  static Future<void> _startDetachedProcess(
    String executable,
    List<String> arguments,
  ) async {
    await Process.start(executable, arguments, mode: ProcessStartMode.detached);
  }
}
