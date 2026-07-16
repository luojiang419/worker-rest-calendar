import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/core/date/current_date_controller.dart';
import 'package:worker_rest_calendar/core/date/current_date_lifecycle.dart';

void main() {
  test('到达本地午夜后自动发布新日期并安排下一次刷新', () {
    var now = DateTime(2026, 7, 14, 23, 59, 30);
    final scheduler = _FakeTimerScheduler();
    final container = ProviderContainer(
      overrides: [
        localNowProvider.overrideWithValue(() => now),
        currentDateProvider.overrideWithValue(
          () => CalendarDate.fromDateTime(now),
        ),
        currentDateTimerFactoryProvider.overrideWithValue(scheduler.create),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(todayProvider), CalendarDate(2026, 7, 14));
    expect(scheduler.lastDelay, const Duration(seconds: 30, milliseconds: 100));

    now = DateTime(2026, 7, 15, 0, 0, 0, 100);
    scheduler.fire();

    expect(container.read(todayProvider), CalendarDate(2026, 7, 15));
    expect(scheduler.lastDelay, const Duration(hours: 24));
    expect(scheduler.createCount, 2);
  });

  test('从后台恢复时立即校正日期并重排午夜定时器', () {
    var now = DateTime(2026, 7, 14, 22);
    final scheduler = _FakeTimerScheduler();
    final container = ProviderContainer(
      overrides: [
        localNowProvider.overrideWithValue(() => now),
        currentDateProvider.overrideWithValue(
          () => CalendarDate.fromDateTime(now),
        ),
        currentDateTimerFactoryProvider.overrideWithValue(scheduler.create),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(todayProvider), CalendarDate(2026, 7, 14));
    final firstTimer = scheduler.lastTimer;

    now = DateTime(2026, 7, 16, 8);
    container.read(todayProvider.notifier).refresh();

    expect(firstTimer.isActive, isFalse);
    expect(container.read(todayProvider), CalendarDate(2026, 7, 16));
    expect(scheduler.lastDelay, const Duration(hours: 16, milliseconds: 100));
  });

  testWidgets('应用恢复前台时由生命周期监听器校正日期', (tester) async {
    var now = DateTime(2026, 7, 14, 22);
    final scheduler = _FakeTimerScheduler();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localNowProvider.overrideWithValue(() => now),
          currentDateProvider.overrideWithValue(
            () => CalendarDate.fromDateTime(now),
          ),
          currentDateTimerFactoryProvider.overrideWithValue(scheduler.create),
        ],
        child: const MaterialApp(
          home: CurrentDateLifecycle(child: SizedBox.shrink()),
        ),
      ),
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(CurrentDateLifecycle)),
    );
    expect(container.read(todayProvider), CalendarDate(2026, 7, 14));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    now = DateTime(2026, 7, 15, 8);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(container.read(todayProvider), CalendarDate(2026, 7, 15));
  });
}

final class _FakeTimerScheduler {
  Duration? lastDelay;
  void Function()? _callback;
  _FakeTimer? _lastTimer;
  int createCount = 0;

  _FakeTimer get lastTimer => _lastTimer!;

  Timer create(Duration delay, void Function() callback) {
    lastDelay = delay;
    _callback = callback;
    createCount += 1;
    return _lastTimer = _FakeTimer();
  }

  void fire() {
    final callback = _callback!;
    _lastTimer!._complete();
    callback();
  }
}

final class _FakeTimer implements Timer {
  var _isActive = true;

  @override
  bool get isActive => _isActive;

  @override
  int get tick => _isActive ? 0 : 1;

  @override
  void cancel() => _isActive = false;

  void _complete() => _isActive = false;
}
