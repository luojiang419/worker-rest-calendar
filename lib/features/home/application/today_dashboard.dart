import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/schedule/application/active_schedule_controller.dart';
import 'package:worker_rest_calendar/features/schedule/application/day_presentation.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';

final class TodayDashboard {
  const TodayDashboard({
    required this.today,
    required this.daysToNextRest,
    required this.remainingWorkDaysBeforeNextRest,
    required this.nextRestDate,
    required this.weekDays,
    required this.monthSummary,
  });

  factory TodayDashboard.build(
    ActiveScheduleState schedule,
    CalendarDate today,
  ) {
    final daysToRest = schedule.engine.daysToNextRest(today);
    final remainingWorkDaysBeforeNextRest = daysToRest <= 1
        ? 0
        : schedule
              .days(today.addDays(1), daysToRest - 1)
              .where((day) => day.effectiveKind.isActualWork)
              .length;
    final monthStart = CalendarDate(today.year, today.month, 1);
    final monthDays = DateTime.utc(today.year, today.month + 1, 0).day;
    return TodayDashboard(
      today: schedule.day(today),
      daysToNextRest: daysToRest,
      remainingWorkDaysBeforeNextRest: remainingWorkDaysBeforeNextRest,
      nextRestDate: today.addDays(daysToRest),
      weekDays: schedule.days(today.monday, DateTime.daysPerWeek),
      monthSummary: MonthSummary.fromDays(schedule.days(monthStart, monthDays)),
    );
  }

  final DayPresentation today;
  final int daysToNextRest;
  final int remainingWorkDaysBeforeNextRest;
  final CalendarDate nextRestDate;
  final List<DayPresentation> weekDays;
  final MonthSummary monthSummary;
}

final class MonthSummary {
  const MonthSummary({
    required this.workDays,
    required this.restDays,
    required this.adjustedDays,
    required this.leaveDays,
  });

  factory MonthSummary.fromDays(List<DayPresentation> days) => MonthSummary(
    workDays: days.where((day) => day.effectiveKind == DayKind.work).length,
    restDays: days.where((day) => day.effectiveKind == DayKind.rest).length,
    adjustedDays: days
        .where(
          (day) =>
              day.effectiveKind == DayKind.adjustedWork ||
              day.effectiveKind == DayKind.adjustedRest,
        )
        .length,
    leaveDays: days.where((day) => day.effectiveKind == DayKind.leave).length,
  );

  final int workDays;
  final int restDays;
  final int adjustedDays;
  final int leaveDays;
}
