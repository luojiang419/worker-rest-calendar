import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_rest_calendar/app/app_dependencies.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/schedule/application/active_schedule_controller.dart';
import 'package:worker_rest_calendar/features/statistics/domain/schedule_statistics.dart';

final statisticsPeriodProvider =
    NotifierProvider<StatisticsPeriodController, CalendarDate>(
      StatisticsPeriodController.new,
    );

final statisticsDashboardProvider = Provider<AsyncValue<StatisticsDashboard>>((
  ref,
) {
  final schedule = ref.watch(activeScheduleControllerProvider);
  final period = ref.watch(statisticsPeriodProvider);
  final today = ref.watch(todayProvider);
  return schedule.whenData((value) {
    final calculator = ScheduleStatisticsCalculator(value.engine);
    return StatisticsDashboard(
      period: period,
      monthly: calculator.calculateMonth(
        year: period.year,
        month: period.month,
      ),
      currentStreak: calculator.calculateCurrentStreak(today),
      heatmap: calculator.calculateYear(period.year),
    );
  });
});

final class StatisticsPeriodController extends Notifier<CalendarDate> {
  @override
  CalendarDate build() {
    final today = ref.read(todayProvider);
    return CalendarDate(today.year, today.month, 1);
  }

  void previousMonth() => _moveMonth(-1);

  void nextMonth() => _moveMonth(1);

  void previousYear() => state = CalendarDate(state.year - 1, state.month, 1);

  void nextYear() => state = CalendarDate(state.year + 1, state.month, 1);

  void goCurrentMonth() {
    final today = ref.read(todayProvider);
    state = CalendarDate(today.year, today.month, 1);
  }

  void _moveMonth(int delta) {
    final normalized = DateTime.utc(state.year, state.month + delta, 1);
    state = CalendarDate(normalized.year, normalized.month, 1);
  }
}

final class StatisticsDashboard {
  const StatisticsDashboard({
    required this.period,
    required this.monthly,
    required this.currentStreak,
    required this.heatmap,
  });

  final CalendarDate period;
  final MonthlyScheduleStatistics monthly;
  final CurrentWorkStreak currentStreak;
  final AnnualScheduleHeatmap heatmap;
}
