import 'package:flutter/material.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/core/widgets/app_button.dart';
import 'package:worker_rest_calendar/core/widgets/app_card.dart';

class OnboardingWelcomePage extends StatelessWidget {
  const OnboardingWelcomePage({required this.onContinue, super.key});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(tokens.spacing.xl),
                decoration: BoxDecoration(
                  color: tokens.colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(tokens.radius.xl),
                  boxShadow: tokens.shadows.medium,
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  size: tokens.sizes.minTouch,
                  color: tokens.colors.primary,
                ),
              ),
              SizedBox(height: tokens.spacing.xl),
              Text(
                '先告诉我你的休息节奏',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: tokens.spacing.md),
              Text(
                '选一个班制、确认起始日，就能立即看到未来上班和休息安排。整个过程通常不到 90 秒。',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: tokens.colors.textSecondary,
                  height: 1.5,
                ),
              ),
              SizedBox(height: tokens.spacing.xl),
              AppCard(
                shadowLevel: AppShadowLevel.low,
                child: Row(
                  children: [
                    Icon(Icons.lock_outline_rounded, color: tokens.colors.rest),
                    SizedBox(width: tokens.spacing.md),
                    const Expanded(child: Text('排班只保存在本机，无需注册账号')),
                  ],
                ),
              ),
              SizedBox(height: tokens.spacing.xl),
              AppButton.primary(
                label: '开始设置',
                icon: Icons.arrow_forward_rounded,
                expand: true,
                onPressed: onContinue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
