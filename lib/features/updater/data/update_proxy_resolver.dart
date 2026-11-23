import 'dart:io';

import 'package:worker_rest_calendar/features/updater/data/update_transport.dart';
import 'package:worker_rest_calendar/features/updater/domain/update_models.dart';

final class UpdateProxyResolver {
  UpdateProxyResolver({
    Map<String, String>? environment,
    Future<bool> Function(String host, int port)? probe,
  }) : _environment = environment ?? Platform.environment,
       _probe = probe ?? _probeSocket;

  final Map<String, String> _environment;
  final Future<bool> Function(String host, int port) _probe;

  Future<NetworkRoute> resolve(UpdateSettings settings) async {
    switch (settings.networkMode) {
      case UpdateNetworkMode.direct:
        return const NetworkRoute(mode: UpdateNetworkMode.direct);
      case UpdateNetworkMode.manualProxy:
        return NetworkRoute(
          mode: UpdateNetworkMode.manualProxy,
          proxyUri: validateProxyUri(settings.manualProxyUrl),
        );
      case UpdateNetworkMode.automaticProxy:
        for (final key in const [
          'HTTPS_PROXY',
          'https_proxy',
          'HTTP_PROXY',
          'http_proxy',
          'ALL_PROXY',
          'all_proxy',
        ]) {
          final value = _environment[key];
          if (value != null && value.trim().isNotEmpty) {
            return NetworkRoute(
              mode: UpdateNetworkMode.automaticProxy,
              proxyUri: validateProxyUri(value),
            );
          }
        }
        final hosts = <String>{'127.0.0.1', 'localhost'};
        for (final interface in await NetworkInterface.list(
          type: InternetAddressType.IPv4,
          includeLoopback: false,
        )) {
          hosts.addAll(interface.addresses.map((address) => address.address));
        }
        for (final host in hosts) {
          for (final port in const [7890, 1080, 8080]) {
            if (await _probe(host, port)) {
              return NetworkRoute(
                mode: UpdateNetworkMode.automaticProxy,
                proxyUri: Uri.parse('http://$host:$port'),
              );
            }
          }
        }
        return const NetworkRoute(mode: UpdateNetworkMode.automaticProxy);
    }
  }

  static Uri validateProxyUri(String value) {
    final normalized = value.trim();
    final explicitPort = RegExp(
      r'^[a-zA-Z][a-zA-Z0-9+.-]*://(?:[^@/]+@)?(?:\[[^\]]+\]|[^/:]+):(\d+)(?:/|$)',
    ).firstMatch(normalized);
    final uri = Uri.tryParse(normalized);
    const supportedSchemes = {'http', 'https', 'socks4', 'socks5', 'socks5h'};
    final port = int.tryParse(explicitPort?.group(1) ?? '');
    if (uri == null ||
        !supportedSchemes.contains(uri.scheme.toLowerCase()) ||
        uri.host.isEmpty ||
        port == null ||
        port < 1 ||
        port > 65535) {
      throw const FormatException('代理地址必须包含支持的协议、主机和端口');
    }
    return uri;
  }

  static Future<bool> _probeSocket(String host, int port) async {
    try {
      final socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(milliseconds: 180),
      );
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }
}
