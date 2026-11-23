import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/app/app_dependencies.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/calendar/application/calendar_controller.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        currentDateProvider.overrideWithValue(() => CalendarDate(2026, 7, 13)),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('月视图固定生成从周一开始的 42 天', () {
    final state = container.read(calendarControllerProvider);

    expect(state.mode, CalendarViewMode.month);
    expect(state.visibleStart, CalendarDate(2026, 6, 29));
    expect(state.visibleDayCount, 42);
    expect(state.periodLabel, '2026年7月');
  });

  test('月/周切换、前后周期和回到今天正确更新日期', () {
    final controller = container.read(calendarControllerProvider.notifier);

    controller.nextPeriod();
    expect(
      container.read(calendarControllerProvider).displayedDate,
      CalendarDate(2026, 8, 1),
    );
    controller.setMode(CalendarViewMode.week);
    controller.previousPeriod();
    expect(
      container.read(calendarControllerProvider).displayedDate,
      CalendarDate(2026, 7, 25),
    );
    expect(
      container.read(calendarControllerProvider).visibleStart,
      CalendarDate(2026, 7, 20),
    );
    controller.goToday();
    expect(
      container.read(calendarControllerProvider).selectedDate,
      CalendarDate(2026, 7, 13),
    );
  });

  test('月份切换跨年安全', () {
    final controller = container.read(calendarControllerProvider.notifier);
    controller.selectDate(CalendarDate(2026, 12, 20));

    controller.nextPeriod();

    expect(container.read(calendarControllerProvider).periodLabel, '2027年1月');
  });

  test('滚动显示月份时归一到月首并同步选中日期', () {
    final controller = container.read(calendarControllerProvider.notifier);

    controller.showMonth(CalendarDate(2027, 2, 18));

    final state = container.read(calendarControllerProvider);
    expect(state.displayedDate, CalendarDate(2027, 2, 1));
    expect(state.selectedDate, CalendarDate(2027, 2, 1));
    expect(state.periodLabel, '2027年2月');
  });
}
