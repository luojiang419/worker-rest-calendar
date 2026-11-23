import 'package:flutter/material.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/core/theme/app_visual_style.dart';
import 'package:worker_rest_calendar/core/widgets/app_card.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

class DesktopWidgetFrame extends StatelessWidget {
  const DesktopWidgetFrame({
    required this.size,
    required this.child,
    required this.cardKey,
    required this.shadowSafeAreaKey,
    super.key,
  });

  final DesktopWidgetSize size;
  final Widget child;
  final Key cardKey;
  final Key shadowSafeAreaKey;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final desktopShadows = tokens.shadows.medium.isEmpty
        ? AppTokens.resolve(
            AppVisualStyle.classic,
            Theme.of(context).brightness,
          ).shadows.medium
        : tokens.shadows.medium;
    return Material(
      type: MaterialType.transparency,
      child: Padding(
        key: shadowSafeAreaKey,
        padding: const EdgeInsets.all(8),
        child: AppCard(
          key: cardKey,
          showBorder: false,
          boxShadow: desktopShadows,
          padding: EdgeInsets.all(
            size == DesktopWidgetSize.large
                ? tokens.spacing.md
                : tokens.spacing.sm + tokens.spacing.xs,
          ),
          child: child,
        ),
      ),
    );
  }
}
