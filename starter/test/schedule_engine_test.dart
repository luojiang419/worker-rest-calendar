import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_engine.dart';

void main() {
  group('AlternatingBigSmallWeekRule', () {
    final rule = AlternatingBigSmallWeekRule(
      anchorMonday: DateTime(2026, 7, 6),
      anchorWeekType: WeekType.big,
    );

    test('big week has Saturday and Sunday off', () {
      expect(rule.plannedKind(DateTime(2026, 7, 11)), DayKind.rest);
      expect(rule.plannedKind(DateTime(2026, 7, 12)), DayKind.rest);
    });

    test('small week has Saturday work and Sunday off', () {
      expect(rule.weekType(DateTime(2026, 7, 13)), WeekType.small);
      expect(rule.plannedKind(DateTime(2026, 7, 18)), DayKind.work);
      expect(rule.plannedKind(DateTime(2026, 7, 19)), DayKind.rest);
    });

    test('week before anchor alternates correctly', () {
      expect(rule.weekType(DateTime(2026, 7, 1)), WeekType.small);
      expect(rule.plannedKind(DateTime(2026, 7, 4)), DayKind.work);
    });
  });

  test('manual override wins over holiday override', () {
    final date = DateTime(2026, 7, 11);
    final resolved = resolveDay(
      date: date,
      rule: const WeekendRule(saturdayIsRest: true),
      holidayOverrides: {
        dateKey(date): const DayOverride(kind: DayKind.adjustedWork),
      },
      manualOverrides: {
        dateKey(date): const DayOverride(kind: DayKind.adjustedRest),
      },
    );
    expect(resolved.plannedKind, DayKind.rest);
    expect(resolved.effectiveKind, DayKind.adjustedRest);
  });
}
