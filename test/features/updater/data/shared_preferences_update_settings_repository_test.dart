import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker_rest_calendar/features/updater/data/shared_preferences_update_settings_repository.dart';
import 'package:worker_rest_calendar/features/updater/domain/semantic_version.dart';
import 'package:worker_rest_calendar/features/updater/domain/update_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('默认自动更新、自动代理和本机 7890', () async {
    final repository = SharedPreferencesUpdateSettingsRepository(
      await SharedPreferences.getInstance(),
    );

    final settings = await repository.load();

    expect(settings.policy, UpdatePolicy.automatic);
    expect(settings.networkMode, UpdateNetworkMode.automaticProxy);
    expect(settings.manualProxyUrl, 'http://127.0.0.1:7890');
    expect(settings.pending, isNull);
  });

  test('往返保存两个设置维度、pending 和 deferred', () async {
    final repository = SharedPreferencesUpdateSettingsRepository(
      await SharedPreferences.getInstance(),
    );
    const pending = PendingUpdate(
      version: SemanticVersion(0, 1, 11),
      installerPath: r'C:\更新 缓存\installer.exe',
      assetName: 'worker-rest-calendar-Setup-Windows-x64-v0.1.11.exe',
      size: 123,
      sha256: 'abc',
    );

    await repository.save(
      const UpdateSettings(
        policy: UpdatePolicy.manual,
        networkMode: UpdateNetworkMode.manualProxy,
        manualProxyUrl: 'socks5://127.0.0.1:1080',
        pending: pending,
        deferredVersion: SemanticVersion(0, 1, 11),
      ),
    );
    final restored = await repository.load();

    expect(restored.policy, UpdatePolicy.manual);
    expect(restored.networkMode, UpdateNetworkMode.manualProxy);
    expect(restored.manualProxyUrl, 'socks5://127.0.0.1:1080');
    expect(restored.pending?.installerPath, pending.installerPath);
    expect(restored.deferredVersion, const SemanticVersion(0, 1, 11));
  });
}
