import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/features/desktop_widget/domain/weather_snapshot.dart';

void main() {
  test('WMO 天气码映射为中文描述', () {
    expect(weatherCodeDescription(0), '晴朗');
    expect(weatherCodeDescription(63), '下雨');
    expect(weatherCodeDescription(95), '雷雨');
    expect(weatherCodeDescription(999), '天气变化');
  });
}
