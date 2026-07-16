import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';

typedef CurrentDateTimerFactory =
    Timer Function(Duration delay, void Function() callback);

final localNowProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final currentDateProvider = Provider<CalendarDate Function()>(
  (ref) =>
      () => CalendarDate.fromDateTime(ref.read(localNowProvider)()),
);

final currentDateTimerFactoryProvider = Provider<CurrentDateTimerFactory>(
  (ref) => Timer.new,
);

final todayProvider = NotifierProvider<CurrentDateController, CalendarDate>(
  CurrentDateController.new,
);

final class CurrentDateController extends Notifier<CalendarDate> {
  static const _midnightGracePeriod = Duration(milliseconds: 100);

  Timer? _timer;

  @override
  CalendarDate build() {
    final currentDate = ref.watch(currentDateProvider);
    ref.watch(localNowProvider);
    ref.watch(currentDateTimerFactoryProvider);
    ref.onDispose(_cancelTimer);
    _scheduleNextMidnight();
    return currentDate();
  }

  void refresh() {
    final current = ref.read(currentDateProvider)();
    if (current != state) state = current;
    _scheduleNextMidnight();
  }

  void _scheduleNextMidnight() {
    _cancelTimer();
    final now = ref.read(localNowProvider)();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final delay = nextMidnight.difference(now) + _midnightGracePeriod;
    _timer = ref.read(currentDateTimerFactoryProvider)(delay, refresh);
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }
}
