import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';

enum HomeNavigationTarget {
  today,
  calendar,
  statistics,
  reminderSettings,
  dataManagement,
}

final class HomeNavigationRequest {
  const HomeNavigationRequest({
    required this.id,
    this.target,
    this.selectedDate,
  });

  final int id;
  final HomeNavigationTarget? target;
  final CalendarDate? selectedDate;
}

final homeNavigationControllerProvider =
    NotifierProvider<HomeNavigationController, HomeNavigationRequest?>(
      HomeNavigationController.new,
    );

final class HomeNavigationController extends Notifier<HomeNavigationRequest?> {
  var _nextId = 0;

  @override
  HomeNavigationRequest? build() => null;

  void open(HomeNavigationTarget target) {
    state = HomeNavigationRequest(id: ++_nextId, target: target);
  }

  void openDate(CalendarDate date) {
    state = HomeNavigationRequest(id: ++_nextId, selectedDate: date);
  }

  void clear(int id) {
    if (state?.id == id) state = null;
  }
}
