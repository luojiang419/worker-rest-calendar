import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/features/desktop_widget/application/focus_timer_controller.dart';
import 'package:worker_rest_calendar/features/desktop_widget/presentation/desktop_widget_frame.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

class DesktopFocusCard extends ConsumerWidget {
  const DesktopFocusCard({required this.size, super.key});

  final DesktopWidgetSize size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final state = ref.watch(focusTimerControllerProvider);
    final controller = ref.read(focusTimerControllerProvider.notifier);
    final compact = size == DesktopWidgetSize.small;
    final minutes = state.remainingSeconds ~/ 60;
    final seconds = state.remainingSeconds % 60;
    final time = '${_two(minutes)}:${_two(seconds)}';
    final status = switch (state.status) {
      FocusTimerStatus.idle => '准备开始',
      FocusTimerStatus.running => '保持专注',
      FocusTimerStatus.paused => '已暂停',
      FocusTimerStatus.completed => '本轮完成',
    };
    return DesktopWidgetFrame(
      size: size,
      cardKey: ValueKey('desktop-focus-card-${tokens.visualStyle.name}'),
      shadowSafeAreaKey: const ValueKey('desktop-focus-shadow-safe-area'),
      child: Semantics(
        label: '专注计时器，$status，剩余$time',
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 18,
                  color: tokens.colors.primary,
                ),
                SizedBox(width: tokens.spacing.sm),
                Expanded(
                  child: Text(
                    '专注时间',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  status,
                  key: const ValueKey('desktop-focus-status'),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: state.status == FocusTimerStatus.completed
                        ? tokens.colors.rest
                        : tokens.colors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox.square(
                    dimension: compact ? 94 : 116,
                    child: Stack(
                      fit: StackFit.expand,
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          key: const ValueKey('desktop-focus-progress'),
                          value: state.elapsedProgress.clamp(0, 1),
                          strokeWidth: compact ? 7 : 9,
                          strokeCap: StrokeCap.round,
                          color: state.status == FocusTimerStatus.completed
                              ? tokens.colors.rest
                              : tokens.colors.primary,
                          backgroundColor: tokens.colors.surfaceElevated,
                        ),
                        Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              time,
                              key: const ValueKey('desktop-focus-time'),
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  key: const ValueKey('desktop-focus-toggle'),
                  tooltip: state.status == FocusTimerStatus.running
                      ? '暂停'
                      : state.status == FocusTimerStatus.paused
                      ? '继续'
                      : '开始',
                  onPressed: state.status == FocusTimerStatus.running
                      ? controller.pause
                      : controller.start,
                  icon: Icon(
                    state.status == FocusTimerStatus.running
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                  ),
                ),
                SizedBox(width: tokens.spacing.md),
                IconButton(
                  key: const ValueKey('desktop-focus-reset'),
                  tooltip: '重置',
                  onPressed: controller.reset,
                  icon: const Icon(Icons.replay_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}
