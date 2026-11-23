import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/core/date/chinese_lunar_date.dart';

void main() {
  test('公农历对照：跨年、月初、除夕和公历闰日', () {
    // 香港天文台公历与农历日期对照表。
    final cases = {
      '2027-01-01': ['廿四', '冬月廿四'],
      '2027-01-08': ['腊月', '腊月初一'],
      '2027-01-11': ['初四', '腊月初四'],
      '2027-02-05': ['廿九', '腊月廿九'],
      '2027-02-06': ['正月', '正月初一'],
      '2024-02-09': ['三十', '腊月三十'],
      '2024-02-10': ['正月', '正月初一'],
      '2024-02-29': ['二十', '正月二十'],
      '2023-03-22': ['闰二月', '闰二月初一'],
    };
    for (final entry in cases.entries) {
      final lunar = ChineseLunarDate.forDate(CalendarDate.parse(entry.key))!;
      expect(lunar.shortLabel, entry.value[0], reason: entry.key);
      expect(lunar.fullLabel, entry.value[1], reason: entry.key);
    }
  });

  test('越界年份不影响公历浏览，缓存重复读取一致', () {
    expect(ChineseLunarDate.forDate(CalendarDate(1900, 12, 31)), isNull);
    expect(ChineseLunarDate.forDate(CalendarDate(2101, 1, 1)), isNull);
    final date = CalendarDate(2027, 2, 6);
    expect(
      ChineseLunarDate.forDate(date),
      same(ChineseLunarDate.forDate(date)),
    );
    for (var index = 0; index < 520; index++) {
      ChineseLunarDate.forDate(date.addDays(index));
    }
    expect(ChineseLunarDate.forDate(date)?.fullLabel, '正月初一');
  });
}
