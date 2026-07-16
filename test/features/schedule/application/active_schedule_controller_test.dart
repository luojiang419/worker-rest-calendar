import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/app/app_dependencies.dart';
import 'package:worker_rest_calendar/core/database/app_database.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/home/application/today_dashboard.dart';
import 'package:worker_rest_calendar/features/schedule/application/active_schedule_controller.dart';
import 'package:worker_rest_calendar/features/schedule/data/drift_schedule_repository.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/schedule/domain/stored_holiday_override.dart';

import '../../../helpers/test_models.dart';

void main() {
  late AppDatabase database;
  late DriftScheduleRepository repository;
  late ProviderContainer container;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftScheduleRepository(database);
    await repository.saveProfile(testProfile());
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        dayOverrideIdProvider.overrideWithValue(() => 'new-override'),
        utcNowProvider.overrideWithValue(() => DateTime.utc(2026, 7, 13, 8)),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  test('active profile、节假日与手动覆盖组装为同一个排班状态', () async {
    final saturday = CalendarDate(2026, 7, 11);
    await repository.saveHolidayOverrides([
      StoredHolidayOverride(
        date: saturday,
        kind: DayKind.adjustedWork,
        title: '节假日调班',
        region: 'CN',
        dataVersion: 'test',
        updatedAt: DateTime.utc(2026, 7, 1),
      ),
    ]);
    await repository.saveDayOverride(
      testOverride(date: saturday, kind: DayKind.adjustedRest),
    );

    final state = await container.read(activeScheduleControllerProvider.future);
    final day = state.day(saturday);

    expect(state.profile.id, 'profile-1');
    expect(day.plannedKind, DayKind.rest);
    expect(day.effectiveKind, DayKind.adjustedRest);
    expect(day.label, '调休休息');
    expect(day.shortLabel, '调休');
    expect(day.hasManualOverride, isTrue);
  });

  test('今日四卡数据和共享日期解析保持一致', () async {
    final state = await container.read(activeScheduleControllerProvider.future);
    final today = CalendarDate(2026, 7, 10);
    final dashboard = TodayDashboard.build(state, today);

    expect(dashboard.today.effectiveKind, state.day(today).effectiveKind);
    expect(dashboard.daysToNextRest, 1);
    expect(dashboard.nextRestDate, CalendarDate(2026, 7, 11));
    expect(dashboard.weekDays, hasLength(7));
    expect(
      dashboard.monthSummary.workDays +
          dashboard.monthSummary.restDays +
          dashboard.monthSummary.adjustedDays +
          dashboard.monthSummary.leaveDays,
      31,
    );
  });

  test('关闭节假日覆盖时不加载节假日数据', () async {
    await repository.saveProfile(
      testProfile().copyWith(holidayOverridesEnabled: false),
    );
    await repository.saveHolidayOverrides([
      StoredHolidayOverride(
        date: CalendarDate(2026, 7, 10),
        kind: DayKind.adjustedRest,
        title: '测试节日',
        region: 'CN',
        dataVersion: 'test',
        updatedAt: DateTime.utc(2026, 7, 1),
      ),
    ]);

    final state = await container.read(activeScheduleControllerProvider.future);

    expect(state.holidayOverrides, isEmpty);
    expect(state.day(CalendarDate(2026, 7, 10)).effectiveKind, DayKind.work);
  });

  test('保存、修改和删除覆盖后实时重载并发布刷新事件', () async {
    final saturday = CalendarDate(2026, 7, 11);
    await container.read(activeScheduleControllerProvider.future);
    final controller = container.read(
      activeScheduleControllerProvider.notifier,
    );

    await controller.saveManualOverride(
      date: saturday,
      kind: DayKind.adjustedWork,
      overtimeMinutes: 90,
      note: ' 临时值班 ',
    );

    var state = container.read(activeScheduleControllerProvider).requireValue;
    var event = container.read(scheduleRefreshEventProvider)!;
    expect(state.day(saturday).effectiveKind, DayKind.adjustedWork);
    expect(state.day(saturday).overtimeMinutes, 90);
    expect(state.day(saturday).note, '临时值班');
    expect(event.sequence, 1);
    expect(event.date, saturday);
    expect(event.type, ScheduleMutationType.saveOverride);

    final firstStored = state.manualOverrideFor(saturday)!;
    await controller.saveManualOverride(
      date: saturday,
      kind: DayKind.leave,
      overtimeMinutes: 0,
      note: ' ',
    );
    state = container.read(activeScheduleControllerProvider).requireValue;
    final edited = state.manualOverrideFor(saturday)!;
    expect(edited.id, firstStored.id);
    expect(edited.createdAt, firstStored.createdAt);
    expect(edited.note, isNull);
    expect(state.day(saturday).effectiveKind, DayKind.leave);
    expect(container.read(scheduleRefreshEventProvider)!.sequence, 2);

    expect(await controller.deleteManualOverride(saturday), isTrue);
    state = container.read(activeScheduleControllerProvider).requireValue;
    event = container.read(scheduleRefreshEventProvider)!;
    expect(state.manualOverrideFor(saturday), isNull);
    expect(state.day(saturday).effectiveKind, DayKind.rest);
    expect(event.sequence, 3);
    expect(event.type, ScheduleMutationType.deleteOverride);
    expect(await controller.deleteManualOverride(saturday), isFalse);
  });
}
