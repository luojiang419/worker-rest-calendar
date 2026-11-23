import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/desktop_widget/data/method_channel_desktop_activation_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('test/desktop_activation');

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('消费原生启动期队列时保留空参数激活并解析日期', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'consumePendingActivations');
          return <Object?>[
            <String>[],
            <String>['--payload=restcalendar://date/2026-07-21'],
          ];
        });
    final service = MethodChannelDesktopActivationService(
      channel: channel,
      isSupported: true,
    );

    final activations = await service.initialize();

    expect(activations, hasLength(2));
    expect(activations.first.arguments, isEmpty);
    expect(activations.last.selectedDate, CalendarDate(2026, 7, 21));
    await service.dispose();
  });
}
