import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/features/desktop_widget/application/focus_timer_controller.dart';

void main() {
  test('专注计时器依据目标时间校正并在超时后完成', () {
    var now = DateTime(2026, 7, 16, 10);
    final container = ProviderContainer(
      overrides: [focusTimerNowProvider.overrideWithValue(() => now)],
    );
    addTearDown(container.dispose);
    final controller = container.read(focusTimerControllerProvider.notifier);

    controller.start();
    expect(
      container.read(focusTimerControllerProvider).status,
      FocusTimerStatus.running,
    );
    now = now.add(const Duration(minutes: 7, seconds: 12));
    controller.synchronize();
    expect(container.read(focusTimerControllerProvider).remainingSeconds, 1068);

    now = now.add(const Duration(minutes: 30));
    controller.synchronize();
    final completed = container.read(focusTimerControllerProvider);
    expect(completed.remainingSeconds, 0);
    expect(completed.status, FocusTimerStatus.completed);
  });

  test('暂停冻结剩余时间，继续后重建目标时间，重置恢复 25 分钟', () {
    var now = DateTime(2026, 7, 16, 10);
    final container = ProviderContainer(
      overrides: [focusTimerNowProvider.overrideWithValue(() => now)],
    );
    addTearDown(container.dispose);
    final controller = container.read(focusTimerControllerProvider.notifier);

    controller.start();
    now = now.add(const Duration(seconds: 90));
    controller.pause();
    expect(container.read(focusTimerControllerProvider).remainingSeconds, 1410);
    now = now.add(const Duration(hours: 1));
    controller.synchronize();
    expect(container.read(focusTimerControllerProvider).remainingSeconds, 1410);

    controller.start();
    now = now.add(const Duration(seconds: 10));
    controller.synchronize();
    expect(container.read(focusTimerControllerProvider).remainingSeconds, 1400);
    controller.reset();
    final reset = container.read(focusTimerControllerProvider);
    expect(reset.remainingSeconds, 1500);
    expect(reset.status, FocusTimerStatus.idle);
  });
}
