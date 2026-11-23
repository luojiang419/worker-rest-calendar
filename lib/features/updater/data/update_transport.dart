import 'dart:io';

import 'package:worker_rest_calendar/features/updater/domain/update_models.dart';

final class NetworkRoute {
  const NetworkRoute({required this.mode, this.proxyUri});

  final UpdateNetworkMode mode;
  final Uri? proxyUri;
}

abstract interface class UpdateTransport {
  Future<List<int>> get(Uri uri, NetworkRoute route);

  Future<void> download(Uri uri, File destination, NetworkRoute route);
}

final class CurlUpdateTransport implements UpdateTransport {
  const CurlUpdateTransport();

  @override
  Future<List<int>> get(Uri uri, NetworkRoute route) async {
    final result = await Process.run('curl.exe', [
      ..._commonArguments(route),
      uri.toString(),
    ], stdoutEncoding: null);
    _checkResult(result, uri);
    return List<int>.from(result.stdout as List<int>);
  }

  @override
  Future<void> download(Uri uri, File destination, NetworkRoute route) async {
    final result = await Process.run('curl.exe', [
      ..._commonArguments(route),
      '--output',
      destination.path,
      uri.toString(),
    ]);
    _checkResult(result, uri);
  }

  List<String> _commonArguments(NetworkRoute route) => [
    '--fail-with-body',
    '--location',
    '--retry',
    '2',
    '--connect-timeout',
    '10',
    '--max-time',
    '300',
    '--header',
    'Accept: application/vnd.github+json',
    '--header',
    'X-GitHub-Api-Version: 2022-11-28',
    '--user-agent',
    'worker-rest-calendar-updater',
    if (route.mode == UpdateNetworkMode.direct) ...['--noproxy', '*'],
    if (route.proxyUri != null) ...['--proxy', route.proxyUri.toString()],
  ];

  void _checkResult(ProcessResult result, Uri uri) {
    if (result.exitCode == 0) return;
    final details = result.stderr.toString().trim();
    throw UpdateTransportException(
      '请求失败（curl ${result.exitCode}）：$uri${details.isEmpty ? '' : '，$details'}',
    );
  }
}

final class UpdateTransportException implements Exception {
  const UpdateTransportException(this.message);

  final String message;

  @override
  String toString() => 'UpdateTransportException: $message';
}
