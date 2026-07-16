import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_rest_calendar/app/app_dependencies.dart';
import 'package:worker_rest_calendar/core/widgets/app_state_view.dart';
import 'package:worker_rest_calendar/features/desktop_widget/application/desktop_widget_controller.dart';
import 'package:worker_rest_calendar/features/desktop_widget/application/desktop_widget_display_mode.dart';
import 'package:worker_rest_calendar/features/desktop_widget/domain/desktop_widget_snapshot.dart';
import 'package:worker_rest_calendar/features/desktop_widget/presentation/desktop_widget_card.dart';
import 'package:worker_rest_calendar/features/home/presentation/home_page.dart';
import 'package:worker_rest_calendar/features/schedule/application/active_schedule_controller.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

class DesktopWidgetShell extends ConsumerWidget {
  const DesktopWidgetShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controllerState = ref.watch(desktopWidgetControllerProvider);
    final displayMode = controllerState.value?.showFullApp == true
        ? DesktopWidgetDisplayMode.fullApp
        : DesktopWidgetDisplayMode.widget;
    if (ref.read(desktopWidgetDisplayModeProvider) != displayMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        final controller = ref.read(desktopWidgetDisplayModeProvider.notifier);
        switch (displayMode) {
          case DesktopWidgetDisplayMode.fullApp:
            controller.showFullApp();
          case DesktopWidgetDisplayMode.widget:
            controller.showWidget();
        }
      });
    }
    return controllerState.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        backgroundColor: Colors.transparent,
        body: AppErrorState(
          title: '桌面小组件启动失败',
          message: '窗口设置暂时无法读取',
          onRetry: () => ref.invalidate(desktopWidgetControllerProvider),
        ),
      ),
      data: (state) {
        if (state.showFullApp) {
          return HomePage(
            initialDate: state.selectedDate,
            onReturnToWidget: () => ref
                .read(desktopWidgetControllerProvider.notifier)
                .returnToWidget(),
          );
        }
        return _WidgetMode(preferences: state.preferences);
      },
    );
  }
}

class _WidgetMode extends ConsumerWidget {
  const _WidgetMode({required this.preferences});

  final AppPreferences preferences;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedule = ref.watch(activeScheduleControllerProvider);
    final controller = ref.read(desktopWidgetControllerProvider.notifier);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onDoubleTap: controller.openFullApp,
        onPanStart: preferences.desktopWidgetLocked
            ? null
            : (_) => controller.startDragging(),
        onSecondaryTapDown: (_) => controller.showContextMenu(),
        child: schedule.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => AppErrorState(
            title: '排班加载失败',
            message: '请打开完整应用后重试',
            onRetry: () => ref.invalidate(activeScheduleControllerProvider),
          ),
          data: (activeSchedule) {
            final snapshot = DesktopWidgetSnapshot.build(
              activeSchedule,
              ref.watch(todayProvider),
            );
            return DesktopWidgetCard(
              snapshot: snapshot,
              size: preferences.desktopWidgetSize,
              largeDateShape: preferences.desktopWidgetLargeDateShape,
              todayHighlightStyle: preferences.desktopWidgetTodayHighlightStyle,
              onOpenDate: (day) =>
                  controller.openFullApp(selectedDate: day.date),
            );
          },
        ),
      ),
    );
  }
}
