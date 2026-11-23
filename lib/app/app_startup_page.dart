import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_rest_calendar/core/widgets/app_state_view.dart';
import 'package:worker_rest_calendar/features/desktop_widget/data/desktop_window_bootstrap.dart';
import 'package:worker_rest_calendar/features/desktop_widget/presentation/desktop_widget_shell.dart';
import 'package:worker_rest_calendar/features/holidays/application/holiday_data_providers.dart';
import 'package:worker_rest_calendar/features/home/presentation/home_page.dart';
import 'package:worker_rest_calendar/features/home_widget/presentation/home_widget_lifecycle_sync.dart';
import 'package:worker_rest_calendar/features/onboarding/application/onboarding_controller.dart';
import 'package:worker_rest_calendar/features/onboarding/presentation/onboarding_flow_page.dart';
import 'package:worker_rest_calendar/features/updater/presentation/update_prompt_coordinator.dart';

class AppStartupPage extends ConsumerWidget {
  const AppStartupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holidayData = ref.watch(holidayDataBootstrapProvider);
    return holidayData.when(
      loading: () => const Scaffold(
        body: SafeArea(
          child: Center(child: AppLoadingState(label: '正在加载法定节假日')),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        body: SafeArea(
          child: Center(
            child: AppErrorState(
              title: '应用启动失败',
              message: '法定节假日数据暂时无法读取',
              onRetry: () => ref.invalidate(holidayDataBootstrapProvider),
            ),
          ),
        ),
      ),
      data: (_) {
        final onboarding = ref.watch(onboardingControllerProvider);
        return onboarding.when(
          loading: () => const Scaffold(
            body: SafeArea(
              child: Center(child: AppLoadingState(label: '正在打开日历')),
            ),
          ),
          error: (error, stackTrace) => Scaffold(
            body: SafeArea(
              child: Center(
                child: AppErrorState(
                  title: '应用启动失败',
                  message: '本地数据暂时无法读取',
                  onRetry: () => ref.invalidate(onboardingControllerProvider),
                ),
              ),
            ),
          ),
          data: (state) => UpdatePromptCoordinator(
            child: state.isCompleted
                ? ref.watch(desktopWidgetPlatformProvider)
                      ? const DesktopWidgetShell()
                      : const HomeWidgetLifecycleSync(child: HomePage())
                : const OnboardingFlowPage(),
          ),
        );
      },
    );
  }
}
