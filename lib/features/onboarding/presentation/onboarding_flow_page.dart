import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_rest_calendar/app/app_dependencies.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/core/widgets/app_state_view.dart';
import 'package:worker_rest_calendar/core/widgets/app_toast.dart';
import 'package:worker_rest_calendar/features/onboarding/application/onboarding_controller.dart';
import 'package:worker_rest_calendar/features/onboarding/domain/onboarding_draft.dart';
import 'package:worker_rest_calendar/features/onboarding/presentation/onboarding_configuration_page.dart';
import 'package:worker_rest_calendar/features/onboarding/presentation/onboarding_pattern_page.dart';
import 'package:worker_rest_calendar/features/onboarding/presentation/onboarding_preview_page.dart';
import 'package:worker_rest_calendar/features/onboarding/presentation/onboarding_welcome_page.dart';

class OnboardingFlowPage extends ConsumerWidget {
  const OnboardingFlowPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: onboarding.when(
          loading: () =>
              const Center(child: AppLoadingState(label: '正在恢复首次设置')),
          error: (error, stackTrace) => Center(
            child: AppErrorState(
              title: '首次设置加载失败',
              message: '请检查本地存储后重试',
              onRetry: () => ref.invalidate(onboardingControllerProvider),
            ),
          ),
          data: (state) => _OnboardingContent(draft: state.draft),
        ),
      ),
    );
  }
}

class _OnboardingContent extends ConsumerWidget {
  const _OnboardingContent({required this.draft});

  final OnboardingDraft draft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(onboardingControllerProvider.notifier);
    final horizontalPadding = MediaQuery.sizeOf(context).width >= 600
        ? context.tokens.sizes.desktopHorizontalPadding
        : context.tokens.sizes.mobileHorizontalPadding;

    Future<void> showValidation(Future<String?> action) async {
      String? message;
      try {
        message = await action;
      } on Object {
        message = '保存失败，请稍后重试';
      }
      if (message != null && context.mounted) {
        showAppToast(
          context,
          message: message,
          icon: Icons.info_outline_rounded,
        );
      }
    }

    final page = switch (draft.step) {
      OnboardingStep.welcome => OnboardingWelcomePage(
        onContinue: controller.start,
      ),
      OnboardingStep.pattern => OnboardingPatternPage(
        selected: draft.patternType,
        onSelected: controller.selectPattern,
        onBack: controller.goBack,
        onContinue: () => showValidation(controller.continueFromPattern()),
      ),
      OnboardingStep.configuration => OnboardingConfigurationPage(
        draft: draft,
        onAnchorDateChanged: controller.setAnchorDate,
        onWeekTypeChanged: controller.setAnchorWeekType,
        onCycleLengthChanged: controller.setCustomCycleLength,
        onCycleDayChanged: controller.setCustomCycleDay,
        onBack: controller.goBack,
        onContinue: () =>
            showValidation(controller.continueFromConfiguration()),
      ),
      OnboardingStep.preview => OnboardingPreviewPage(
        draft: draft,
        startDate: ref.read(todayProvider),
        onBack: controller.goBack,
        onComplete: () => showValidation(controller.complete()),
      ),
    };

    return AnimatedSwitcher(
      duration: context.tokens.motion.normal,
      child: Padding(
        key: ValueKey(draft.step),
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: page,
      ),
    );
  }
}
