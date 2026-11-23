import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/features/updater/data/update_service.dart';
import 'package:worker_rest_calendar/features/updater/data/update_transport.dart';
import 'package:worker_rest_calendar/features/updater/domain/semantic_version.dart';
import 'package:worker_rest_calendar/features/updater/domain/update_config.dart';
import 'package:worker_rest_calendar/features/updater/domain/update_models.dart';

void main() {
  const config = UpdateConfig(
    repositoryOwner: 'luojiang419',
    repositoryName: 'worker-rest-calendar',
    currentVersion: SemanticVersion(0, 1, 10),
  );
  const route = NetworkRoute(mode: UpdateNetworkMode.direct);

  test('解析 Latest 并只在远端更高时报告更新', () async {
    final transport = _FakeTransport();
    final service = UpdateService(config: config, transport: transport);
    transport.getResponse = utf8.encode(_releaseJson('v0.1.11'));

    final newer = await service.check(route);
    expect(newer, isA<UpdateAvailable>());

    transport.getResponse = utf8.encode(_releaseJson('v0.1.10'));
    final equal = await service.check(route);
    expect(equal, isA<NoUpdateAvailable>());

    transport.getResponse = utf8.encode(_releaseJson('v0.1.9'));
    final older = await service.check(route);
    expect(older, isA<NoUpdateAvailable>());
  });

  test('下载使用 part 并验证大小与 SHA-256 后生成 pending', () async {
    final bytes = utf8.encode('真实安装包内容');
    final digest = sha256.convert(bytes).toString();
    final installerName = config.installerAssetName(
      const SemanticVersion(0, 1, 11),
    );
    final transport = _FakeTransport(downloadBytes: bytes);
    final service = UpdateService(config: config, transport: transport);
    transport.getResponse = utf8.encode('$digest  $installerName\n');
    final temp = await Directory.systemTemp.createTemp('工作日历 更新测试 ');
    addTearDown(() => temp.delete(recursive: true));
    final available = _available(config, bytes.length);

    final pending = await service.download(available, temp, route);

    expect(pending.assetName, installerName);
    expect(pending.sha256, digest);
    expect(await File(pending.installerPath).readAsBytes(), bytes);
    expect(await File('${pending.installerPath}.part').exists(), isFalse);
    expect(await service.validatePending(pending), isTrue);
  });

  test('摘要不一致时删除 part 并失败关闭', () async {
    final bytes = utf8.encode('损坏内容');
    final installerName = config.installerAssetName(
      const SemanticVersion(0, 1, 11),
    );
    final transport = _FakeTransport(downloadBytes: bytes);
    final service = UpdateService(config: config, transport: transport);
    final wrongDigest = List.filled(64, '0').join();
    transport.getResponse = utf8.encode('$wrongDigest  $installerName\n');
    final temp = await Directory.systemTemp.createTemp('updater-corrupt-');
    addTearDown(() => temp.delete(recursive: true));

    await expectLater(
      service.download(_available(config, bytes.length), temp, route),
      throwsA(isA<UpdateContractException>()),
    );
    expect(
      await File(
        '${temp.path}${Platform.pathSeparator}$installerName.part',
      ).exists(),
      isFalse,
    );
  });
}

UpdateAvailable _available(UpdateConfig config, int size) {
  const version = SemanticVersion(0, 1, 11);
  final installer = ReleaseAsset(
    name: config.installerAssetName(version),
    downloadUri: Uri.parse('https://example.test/installer'),
    size: size,
  );
  final checksum = ReleaseAsset(
    name: config.checksumAssetName(version),
    downloadUri: Uri.parse('https://example.test/checksum'),
    size: 100,
  );
  final release = UpdateRelease(
    version: version,
    assets: [installer, checksum],
    htmlUri: Uri.parse('https://example.test/release'),
  );
  return UpdateAvailable(
    release: release,
    assets: UpdateReleaseAssets(installer: installer, checksum: checksum),
  );
}

String _releaseJson(String tag) => jsonEncode({
  'tag_name': tag,
  'draft': false,
  'prerelease': false,
  'html_url': 'https://github.com/luojiang419/worker-rest-calendar/releases',
  'assets': [
    {
      'name': 'worker-rest-calendar-Setup-Windows-x64-$tag.exe.sha256',
      'browser_download_url': 'https://example.test/checksum',
      'size': 100,
    },
    {
      'name': 'worker-rest-calendar-Setup-Windows-x64-$tag.exe',
      'browser_download_url': 'https://example.test/installer',
      'size': 12000000,
    },
  ],
});

final class _FakeTransport implements UpdateTransport {
  _FakeTransport({this.downloadBytes = const []});

  List<int> getResponse = const [];
  final List<int> downloadBytes;

  @override
  Future<List<int>> get(Uri uri, NetworkRoute route) async => getResponse;

  @override
  Future<void> download(Uri uri, File destination, NetworkRoute route) async {
    await destination.writeAsBytes(downloadBytes, flush: true);
  }
}
