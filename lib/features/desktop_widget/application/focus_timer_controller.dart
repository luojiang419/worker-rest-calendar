import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FocusTimerStatus { idle, running, paused, completed }

final class FocusTimerState {
  const FocusTimerState({
    this.totalSeconds = 25 * 60,
    this.remainingSeconds = 25 * 60,
    this.status = FocusTimerStatus.idle,
  });

  final int totalSeconds;
  final int remainingSeconds;
  final FocusTimerStatus status;

  double get elapsedProgress =>
      totalSeconds == 0 ? 0 : 1 - remainingSeconds / totalSeconds;

  FocusTimerState copyWith({
    int? totalSeconds,
    int? remainingSeconds,
    FocusTimerStatus? status,
  }) => FocusTimerState(
    totalSeconds: totalSeconds ?? this.totalSeconds,
    remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    status: status ?? this.status,
  );
}

final focusTimerNowProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

final focusTimerControllerProvider =
    NotifierProvider<FocusTimerController, FocusTimerState>(
      FocusTimerController.new,
    );

final class FocusTimerController extends Notifier<FocusTimerState> {
  Timer? _timer;
  DateTime? _endsAt;

  DateTime get _now => ref.read(focusTimerNowProvider)();

  @override
  FocusTimerState build() {
    ref.onDispose(_cancelTimer);
    return const FocusTimerState();
  }

  void start() {
    if (state.status == FocusTimerStatus.running) return;
    final remaining = state.remainingSeconds == 0
        ? state.totalSeconds
        : state.remainingSeconds;
    _endsAt = _now.add(Duration(seconds: remaining));
    state = state.copyWith(
      remainingSeconds: remaining,
      status: FocusTimerStatus.running,
    );
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => synchronize());
  }

  void pause() {
    if (state.status != FocusTimerStatus.running) return;
    synchronize();
    _cancelTimer();
    _endsAt = null;
    if (state.remainingSeconds > 0) {
      state = state.copyWith(status: FocusTimerStatus.paused);
    }
  }

  void reset() {
    _cancelTimer();
    _endsAt = null;
    state = FocusTimerState(
      totalSeconds: state.totalSeconds,
      remainingSeconds: state.totalSeconds,
    );
  }

  void synchronize() {
    final endsAt = _endsAt;
    if (state.status != FocusTimerStatus.running || endsAt == null) return;
    final milliseconds = endsAt.difference(_now).inMilliseconds;
    if (milliseconds <= 0) {
      _cancelTimer();
      _endsAt = null;
      state = state.copyWith(
        remainingSeconds: 0,
        status: FocusTimerStatus.completed,
      );
      return;
    }
    final remaining = (milliseconds + 999) ~/ 1000;
    if (remaining != state.remainingSeconds) {
      state = state.copyWith(remainingSeconds: remaining);
    }
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }
}
