import 'package:worker_rest_calendar/core/date/calendar_date.dart';

const _weekdayLabels = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
const _weekdayShortLabels = ['一', '二', '三', '四', '五', '六', '日'];

extension CalendarDateLabels on CalendarDate {
  String get weekdayLabel => _weekdayLabels[weekday - 1];

  String get weekdayShortLabel => _weekdayShortLabels[weekday - 1];

  String get monthDayLabel => '$month月$day日';

  String get fullDateLabel => '$year年$month月$day日 $weekdayLabel';
}
