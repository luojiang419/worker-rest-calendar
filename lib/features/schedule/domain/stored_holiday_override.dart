import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';

final class StoredHolidayOverride {
  StoredHolidayOverride({
    required this.date,
    required this.kind,
    required this.title,
    required this.region,
    required this.dataVersion,
    required this.updatedAt,
  }) {
    if (kind != DayKind.adjustedWork && kind != DayKind.adjustedRest) {
      throw ArgumentError.value(kind, 'kind', '节假日只能是调休上班或调休休息');
    }
  }

  final CalendarDate date;
  final DayKind kind;
  final String title;
  final String region;
  final String dataVersion;
  final DateTime updatedAt;
}
