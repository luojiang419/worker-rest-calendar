import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/features/desktop_widget/data/method_channel_system_status_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('test/system_status');

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('将平台结果映射为系统状态', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'getSystemStatus');
          return {
            'cpuUsage': 37.5,
            'memoryUsage': 68,
            'batteryLevel': 82,
            'isCharging': true,
          };
        });
    final service = MethodChannelSystemStatusService(
      channel: channel,
      isSupported: true,
    );

    final snapshot = await service.read();

    expect(snapshot?.cpuUsage, 37.5);
    expect(snapshot?.memoryUsage, 68);
    expect(snapshot?.batteryLevel, 82);
    expect(snapshot?.isCharging, isTrue);
  });

  test('不支持的平台安全返回 null', () async {
    final service = MethodChannelSystemStatusService(
      channel: channel,
      isSupported: false,
    );

    expect(await service.read(), isNull);
  });
}
