import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:worker_rest_calendar/features/updater/data/update_transport.dart';
import 'package:worker_rest_calendar/features/updater/domain/semantic_version.dart';
import 'package:worker_rest_calendar/features/updater/domain/update_config.dart';
import 'package:worker_rest_calendar/features/updater/domain/update_models.dart';

final class UpdateService {
  const UpdateService({
    required UpdateConfig config,
    required UpdateTransport transport,
  }) : _config = config,
       _transport = transport;

  final UpdateConfig _config;
  final UpdateTransport _transport;

  Future<UpdateCheckResult> check(NetworkRoute route) async {
    final bytes = await _transport.get(_config.latestReleaseUri, route);
    final release = parseRelease(utf8.decode(bytes));
    if (release.version.compareTo(_config.currentVersion) <= 0) {
      return NoUpdateAvailable(_config.currentVersion);
    }
    return UpdateAvailable(
      release: release,
      assets: release.selectAssets(_config),
    );
  }

  UpdateRelease parseRelease(String body) {
    final json = jsonDecode(body) as Map<String, Object?>;
    if (json['draft'] == true || json['prerelease'] == true) {
      throw const UpdateContractException('Latest Release 不能是草稿或预发布');
    }
    final assetsJson = json['assets'];
    if (assetsJson is! List<Object?>) {
      throw const UpdateContractException('Release assets 字段无效');
    }
    return UpdateRelease(
      version: SemanticVersion.parse(json['tag_name']! as String),
      htmlUri: Uri.parse(json['html_url']! as String),
      assets: assetsJson
          .map((entry) {
            final asset = entry! as Map<String, Object?>;
            final digest = asset['digest'];
            return ReleaseAsset(
              name: asset['name']! as String,
              downloadUri: Uri.parse(asset['browser_download_url']! as String),
              size: asset['size']! as int,
              digest: digest is String ? digest : null,
            );
          })
          .toList(growable: false),
    );
  }

  Future<PendingUpdate> download(
    UpdateAvailable available,
    Directory cacheDirectory,
    NetworkRoute route,
  ) async {
    await cacheDirectory.create(recursive: true);
    final checksumBytes = await _transport.get(
      available.assets.checksum.downloadUri,
      route,
    );
    final expectedSha = _parseChecksum(
      utf8.decode(checksumBytes),
      available.assets.installer.name,
    );
    final target = File(
      '${cacheDirectory.path}${Platform.pathSeparator}${available.assets.installer.name}',
    );
    if (await _isValid(target, available.assets.installer.size, expectedSha)) {
      return _pending(available, target, expectedSha);
    }
    final partial = File('${target.path}.part');
    if (await partial.exists()) await partial.delete();
    await _transport.download(
      available.assets.installer.downloadUri,
      partial,
      route,
    );
    if (!await _isValid(
      partial,
      available.assets.installer.size,
      expectedSha,
    )) {
      if (await partial.exists()) await partial.delete();
      throw const UpdateContractException('安装包大小或 SHA-256 校验失败');
    }
    if (await target.exists()) {
      await target.delete();
    }
    await partial.rename(target.path);
    return _pending(available, target, expectedSha);
  }

  Future<bool> validatePending(PendingUpdate pending) async {
    if (pending.version.compareTo(_config.currentVersion) <= 0 ||
        pending.assetName != _config.installerAssetName(pending.version)) {
      return false;
    }
    return _isValid(File(pending.installerPath), pending.size, pending.sha256);
  }

  PendingUpdate _pending(
    UpdateAvailable available,
    File target,
    String expectedSha,
  ) => PendingUpdate(
    version: available.release.version,
    installerPath: target.path,
    assetName: available.assets.installer.name,
    size: available.assets.installer.size,
    sha256: expectedSha,
  );

  String _parseChecksum(String value, String expectedName) {
    final match = RegExp(
      r'^([a-fA-F0-9]{64})\s+\*?(.+?)\s*$',
    ).firstMatch(value.trim());
    if (match == null || match.group(2) != expectedName) {
      throw const UpdateContractException('SHA-256 校验文件格式或文件名不匹配');
    }
    return match.group(1)!.toLowerCase();
  }

  Future<bool> _isValid(File file, int expectedSize, String expectedSha) async {
    if (!await file.exists() || await file.length() != expectedSize) {
      return false;
    }
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString().toLowerCase() == expectedSha.toLowerCase();
  }
}
