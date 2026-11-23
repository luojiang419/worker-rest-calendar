import 'package:lunar/lunar.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';

/// 中国农历显示适配器；只使用年月日，避免时区和夏令时偏移。
final class ChineseLunarDate {
  const ChineseLunarDate._(this.monthLabel, this.dayLabel, this.isFirstDay);

  static final _cache = <CalendarDate, ChineseLunarDate>{};
  static const _cacheLimit = 512;

  /// 展示范围与常用公农历对照表一致，超出范围保留公历显示。
  static ChineseLunarDate? forDate(CalendarDate date) {
    if (date.year < 1901 || date.year > 2100) return null;
    return _cache[date] ?? _convert(date);
  }

  static ChineseLunarDate _convert(CalendarDate date) {
    final lunar = Solar.fromYmd(date.year, date.month, date.day).getLunar();
    final result = ChineseLunarDate._(
      '${lunar.getMonthInChinese()}月',
      lunar.getDayInChinese(),
      lunar.getDay() == 1,
    );
    if (_cache.length >= _cacheLimit) _cache.remove(_cache.keys.first);
    _cache[date] = result;
    return result;
  }

  final String monthLabel;
  final String dayLabel;
  final bool isFirstDay;

  String get shortLabel => isFirstDay ? monthLabel : dayLabel;
  String get fullLabel => '$monthLabel$dayLabel';
}
