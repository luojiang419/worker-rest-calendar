import 'package:worker_rest_calendar/core/date/calendar_date.dart';

sealed class ScheduleDomainException implements Exception {
  const ScheduleDomainException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class InvalidPattern extends ScheduleDomainException {
  const InvalidPattern(super.message);
}

final class NoRestDayFound extends ScheduleDomainException {
  NoRestDayFound({required CalendarDate from, required int maxScanDays})
    : super('从 $from 起 $maxScanDays 天内没有找到休息日');
}

final class WorkStreakScanLimitExceeded extends ScheduleDomainException {
  WorkStreakScanLimitExceeded({
    required CalendarDate endingOn,
    required int maxScanDays,
  }) : super('截至 $endingOn 的连续工作天数超过扫描上限 $maxScanDays 天');
}
