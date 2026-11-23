import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/schedule/application/active_schedule_controller.dart';
import 'package:worker_rest_calendar/features/schedule/application/day_presentation.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';

final class DesktopWidgetSnapshot {
  const DesktopWidgetSnapshot({
    required this.today,
    required this.daysToNextRest,
    required this.nextRestDate,
    required this.weekDays,
    required this.monthDays,
    required this.month,
    required this.remainingWeekWorkDays,
    required this.remainingMonthWorkDays,
  });

  factory DesktopWidgetSnapshot.build(
    ActiveScheduleState schedule,
    CalendarDate today,
  ) {
    final daysToNextRest = schedule.engine.daysToNextRest(today);
    final monthStart = CalendarDate(today.year, today.month, 1);
    final gridStart = monthStart.monday;
    final tomorrow = today.addDays(1);
    final weekEnd = today.monday.addDays(DateTime.daysPerWeek - 1);
    final monthEnd = CalendarDate(
      today.year,
      today.month,
      DateTime.utc(today.year, today.month + 1, 0).day,
    );
    return DesktopWidgetSnapshot(
      today: schedule.day(today),
      daysToNextRest: daysToNextRest,
      nextRestDate: today.addDays(daysToNextRest),
      weekDays: schedule.days(today.monday, DateTime.daysPerWeek),
      monthDays: schedule.days(gridStart, 42),
      month: monthStart,
      remainingWeekWorkDays: _countActualWorkDays(schedule, tomorrow, weekEnd),
      remainingMonthWorkDays: _countActualWorkDays(
        schedule,
        tomorrow,
        monthEnd,
      ),
    );
  }

  final DayPresentation today;
  final int daysToNextRest;
  final CalendarDate nextRestDate;
  final List<DayPresentation> weekDays;
  final List<DayPresentation> monthDays;
  final CalendarDate month;
  final int remainingWeekWorkDays;
  final int remainingMonthWorkDays;

  WeekType? get currentWeekType => today.weekType;

  static int _countActualWorkDays(
    ActiveScheduleState schedule,
    CalendarDate start,
    CalendarDate end,
  ) {
    if (start.compareTo(end) > 0) return 0;
    return schedule
        .days(start, end.daysSince(start) + 1)
        .where((day) => day.effectiveKind.isActualWork)
        .length;
  }
}
