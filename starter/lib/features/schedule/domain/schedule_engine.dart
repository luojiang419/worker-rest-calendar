import 'day_kind.dart';

typedef DateKey = String;

DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

DateTime mondayOf(DateTime value) {
  final d = dateOnly(value);
  return d.subtract(Duration(days: d.weekday - DateTime.monday));
}

int floorDiv(int value, int divisor) {
  if (divisor <= 0) throw ArgumentError.value(divisor, 'divisor');
  final mod = value % divisor;
  return (value - mod) ~/ divisor;
}

int positiveModulo(int value, int modulus) {
  if (modulus <= 0) throw ArgumentError.value(modulus, 'modulus');
  return value % modulus;
}

String dateKey(DateTime value) {
  final d = dateOnly(value);
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)}';
}

abstract class ScheduleRule {
  DayKind plannedKind(DateTime date);
  WeekType? weekType(DateTime date) => null;
}

final class WeekendRule extends ScheduleRule {
  const WeekendRule({required this.saturdayIsRest});
  final bool saturdayIsRest;

  @override
  DayKind plannedKind(DateTime date) {
    if (date.weekday == DateTime.sunday) return DayKind.rest;
    if (saturdayIsRest && date.weekday == DateTime.saturday) {
      return DayKind.rest;
    }
    return DayKind.work;
  }
}

final class AlternatingBigSmallWeekRule extends ScheduleRule {
  AlternatingBigSmallWeekRule({
    required DateTime anchorMonday,
    required this.anchorWeekType,
  }) : anchorMonday = mondayOf(anchorMonday);

  final DateTime anchorMonday;
  final WeekType anchorWeekType;

  @override
  WeekType weekType(DateTime date) {
    final days = mondayOf(date).difference(anchorMonday).inDays;
    final offset = floorDiv(days, 7);
    if (offset.isEven) return anchorWeekType;
    return anchorWeekType == WeekType.big ? WeekType.small : WeekType.big;
  }

  @override
  DayKind plannedKind(DateTime date) {
    final type = weekType(date);
    if (date.weekday == DateTime.sunday) return DayKind.rest;
    if (date.weekday == DateTime.saturday && type == WeekType.big) {
      return DayKind.rest;
    }
    return DayKind.work;
  }
}

final class CycleRule extends ScheduleRule {
  CycleRule({required DateTime anchorDate, required List<DayKind> cycle})
    : anchorDate = dateOnly(anchorDate),
      cycle = List.unmodifiable(cycle) {
    if (cycle.isEmpty || cycle.length > 56) {
      throw ArgumentError('cycle length must be 1..56');
    }
    if (cycle.every((kind) => !kind.isRest)) {
      throw ArgumentError('cycle must contain at least one rest day');
    }
  }

  final DateTime anchorDate;
  final List<DayKind> cycle;

  @override
  DayKind plannedKind(DateTime date) {
    final days = dateOnly(date).difference(anchorDate).inDays;
    return cycle[positiveModulo(days, cycle.length)];
  }
}

final class ResolvedDay {
  const ResolvedDay({
    required this.date,
    required this.plannedKind,
    required this.effectiveKind,
    required this.weekType,
    this.overtimeMinutes = 0,
    this.note,
  });

  final DateTime date;
  final DayKind plannedKind;
  final DayKind effectiveKind;
  final WeekType? weekType;
  final int overtimeMinutes;
  final String? note;
}

final class DayOverride {
  const DayOverride({required this.kind, this.overtimeMinutes = 0, this.note});
  final DayKind kind;
  final int overtimeMinutes;
  final String? note;
}

ResolvedDay resolveDay({
  required DateTime date,
  required ScheduleRule rule,
  Map<DateKey, DayOverride> holidayOverrides = const {},
  Map<DateKey, DayOverride> manualOverrides = const {},
}) {
  final normalized = dateOnly(date);
  final planned = rule.plannedKind(normalized);
  final override =
      manualOverrides[dateKey(normalized)] ??
      holidayOverrides[dateKey(normalized)];
  return ResolvedDay(
    date: normalized,
    plannedKind: planned,
    effectiveKind: override?.kind ?? planned,
    weekType: rule.weekType(normalized),
    overtimeMinutes: override?.overtimeMinutes ?? 0,
    note: override?.note,
  );
}

int daysToNextRest({
  required DateTime from,
  required ResolvedDay Function(DateTime) resolver,
  int maxScanDays = 366,
}) {
  for (var offset = 0; offset <= maxScanDays; offset++) {
    final date = dateOnly(from).add(Duration(days: offset));
    if (resolver(date).effectiveKind.isRest) return offset;
  }
  throw StateError('No rest day found in scan range');
}
