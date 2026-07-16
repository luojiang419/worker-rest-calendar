import 'package:worker_rest_calendar/features/updater/domain/semantic_version.dart';
import 'package:worker_rest_calendar/features/updater/domain/update_config.dart';

enum UpdatePolicy { automatic, manual, disabled }

enum UpdateNetworkMode { automaticProxy, manualProxy, direct }

final class UpdateSettings {
  const UpdateSettings({
    this.policy = UpdatePolicy.automatic,
    this.networkMode = UpdateNetworkMode.automaticProxy,
    this.manualProxyUrl = 'http://127.0.0.1:7890',
    this.pending,
    this.deferredVersion,
  });

  final UpdatePolicy policy;
  final UpdateNetworkMode networkMode;
  final String manualProxyUrl;
  final PendingUpdate? pending;
  final SemanticVersion? deferredVersion;

  bool get checksOnStartup => policy == UpdatePolicy.automatic;
  bool get allowsManualCheck => policy != UpdatePolicy.disabled;

  UpdateSettings copyWith({
    UpdatePolicy? policy,
    UpdateNetworkMode? networkMode,
    String? manualProxyUrl,
    PendingUpdate? pending,
    bool clearPending = false,
    SemanticVersion? deferredVersion,
    bool clearDeferredVersion = false,
  }) => UpdateSettings(
    policy: policy ?? this.policy,
    networkMode: networkMode ?? this.networkMode,
    manualProxyUrl: manualProxyUrl ?? this.manualProxyUrl,
    pending: clearPending ? null : pending ?? this.pending,
    deferredVersion: clearDeferredVersion
        ? null
        : deferredVersion ?? this.deferredVersion,
  );
}

final class PendingUpdate {
  const PendingUpdate({
    required this.version,
    required this.installerPath,
    required this.assetName,
    required this.size,
    required this.sha256,
  });

  factory PendingUpdate.fromJson(Map<String, Object?> json) => PendingUpdate(
    version: SemanticVersion.parse(json['version']! as String),
    installerPath: json['installerPath']! as String,
    assetName: json['assetName']! as String,
    size: json['size']! as int,
    sha256: json['sha256']! as String,
  );

  final SemanticVersion version;
  final String installerPath;
  final String assetName;
  final int size;
  final String sha256;

  Map<String, Object> toJson() => {
    'version': version.toString(),
    'installerPath': installerPath,
    'assetName': assetName,
    'size': size,
    'sha256': sha256,
  };
}

final class ReleaseAsset {
  const ReleaseAsset({
    required this.name,
    required this.downloadUri,
    required this.size,
    this.digest,
  });

  final String name;
  final Uri downloadUri;
  final int size;
  final String? digest;
}

final class UpdateRelease {
  const UpdateRelease({
    required this.version,
    required this.assets,
    required this.htmlUri,
  });

  final SemanticVersion version;
  final List<ReleaseAsset> assets;
  final Uri htmlUri;

  UpdateReleaseAssets selectAssets(UpdateConfig config) {
    final installerName = config.installerAssetName(version);
    final checksumName = config.checksumAssetName(version);
    final installers = assets.where((asset) => asset.name == installerName);
    final checksums = assets.where((asset) => asset.name == checksumName);
    if (installers.length != 1) {
      throw UpdateContractException('安装包资产必须唯一：$installerName');
    }
    if (checksums.length != 1) {
      throw UpdateContractException('校验资产必须唯一：$checksumName');
    }
    final installer = installers.single;
    final checksum = checksums.single;
    if (installer.size <= 0 || checksum.size <= 0) {
      throw const UpdateContractException('Release 资产大小必须大于 0');
    }
    if (!installer.downloadUri.hasScheme || !checksum.downloadUri.hasScheme) {
      throw const UpdateContractException('Release 资产下载地址无效');
    }
    return UpdateReleaseAssets(installer: installer, checksum: checksum);
  }
}

final class UpdateReleaseAssets {
  const UpdateReleaseAssets({required this.installer, required this.checksum});

  final ReleaseAsset installer;
  final ReleaseAsset checksum;
}

sealed class UpdateCheckResult {
  const UpdateCheckResult();
}

final class NoUpdateAvailable extends UpdateCheckResult {
  const NoUpdateAvailable(this.currentVersion);

  final SemanticVersion currentVersion;
}

final class UpdateAvailable extends UpdateCheckResult {
  const UpdateAvailable({required this.release, required this.assets});

  final UpdateRelease release;
  final UpdateReleaseAssets assets;
}

final class UpdateContractException implements Exception {
  const UpdateContractException(this.message);

  final String message;

  @override
  String toString() => 'UpdateContractException: $message';
}
