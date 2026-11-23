import 'package:test/test.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule.dart';

void main() {
  group('覆盖优先级', () {
    final date = CalendarDate(2026, 7, 11);
    const pattern = FixedWeeklyPattern.doubleRest();
    final holiday = DayOverride(kind: DayKind.adjustedWork, note: '节假日调班');
    final manual = DayOverride(kind: DayKind.adjustedRest, note: '用户补休');

    test('手动覆盖高于节假日覆盖，节假日覆盖高于基础班制', () {
      final withManual = ScheduleEngine(
        pattern: pattern,
        holidayOverrides: {date: holiday},
        manualOverrides: {date: manual},
      ).resolve(date);
      expect(withManual.plannedKind, DayKind.rest);
      expect(withManual.effectiveKind, DayKind.adjustedRest);
      expect(withManual.appliedOverrideSource, DayOverrideSource.manual);
      expect(withManual.note, '用户补休');

      final withoutManual = ScheduleEngine(
        pattern: pattern,
        holidayOverrides: {date: holiday},
      ).resolve(date);
      expect(withoutManual.effectiveKind, DayKind.adjustedWork);
      expect(withoutManual.appliedOverrideSource, DayOverrideSource.holiday);

      final withoutOverrides = ScheduleEngine(pattern: pattern).resolve(date);
      expect(withoutOverrides.effectiveKind, DayKind.rest);
      expect(withoutOverrides.appliedOverrideSource, isNull);
    });

    test('引擎复制覆盖映射，外部修改不会静默改变计算结果', () {
      final mutableOverrides = <CalendarDate, DayOverride>{date: manual};
      final engine = ScheduleEngine(
        pattern: pattern,
        manualOverrides: mutableOverrides,
      );

      mutableOverrides.clear();

      expect(engine.resolve(date).effectiveKind, DayKind.adjustedRest);
      expect(() => engine.manualOverrides.clear(), throwsUnsupportedError);
    });

    test('加班分钟是附加数据，不替换计划状态或额外增加天数', () {
      final monday = CalendarDate(2026, 7, 6);
      final tuesday = monday.addDays(1);
      final engine = ScheduleEngine(
        pattern: pattern,
        manualOverrides: {
          tuesday: DayOverride(kind: DayKind.work, overtimeMinutes: 120),
        },
      );

      final resolved = engine.resolve(tuesday);
      expect(resolved.plannedKind, DayKind.work);
      expect(resolved.effectiveKind, DayKind.work);
      expect(resolved.overtimeMinutes, 120);
      expect(engine.consecutiveWorkDaysEndingOn(tuesday), 2);
      expect(
        () => DayOverride(kind: DayKind.work, overtimeMinutes: -1),
        throwsArgumentError,
      );
    });

    test('节假日覆盖拒绝普通工作、休息或请假状态', () {
      expect(
        () => ScheduleEngine(
          pattern: pattern,
          holidayOverrides: {date: DayOverride(kind: DayKind.leave)},
        ),
        throwsArgumentError,
      );
    });
  });

  group('下一休息日', () {
    test('今天已休息返回 0，从工作日扫描到下一休息日', () {
      final engine = ScheduleEngine(
        pattern: const FixedWeeklyPattern.doubleRest(),
      );

      expect(engine.daysToNextRest(CalendarDate(2026, 7, 11)), 0);
      expect(engine.daysToNextRest(CalendarDate(2026, 7, 10)), 1);
    });

    test('调休休息属于休息，今天命中时返回 0', () {
      final monday = CalendarDate(2026, 7, 6);
      final engine = ScheduleEngine(
        pattern: const FixedWeeklyPattern.doubleRest(),
        manualOverrides: {monday: DayOverride(kind: DayKind.adjustedRest)},
      );

      expect(engine.daysToNextRest(monday), 0);
    });

    test('依据最终状态扫描，调休上班会推迟结果', () {
      final saturday = CalendarDate(2026, 7, 11);
      final sunday = CalendarDate(2026, 7, 12);
      final engine = ScheduleEngine(
        pattern: const FixedWeeklyPattern.doubleRest(),
        manualOverrides: {
          saturday: DayOverride(kind: DayKind.adjustedWork),
          sunday: DayOverride(kind: DayKind.adjustedWork),
        },
      );

      expect(engine.daysToNextRest(CalendarDate(2026, 7, 10)), 8);
    });

    test('扫描上限内找不到休息日时返回可诊断错误', () {
      final engine = ScheduleEngine(
        pattern: const FixedWeeklyPattern.singleRest(),
      );

      expect(
        () => engine.daysToNextRest(CalendarDate(2026, 7, 6), maxScanDays: 5),
        throwsA(isA<NoRestDayFound>()),
      );
      expect(
        () => engine.daysToNextRest(CalendarDate(2026, 7, 6), maxScanDays: -1),
        throwsArgumentError,
      );
    });
  });

  group('连续工作天数', () {
    final monday = CalendarDate(2026, 7, 6);
    final wednesday = monday.addDays(2);
    final saturday = monday.addDays(5);
    final engine = ScheduleEngine(
      pattern: const FixedWeeklyPattern.doubleRest(),
      manualOverrides: {
        wednesday: DayOverride(kind: DayKind.leave),
        saturday: DayOverride(kind: DayKind.adjustedWork),
      },
    );

    test('计划口径忽略覆盖，实际口径由请假中断并计入调休上班', () {
      expect(
        engine.consecutiveWorkDaysEndingOn(
          saturday,
          basis: WorkdayBasis.planned,
        ),
        0,
      );
      expect(
        engine.consecutiveWorkDaysEndingOn(
          saturday,
          basis: WorkdayBasis.effective,
        ),
        3,
      );
    });

    test('区间最长连续工作分别按计划与实际口径统计', () {
      final sunday = monday.addDays(6);

      expect(
        engine.longestConsecutiveWorkDays(
          start: monday,
          end: sunday,
          basis: WorkdayBasis.planned,
        ),
        5,
      );
      expect(
        engine.longestConsecutiveWorkDays(
          start: monday,
          end: sunday,
          basis: WorkdayBasis.effective,
        ),
        3,
      );
    });

    test('扫描上限不足时不返回截断的错误天数', () {
      expect(
        () => engine.consecutiveWorkDaysEndingOn(
          monday.addDays(4),
          basis: WorkdayBasis.planned,
          maxScanDays: 3,
        ),
        throwsA(isA<WorkStreakScanLimitExceeded>()),
      );
      expect(
        () => engine.longestConsecutiveWorkDays(
          start: monday.addDays(1),
          end: monday,
        ),
        throwsArgumentError,
      );
    });
  });
}
