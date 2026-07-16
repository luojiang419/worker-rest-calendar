import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_rest_calendar/app/app_dependencies.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';

enum CalendarViewMode { month, week }

final calendarControllerProvider =
    NotifierProvider<CalendarController, CalendarViewState>(
      CalendarController.new,
    );

final class CalendarViewState {
  const CalendarViewState({
    required this.mode,
    required this.displayedDate,
    required this.selectedDate,
  });

  final CalendarViewMode mode;
  final CalendarDate displayedDate;
  final CalendarDate selectedDate;

  CalendarDate get visibleStart => switch (mode) {
    CalendarViewMode.month => CalendarDate(
      displayedDate.year,
      displayedDate.month,
      1,
    ).monday,
    CalendarViewMode.week => displayedDate.monday,
  };

  int get visibleDayCount =>
      mode == CalendarViewMode.month ? 42 : DateTime.daysPerWeek;

  String get periodLabel => mode == CalendarViewMode.month
      ? '${displayedDate.year}年${displayedDate.month}月'
      : '${visibleStart.month}月${visibleStart.day}日 – ${visibleStart.addDays(6).month}月${visibleStart.addDays(6).day}日';

  CalendarViewState copyWith({
    CalendarViewMode? mode,
    CalendarDate? displayedDate,
    CalendarDate? selectedDate,
  }) => CalendarViewState(
    mode: mode ?? this.mode,
    displayedDate: displayedDate ?? this.displayedDate,
    selectedDate: selectedDate ?? this.selectedDate,
  );
}

final class CalendarController extends Notifier<CalendarViewState> {
  @override
  CalendarViewState build() {
    final today = ref.read(todayProvider);
    return CalendarViewState(
      mode: CalendarViewMode.month,
      displayedDate: today,
      selectedDate: today,
    );
  }

  void setMode(CalendarViewMode mode) {
    state = state.copyWith(mode: mode);
  }

  void selectDate(CalendarDate date) {
    state = state.copyWith(displayedDate: date, selectedDate: date);
  }

  void showMonth(CalendarDate date) {
    final month = CalendarDate(date.year, date.month, 1);
    if (state.displayedDate.year == month.year &&
        state.displayedDate.month == month.month) {
      return;
    }
    state = state.copyWith(displayedDate: month, selectedDate: month);
  }

  void previousPeriod() => _movePeriod(-1);

  void nextPeriod() => _movePeriod(1);

  void goToday() {
    final today = ref.read(todayProvider);
    state = state.copyWith(displayedDate: today, selectedDate: today);
  }

  void _movePeriod(int direction) {
    final date = state.displayedDate;
    final moved = switch (state.mode) {
      CalendarViewMode.month => _monthDate(date, direction),
      CalendarViewMode.week => date.addDays(direction * DateTime.daysPerWeek),
    };
    state = state.copyWith(displayedDate: moved, selectedDate: moved);
  }

  CalendarDate _monthDate(CalendarDate date, int delta) {
    final normalized = DateTime.utc(date.year, date.month + delta, 1);
    return CalendarDate(normalized.year, normalized.month, normalized.day);
  }
}
