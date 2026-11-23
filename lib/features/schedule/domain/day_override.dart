import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';

enum DayOverrideSource { holiday, manual }

final class DayOverride {
  DayOverride({required this.kind, this.overtimeMinutes = 0, this.note}) {
    if (overtimeMinutes < 0) {
      throw ArgumentError.value(overtimeMinutes, 'overtimeMinutes', '不能小于 0');
    }
  }

  final DayKind kind;
  final int overtimeMinutes;
  final String? note;
}
