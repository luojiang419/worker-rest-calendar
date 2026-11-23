import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/features/desktop_widget/domain/countdown_target.dart';

void main() {
  test('按本地自然日计算倒数日且忽略时刻', () {
    final target = CountdownTarget(title: '生日', date: DateTime(2026, 8, 1));

    expect(target.daysFrom(DateTime(2026, 7, 30, 23, 59)), 2);
    expect(target.daysFrom(DateTime(2026, 8, 1, 12)), 0);
    expect(target.daysFrom(DateTime(2026, 8, 2)), -1);
  });

  test('无效日期不会生成目标', () {
    expect(
      CountdownTarget.tryParse(title: '目标', isoDate: 'not-a-date'),
      isNull,
    );
  });
}
