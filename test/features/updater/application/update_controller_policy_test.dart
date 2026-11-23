import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/features/updater/application/update_controller.dart';
import 'package:worker_rest_calendar/features/updater/application/update_settings_repository.dart';
import 'package:worker_rest_calendar/features/updater/data/update_proxy_resolver.dart';
import 'package:worker_rest_calendar/features/updater/data/update_transport.dart';
import 'package:worker_rest_calendar/features/updater/domain/semantic_version.dart';
import 'package:worker_rest_calendar/features/updater/domain/update_models.dart';

void main() {
  test('更新策略与网络模式九种组合严格决定启动检查', () async {
    for (final policy in UpdatePolicy.values) {
      for (final networkMode in UpdateNetworkMode.values) {
        final transport = _CountingTransport();
        final repository = _MemorySettingsRepository(
          UpdateSettings(policy: policy, networkMode: networkMode),
        );
        final container = _container(transport, repository);
        addTearDown(container.dispose);
        await container.read(updateControllerProvider.future);

        await container
            .read(updateControllerProvider.notifier)
            .startStartupCheck();

        expect(
          transport.getCount,
          policy == UpdatePolicy.automatic ? 1 : 0,
          reason: '${policy.name} × ${networkMode.name}',
        );
      }
    }
  });

  test('手动检查在 automatic/manual 可用，在 disabled 禁用', () async {
    for (final policy in UpdatePolicy.values) {
      final transport = _CountingTransport();
      final repository = _MemorySettingsRepository(
        UpdateSettings(policy: policy, networkMode: UpdateNetworkMode.direct),
      );
      final container = _container(transport, repository);
      addTearDown(container.dispose);
      await container.read(updateControllerProvider.future);

      await container.read(updateControllerProvider.notifier).checkManually();

      expect(
        transport.getCount,
        policy == UpdatePolicy.disabled ? 0 : 1,
        reason: policy.name,
      );
    }
  });
}

ProviderContainer _container(
  _CountingTransport transport,
  _MemorySettingsRepository repository,
) => ProviderContainer(
  overrides: [
    updatePlatformSupportedProvider.overrideWithValue(true),
    currentAppVersionProvider.overrideWith(
      (ref) async => const SemanticVersion(0, 1, 10),
    ),
    updateSettingsRepositoryProvider.overrideWith((ref) async => repository),
    updateTransportProvider.overrideWithValue(transport),
    updateProxyResolverProvider.overrideWithValue(
      UpdateProxyResolver(
        environment: {'HTTPS_PROXY': 'http://127.0.0.1:7890'},
        probe: (_, _) async => false,
      ),
    ),
  ],
);

final class _MemorySettingsRepository implements UpdateSettingsRepository {
  _MemorySettingsRepository(this.settings);

  UpdateSettings settings;

  @override
  Future<UpdateSettings> load() async => settings;

  @override
  Future<void> save(UpdateSettings settings) async {
    this.settings = settings;
  }
}

final class _CountingTransport implements UpdateTransport {
  var getCount = 0;

  @override
  Future<List<int>> get(Uri uri, NetworkRoute route) async {
    getCount++;
    return utf8.encode(
      jsonEncode({
        'tag_name': 'v0.1.10',
        'draft': false,
        'prerelease': false,
        'html_url': 'https://example.test/release',
        'assets': <Object?>[],
      }),
    );
  }

  @override
  Future<void> download(Uri uri, File destination, NetworkRoute route) async {
    fail('无更新时不应下载');
  }
}
