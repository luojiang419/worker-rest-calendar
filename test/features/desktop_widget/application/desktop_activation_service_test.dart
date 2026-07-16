import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/desktop_widget/application/desktop_activation_service.dart';

void main() {
  test('从完整命令行参数中提取日期深链并保留原始参数', () {
    final intent = DesktopActivationIntent(
      arguments: const [
        '--notification-launch-details',
        '--payload=restcalendar://date/2026-07-18',
      ],
    );

    expect(intent.selectedDate, CalendarDate(2026, 7, 18));
    expect(intent.arguments, hasLength(2));
  });

  test('空参数重复启动仍形成激活意图，损坏日期不会导致崩溃', () {
    final empty = DesktopActivationIntent(arguments: const []);
    final invalid = DesktopActivationIntent(
      arguments: const ['restcalendar://date/2026-02-30'],
    );

    expect(empty.selectedDate, isNull);
    expect(invalid.selectedDate, isNull);
  });
}
