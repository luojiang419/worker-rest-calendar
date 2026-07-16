import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:worker_rest_calendar/features/updater/data/windows_update_installer_launcher.dart';
import 'package:worker_rest_calendar/features/updater/domain/semantic_version.dart';
import 'package:worker_rest_calendar/features/updater/domain/update_models.dart';

void main() {
  test('复制独立 helper 并以参数列表安全传递中文空格路径', () async {
    if (!Platform.isWindows) return;
    final root = await Directory.systemTemp.createTemp('工作日历 启动器测试 ');
    addTearDown(() => root.delete(recursive: true));
    final appDirectory = Directory(path.join(root.path, '已安装 应用'));
    final updateDirectory = Directory(path.join(root.path, '更新 缓存'));
    await appDirectory.create(recursive: true);
    await updateDirectory.create(recursive: true);
    final app = File(path.join(appDirectory.path, 'worker_rest_calendar.exe'));
    final sourceHelper = File(
      path.join(appDirectory.path, WindowsUpdateInstallerLauncher.helperName),
    );
    final installer = File(path.join(updateDirectory.path, '安装 包.exe'));
    await app.writeAsBytes([1]);
    await sourceHelper.writeAsBytes([2]);
    await installer.writeAsBytes([3]);
    String? startedExecutable;
    List<String>? startedArguments;
    final launcher = WindowsUpdateInstallerLauncher(
      executablePath: app.path,
      processId: 4321,
      startDetached: (executable, arguments) async {
        startedExecutable = executable;
        startedArguments = arguments;
      },
    );

    await launcher.launch(
      PendingUpdate(
        version: const SemanticVersion(0, 1, 11),
        installerPath: installer.path,
        assetName: installer.path,
        size: 1,
        sha256: 'abc',
      ),
    );

    expect(await File(startedExecutable!).readAsBytes(), [2]);
    expect(startedArguments, contains('--old-pid=4321'));
    expect(startedArguments, contains('--installer=${installer.path}'));
    expect(startedArguments, contains('--install-dir=${appDirectory.path}'));
    expect(startedArguments, contains('--app-exe=${app.path}'));
  });

  test('缺少 helper 或安装包时拒绝退出旧程序', () async {
    if (!Platform.isWindows) return;
    final root = await Directory.systemTemp.createTemp('updater-missing-');
    addTearDown(() => root.delete(recursive: true));
    final app = File(path.join(root.path, 'worker_rest_calendar.exe'));
    final installer = File(path.join(root.path, 'installer.exe'));
    await app.writeAsBytes([1]);
    await installer.writeAsBytes([2]);
    final launcher = WindowsUpdateInstallerLauncher(
      executablePath: app.path,
      startDetached: (_, _) async => fail('不应启动'),
    );

    await expectLater(
      launcher.launch(
        PendingUpdate(
          version: const SemanticVersion(0, 1, 11),
          installerPath: installer.path,
          assetName: installer.path,
          size: 1,
          sha256: 'abc',
        ),
      ),
      throwsStateError,
    );
  });
}
