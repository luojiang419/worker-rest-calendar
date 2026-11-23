import 'package:worker_rest_calendar/features/updater/domain/semantic_version.dart';

final class UpdateConfig {
  const UpdateConfig({
    required this.repositoryOwner,
    required this.repositoryName,
    required this.currentVersion,
    this.productId = 'worker-rest-calendar',
  });

  final String repositoryOwner;
  final String repositoryName;
  final SemanticVersion currentVersion;
  final String productId;

  Uri get latestReleaseUri => Uri.https(
    'api.github.com',
    '/repos/$repositoryOwner/$repositoryName/releases/latest',
  );

  String installerAssetName(SemanticVersion version) =>
      '$productId-Setup-Windows-x64-${version.tag}.exe';

  String checksumAssetName(SemanticVersion version) =>
      '${installerAssetName(version)}.sha256';
}
