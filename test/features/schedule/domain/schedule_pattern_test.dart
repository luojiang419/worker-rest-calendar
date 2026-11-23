import 'package:test/test.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule.dart';

void main() {
  group('固定周制', () {
    test('双休为周一至周五工作、周六周日休息', () {
      const pattern = FixedWeeklyPattern.doubleRest();
      final monday = CalendarDate(2026, 7, 6);

      expect(
        List.generate(7, (index) => pattern.plannedKind(monday.addDays(index))),
        const [
          DayKind.work,
          DayKind.work,
          DayKind.work,
          DayKind.work,
          DayKind.work,
          DayKind.rest,
          DayKind.rest,
        ],
      );
    });

    test('单休仅周日休息', () {
      const pattern = FixedWeeklyPattern.singleRest();
      final monday = CalendarDate(2026, 7, 6);

      expect(
        List.generate(7, (index) => pattern.plannedKind(monday.addDays(index))),
        const [
          DayKind.work,
          DayKind.work,
          DayKind.work,
          DayKind.work,
          DayKind.work,
          DayKind.work,
          DayKind.rest,
        ],
      );
    });
  });

  group('大小周', () {
    final pattern = AlternatingBigSmallWeekPattern(
      anchorDate: CalendarDate(2026, 7, 8),
      anchorWeekType: WeekType.big,
    );

    test('锚点自动归一化到周一', () {
      expect(pattern.anchorMonday, CalendarDate(2026, 7, 6));
    });

    test('大周周六周日休息，小周周六工作周日休息', () {
      expect(pattern.weekTypeFor(CalendarDate(2026, 7, 11)), WeekType.big);
      expect(pattern.plannedKind(CalendarDate(2026, 7, 11)), DayKind.rest);
      expect(pattern.plannedKind(CalendarDate(2026, 7, 12)), DayKind.rest);

      expect(pattern.weekTypeFor(CalendarDate(2026, 7, 18)), WeekType.small);
      expect(pattern.plannedKind(CalendarDate(2026, 7, 18)), DayKind.work);
      expect(pattern.plannedKind(CalendarDate(2026, 7, 19)), DayKind.rest);
    });

    test('锚点前一周和前两周正确交替', () {
      expect(pattern.weekTypeFor(CalendarDate(2026, 7, 1)), WeekType.small);
      expect(pattern.plannedKind(CalendarDate(2026, 7, 4)), DayKind.work);
      expect(pattern.weekTypeFor(CalendarDate(2026, 6, 22)), WeekType.big);
      expect(pattern.plannedKind(CalendarDate(2026, 6, 27)), DayKind.rest);
    });

    test('跨年仍按周交替', () {
      final crossYear = AlternatingBigSmallWeekPattern(
        anchorDate: CalendarDate(2026, 12, 28),
        anchorWeekType: WeekType.big,
      );

      expect(crossYear.plannedKind(CalendarDate(2027, 1, 2)), DayKind.rest);
      expect(crossYear.weekTypeFor(CalendarDate(2027, 1, 9)), WeekType.small);
      expect(crossYear.plannedKind(CalendarDate(2027, 1, 9)), DayKind.work);
    });

    test('小周作为锚点时，锚点周六工作、下一周六休息', () {
      final smallAnchor = AlternatingBigSmallWeekPattern(
        anchorDate: CalendarDate(2026, 7, 6),
        anchorWeekType: WeekType.small,
      );

      expect(smallAnchor.plannedKind(CalendarDate(2026, 7, 11)), DayKind.work);
      expect(smallAnchor.plannedKind(CalendarDate(2026, 7, 18)), DayKind.rest);
      expect(smallAnchor.plannedKind(CalendarDate(2026, 7, 19)), DayKind.rest);
    });
  });

  group('循环班制', () {
    test('做六休一从锚点起连续工作六天后休息', () {
      final pattern = CycleSchedulePattern.sixOnOneOff(
        anchorDate: CalendarDate(2026, 7, 6),
      );

      expect(
        List.generate(
          7,
          (index) =>
              pattern.plannedKind(CalendarDate(2026, 7, 6).addDays(index)),
        ),
        const [
          DayKind.work,
          DayKind.work,
          DayKind.work,
          DayKind.work,
          DayKind.work,
          DayKind.work,
          DayKind.rest,
        ],
      );
    });

    test('做二休二在闰日和跨月时保持周期', () {
      final pattern = CycleSchedulePattern.twoOnTwoOff(
        anchorDate: CalendarDate(2024, 2, 28),
      );

      expect(pattern.plannedKind(CalendarDate(2024, 2, 28)), DayKind.work);
      expect(pattern.plannedKind(CalendarDate(2024, 2, 29)), DayKind.work);
      expect(pattern.plannedKind(CalendarDate(2024, 3, 1)), DayKind.rest);
      expect(pattern.plannedKind(CalendarDate(2024, 3, 2)), DayKind.rest);
    });

    test('自定义周期支持锚点前日期的正规范化取模', () {
      final pattern = CycleSchedulePattern.custom(
        anchorDate: CalendarDate(2026, 7, 10),
        cycleDays: const [DayKind.work, DayKind.rest, DayKind.rest],
      );

      expect(pattern.plannedKind(CalendarDate(2026, 7, 9)), DayKind.rest);
      expect(pattern.plannedKind(CalendarDate(2026, 7, 8)), DayKind.rest);
      expect(pattern.plannedKind(CalendarDate(2026, 7, 7)), DayKind.work);
    });

    test('拒绝空周期、无休息日、超长周期和非基础状态', () {
      final anchor = CalendarDate(2026, 7, 6);

      expect(
        () => CycleSchedulePattern.custom(
          anchorDate: anchor,
          cycleDays: const [],
        ),
        throwsA(isA<InvalidPattern>()),
      );
      expect(
        () => CycleSchedulePattern.custom(
          anchorDate: anchor,
          cycleDays: const [DayKind.work],
        ),
        throwsA(isA<InvalidPattern>()),
      );
      expect(
        () => CycleSchedulePattern.custom(
          anchorDate: anchor,
          cycleDays: List.filled(57, DayKind.rest),
        ),
        throwsA(isA<InvalidPattern>()),
      );
      expect(
        () => CycleSchedulePattern.custom(
          anchorDate: anchor,
          cycleDays: const [DayKind.work, DayKind.leave, DayKind.rest],
        ),
        throwsA(isA<InvalidPattern>()),
      );
    });
  });
}
