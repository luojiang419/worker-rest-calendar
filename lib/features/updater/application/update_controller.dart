import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker_rest_calendar/features/updater/application/update_installer_launcher.dart';
import 'package:worker_rest_calendar/features/updater/application/update_settings_repository.dart';
import 'package:worker_rest_calendar/features/updater/data/shared_preferences_update_settings_repository.dart';
import 'package:worker_rest_calendar/features/updater/data/update_proxy_resolver.dart';
import 'package:worker_rest_calendar/features/updater/data/update_service.dart';
import 'package:worker_rest_calendar/features/updater/data/update_transport.dart';
import 'package:worker_rest_calendar/features/updater/data/windows_update_installer_launcher.dart';
import 'package:worker_rest_calendar/features/updater/domain/semantic_version.dart';
import 'package:worker_rest_calendar/features/updater/domain/update_config.dart';
import 'package:worker_rest_calendar/features/updater/domain/update_models.dart';

enum UpdateControllerStatus {
  idle,
  checking,
  downloading,
  ready,
  noUpdate,
  installing,
  error,
}

final class UpdateControllerState {
  const UpdateControllerState({
    required this.settings,
    this.status = UpdateControllerStatus.idle,
    this.message,
  });

  final UpdateSettings settings;
  final UpdateControllerStatus status;
  final String? message;

  PendingUpdate? get pending => settings.pending;

  UpdateControllerState copyWith({
    UpdateSettings? settings,
    UpdateControllerStatus? status,
    String? message,
    bool clearMessage = false,
  }) => UpdateControllerState(
    settings: settings ?? this.settings,
    status: status ?? this.status,
    message: clearMessage ? null : message ?? this.message,
  );
}

final updatePlatformSupportedProvider = Provider<bool>(
  (ref) => Platform.isWindows,
);

final currentAppVersionProvider = FutureProvider<SemanticVersion>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return SemanticVersion.parse(info.version);
});

final updateConfigProvider = FutureProvider<UpdateConfig>((ref) async {
  return UpdateConfig(
    repositoryOwner: 'luojiang419',
    repositoryName: 'worker-rest-calendar',
    currentVersion: await ref.watch(currentAppVersionProvider.future),
  );
});

final updateSettingsRepositoryProvider =
    FutureProvider<UpdateSettingsRepository>(
      (ref) async => SharedPreferencesUpdateSettingsRepository(
        await SharedPreferences.getInstance(),
      ),
    );

final updateProxyResolverProvider = Provider<UpdateProxyResolver>(
  (ref) => UpdateProxyResolver(),
);

final updateTransportProvider = Provider<UpdateTransport>(
  (ref) => const CurlUpdateTransport(),
);

final updateServiceProvider = FutureProvider<UpdateService>(
  (ref) async => UpdateService(
    config: await ref.watch(updateConfigProvider.future),
    transport: ref.watch(updateTransportProvider),
  ),
);

final updateCacheDirectoryProvider = FutureProvider<Directory>((ref) async {
  final root = await getApplicationSupportDirectory();
  return Directory(
    '${root.path}${Platform.pathSeparator}updates${Platform.pathSeparator}windows-x64',
  );
});

final updateInstallerLauncherProvider = Provider<UpdateInstallerLauncher>(
  (ref) => Platform.isWindows
      ? WindowsUpdateInstallerLauncher()
      : const UnsupportedUpdateInstallerLauncher(),
);

final updateControllerProvider =
    AsyncNotifierProvider<UpdateController, UpdateControllerState>(
      UpdateController.new,
    );

final class UpdateController extends AsyncNotifier<UpdateControllerState> {
  Future<void>? _operation;
  var _startupCheckStarted = false;

  UpdateSettingsRepository get _repository =>
      ref.read(updateSettingsRepositoryProvider).requireValue;

  @override
  Future<UpdateControllerState> build() async {
    final repository = await ref.watch(updateSettingsRepositoryProvider.future);
    var settings = await repository.load();
    if (!ref.watch(updatePlatformSupportedProvider)) {
      return UpdateControllerState(settings: settings);
    }
    final service = await ref.watch(updateServiceProvider.future);
    final pending = settings.pending;
    if (pending != null && !await service.validatePending(pending)) {
      settings = settings.copyWith(
        clearPending: true,
        clearDeferredVersion: true,
      );
      await repository.save(settings);
    }
    return UpdateControllerState(
      settings: settings,
      status: settings.pending == null
          ? UpdateControllerStatus.idle
          : UpdateControllerStatus.ready,
    );
  }

