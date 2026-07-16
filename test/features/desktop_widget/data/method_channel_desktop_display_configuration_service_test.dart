import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/features/desktop_widget/data/method_channel_desktop_display_configuration_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channelName = 'test/desktop_display_configuration';
  const channel = MethodChannel(channelName);

  test('原生显示配置变化会通知已注册处理器且释放后停止通知', () async {
    var notificationCount = 0;
    final service = MethodChannelDesktopDisplayConfigurationService(
      channel: channel,
      isSupported: true,
    );
    await service.initialize(() async => notificationCount += 1);

    await _sendNativeMethodCall(
      channelName,
      const MethodCall('onDisplayConfigurationChanged'),
    );
    expect(notificationCount, 1);

    await service.dispose();
    await _sendNativeMethodCall(
      channelName,
      const MethodCall('onDisplayConfigurationChanged'),
    );
    expect(notificationCount, 1);
  });
}

Future<void> _sendNativeMethodCall(String channel, MethodCall call) async {
  final completer = Completer<void>();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage(
        channel,
        const StandardMethodCodec().encodeMethodCall(call),
        (_) => completer.complete(),
      );
  await completer.future;
}
