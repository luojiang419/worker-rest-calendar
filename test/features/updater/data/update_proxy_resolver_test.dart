import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/features/updater/data/update_proxy_resolver.dart';
import 'package:worker_rest_calendar/features/updater/domain/update_models.dart';

void main() {
  test('自动代理优先读取环境变量', () async {
    final resolver = UpdateProxyResolver(
      environment: {'HTTPS_PROXY': 'http://127.0.0.1:7890'},
      probe: (_, _) async => false,
    );
    final route = await resolver.resolve(const UpdateSettings());
    expect(route.proxyUri, Uri.parse('http://127.0.0.1:7890'));
  });

  test('手动代理接受 HTTP HTTPS 与 SOCKS', () {
    for (final value in [
      'http://127.0.0.1:7890',
      'https://proxy.example:443',
      'socks4://127.0.0.1:1080',
      'socks5://127.0.0.1:1080',
    ]) {
      expect(UpdateProxyResolver.validateProxyUri(value), Uri.parse(value));
    }
  });

  test('手动代理拒绝无端口、不支持协议和空主机', () {
    for (final value in [
      'http://127.0.0.1',
      'ftp://127.0.0.1:21',
      'http://:7890',
    ]) {
      expect(
        () => UpdateProxyResolver.validateProxyUri(value),
        throwsFormatException,
      );
    }
  });

  test('直连明确不附带代理', () async {
    final resolver = UpdateProxyResolver(
      environment: {'HTTPS_PROXY': 'http://127.0.0.1:7890'},
    );
    final route = await resolver.resolve(
      const UpdateSettings(networkMode: UpdateNetworkMode.direct),
    );
    expect(route.mode, UpdateNetworkMode.direct);
    expect(route.proxyUri, isNull);
  });
}