  Future<void> startStartupCheck() async {
    if (_startupCheckStarted || !ref.read(updatePlatformSupportedProvider)) {
      return;
    }
    _startupCheckStarted = true;
    final current = state.requireValue;
    if (current.settings.pending != null) return;
    if (current.settings.checksOnStartup) {
      await _runCheck(isManual: false);
    }
  }

  Future<void> checkManually() async {
    if (!state.requireValue.settings.allowsManualCheck) return;
    await _runCheck(isManual: true);
  }

  Future<void> setPolicy(UpdatePolicy policy) =>
      _saveSettings(state.requireValue.settings.copyWith(policy: policy));

  Future<void> setNetworkMode(UpdateNetworkMode mode) =>
      _saveSettings(state.requireValue.settings.copyWith(networkMode: mode));

  Future<void> setManualProxyUrl(String url) async {
    UpdateProxyResolver.validateProxyUri(url);
    await _saveSettings(
      state.requireValue.settings.copyWith(manualProxyUrl: url.trim()),
    );
  }

  Future<void> deferPending() async {
    final pending = state.requireValue.pending;
    if (pending == null) return;
    await _saveSettings(
      state.requireValue.settings.copyWith(deferredVersion: pending.version),
      status: UpdateControllerStatus.ready,
      message: '将在下次启动时安装 ${pending.version}',
    );
  }

  Future<void> installPending() async {
    final pending = state.requireValue.pending;
    if (pending == null) return;
    state = AsyncData(
      state.requireValue.copyWith(
        status: UpdateControllerStatus.installing,
        message: '正在启动更新程序',
      ),
    );
    try {
      await ref.read(updateInstallerLauncherProvider).launch(pending);
    } catch (error) {
      state = AsyncData(
        state.requireValue.copyWith(
          status: UpdateControllerStatus.error,
          message: _friendlyError(error),
        ),
      );
      rethrow;
    }
  }

  Future<void> _runCheck({required bool isManual}) {
    final running = _operation;
    if (running != null) return running;
    final operation = _performCheck(isManual: isManual);
    _operation = operation;
    return operation.whenComplete(() => _operation = null);
  }

  Future<void> _performCheck({required bool isManual}) async {
    state = AsyncData(
      state.requireValue.copyWith(
        status: UpdateControllerStatus.checking,
        message: '正在检查更新',
      ),
    );
    try {
      final settings = state.requireValue.settings;
      final route = await ref
          .read(updateProxyResolverProvider)
          .resolve(settings);
      final service = await ref.read(updateServiceProvider.future);
      final result = await service.check(route);
      if (result is NoUpdateAvailable) {
        state = AsyncData(
          state.requireValue.copyWith(
            status: UpdateControllerStatus.noUpdate,
            message: isManual ? '当前已是最新版本' : null,
            clearMessage: !isManual,
          ),
        );
        return;
      }
      final available = result as UpdateAvailable;
      state = AsyncData(
        state.requireValue.copyWith(
          status: UpdateControllerStatus.downloading,
          message: '正在下载 ${available.release.version}',
        ),
      );
      final pending = await service.download(
        available,
        await ref.read(updateCacheDirectoryProvider.future),
        route,
      );
      final updatedSettings = state.requireValue.settings.copyWith(
        pending: pending,
        clearDeferredVersion: true,
      );
      await _repository.save(updatedSettings);
      state = AsyncData(
        UpdateControllerState(
          settings: updatedSettings,
          status: UpdateControllerStatus.ready,
          message: '更新 ${pending.version} 已下载完成',
        ),
      );
    } catch (error) {
      state = AsyncData(
        state.requireValue.copyWith(
          status: UpdateControllerStatus.error,
          message: _friendlyError(error),
        ),
      );
      if (isManual) rethrow;
    }
  }

  Future<void> _saveSettings(
    UpdateSettings settings, {
    UpdateControllerStatus? status,
    String? message,
  }) async {
    await _repository.save(settings);
    state = AsyncData(
      state.requireValue.copyWith(
        settings: settings,
        status: status,
        message: message,
      ),
    );
  }

  String _friendlyError(Object error) {
    if (error is FormatException) return error.message;
    if (error is UpdateContractException) return error.message;
    if (error is UpdateTransportException) return error.message;
    return '更新暂时失败，请稍后重试';
  }
}
