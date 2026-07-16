import 'package:flutter/material.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/core/widgets/app_button.dart';

class AppLoadingState extends StatelessWidget {
  const AppLoadingState({super.key, this.label = '正在加载'});

  final String label;

  @override
  Widget build(BuildContext context) => _StateView(
    icon: SizedBox.square(
      dimension: context.tokens.sizes.minTouch,
      child: const CircularProgressIndicator(strokeWidth: 3),
    ),
    title: label,
  );
}

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.title,
    required this.message,
    super.key,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => _StateView(
    icon: Icon(
      Icons.calendar_today_outlined,
      size: context.tokens.sizes.minTouch,
      color: context.tokens.colors.textSecondary,
    ),
    title: title,
    message: message,
    actionLabel: actionLabel,
    onAction: onAction,
  );
}

class AppErrorState extends StatelessWidget {
  const AppErrorState({
    required this.title,
    required this.message,
    super.key,
    this.retryLabel = '重试',
    this.onRetry,
  });

  final String title;
  final String message;
  final String retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => _StateView(
    icon: Icon(
      Icons.error_outline_rounded,
      size: context.tokens.sizes.minTouch,
      color: context.tokens.colors.danger,
    ),
    title: title,
    message: message,
    actionLabel: retryLabel,
    onAction: onRetry,
  );
}

class _StateView extends StatelessWidget {
  const _StateView({
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final Widget icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Semantics(
      container: true,
      label: [title, message].whereType<String>().join('，'),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            SizedBox(height: tokens.spacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            if (message case final value?) ...[
              SizedBox(height: tokens.spacing.sm),
              Text(
                value,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: tokens.colors.textSecondary,
                ),
              ),
            ],
            if (actionLabel case final label?) ...[
              SizedBox(height: tokens.spacing.lg),
              AppButton.secondary(label: label, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}
