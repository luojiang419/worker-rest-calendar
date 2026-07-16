import 'package:worker_rest_calendar/features/updater/domain/update_models.dart';

abstract interface class UpdateInstallerLauncher {
  Future<void> launch(PendingUpdate pending);
}

final class UnsupportedUpdateInstallerLauncher
    implements UpdateInstallerLauncher {
  const UnsupportedUpdateInstallerLauncher();

  @override
  Future<void> launch(PendingUpdate pending) {
    throw UnsupportedError('当前平台不支持自动安装更新');
  }
}
