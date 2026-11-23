import 'package:flutter/material.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';

Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  final tokens = context.tokens;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: tokens.colors.textPrimary.withValues(alpha: 0.22),
    sheetAnimationStyle: AnimationStyle(
      duration: tokens.motion.sheet,
      reverseDuration: tokens.motion.normal,
    ),
    builder: (sheetContext) => Container(
      padding: EdgeInsets.fromLTRB(
        tokens.spacing.lg,
        tokens.spacing.md,
        tokens.spacing.lg,
        MediaQuery.viewInsetsOf(sheetContext).bottom + tokens.spacing.xl,
      ),
      decoration: BoxDecoration(
        color: tokens.colors.surfaceElevated,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(tokens.radius.sheet),
        ),
        border: tokens.borderWidth == 0
            ? null
            : Border(
                top: BorderSide(
                  color: tokens.colors.border,
                  width: tokens.borderWidth,
                ),
              ),
        boxShadow: tokens.shadows.high,
      ),
      child: SafeArea(top: false, child: builder(sheetContext)),
    ),
  );
}
