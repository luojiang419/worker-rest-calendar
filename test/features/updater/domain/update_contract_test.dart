import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/features/updater/domain/semantic_version.dart';
import 'package:worker_rest_calendar/features/updater/domain/update_config.dart';
import 'package:worker_rest_calendar/features/updater/domain/update_models.dart';

void main() {
  const version = SemanticVersion(0, 1, 11);
  const config = UpdateConfig(
    repositoryOwner: 'owner',
    repositoryName: 'releases',
    currentVersion: SemanticVersion(0, 1, 10),
  );

  test('固定 Latest API 与 Windows x64 唯一资产名称', () {
    expect(
      config.latestReleaseUri.toString(),
      'https://api.github.com/repos/owner/releases/releases/latest',
    );
    expect(
      config.installerAssetName(version),
      'worker-rest-calendar-Setup-Windows-x64-v0.1.11.exe',
    );
    expect(
      config.checksumAssetName(version),
      'worker-rest-calendar-Setup-Windows-x64-v0.1.11.exe.sha256',
    );
  });

  test('资产顺序变化或存在其他 exe 时仍精确匹配', () {
    final expectedInstaller = _asset(
      config.installerAssetName(version),
      size: 12000000,
    );
    final expectedChecksum = _asset(config.checksumAssetName(version));
    final release = UpdateRelease(
      version: version,
      htmlUri: Uri.parse('https://github.com/owner/releases/releases/v0.1.11'),
      assets: [
        _asset('unrelated.exe'),
        expectedChecksum,
        _asset('android.apk'),
        expectedInstaller,
      ],
    );

    final selected = release.selectAssets(config);
    expect(selected.installer, same(expectedInstaller));
    expect(selected.checksum, same(expectedChecksum));
  });

  test('缺失、重复和零大小资产都失败关闭', () {
    final installer = _asset(config.installerAssetName(version));
    final checksum = _asset(config.checksumAssetName(version));

    expect(
      () => _release([installer]).selectAssets(config),
      throwsA(isA<UpdateContractException>()),
    );
    expect(
      () => _release([installer, installer, checksum]).selectAssets(config),
      throwsA(isA<UpdateContractException>()),
    );
    expect(
      () => _release([
        _asset(config.installerAssetName(version), size: 0),
        checksum,
      ]).selectAssets(config),
      throwsA(isA<UpdateContractException>()),
    );
  });
}

UpdateRelease _release(List<ReleaseAsset> assets) => UpdateRelease(
  version: const SemanticVersion(0, 1, 11),
  assets: assets,
  htmlUri: Uri.parse('https://github.com/owner/releases/releases/v0.1.11'),
);

ReleaseAsset _asset(String name, {int size = 64}) => ReleaseAsset(
  name: name,
  downloadUri: Uri.parse('https://github.com/downloads/$name'),
  size: size,
);
