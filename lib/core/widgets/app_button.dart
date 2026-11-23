import 'package:flutter/material.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';

enum AppButtonVariant { primary, secondary, danger }

class AppButton extends StatefulWidget {
  const AppButton.primary({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.expand = false,
    this.semanticLabel,
  }) : variant = AppButtonVariant.primary;

  const AppButton.secondary({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.expand = false,
    this.semanticLabel,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.danger({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.expand = false,
    this.semanticLabel,
  }) : variant = AppButtonVariant.danger;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;
  final String? semanticLabel;
  final AppButtonVariant variant;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final enabled = widget.onPressed != null;
    final style = _style(context, tokens);
    final borderRadius = BorderRadius.circular(tokens.radius.md);
    final content = AnimatedScale(
      scale: _pressed && enabled ? 0.98 : 1,
      duration: tokens.motion.fast,
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: tokens.motion.fast,
        constraints: BoxConstraints(
          minHeight: tokens.sizes.buttonHeight,
          minWidth: tokens.sizes.minTouch,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.lg,
          vertical: tokens.spacing.sm,
        ),
        decoration: BoxDecoration(
          color: enabled
              ? style.background
              : style.background.withValues(alpha: 0.4),
          borderRadius: borderRadius,
          border: tokens.borderWidth == 0
              ? null
              : Border.all(
                  color: enabled
                      ? style.border
                      : style.border.withValues(alpha: 0.4),
                  width: tokens.borderWidth,
                ),
          boxShadow: enabled && !_pressed ? style.shadows : tokens.shadows.low,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon case final icon?) ...[
              Icon(icon, size: 20, color: style.foreground),
              SizedBox(width: tokens.spacing.sm),
            ],
            Flexible(
              child: Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: enabled
                      ? style.foreground
                      : style.foreground.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel ?? widget.label,
      child: SizedBox(
        width: widget.expand ? double.infinity : null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onPressed,
          onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
          onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
          onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
          child: content,
        ),
      ),
    );
  }

  _ButtonVisualStyle _style(BuildContext context, AppTokens tokens) {
    final solidForeground = Theme.of(context).brightness == Brightness.light
        ? tokens.colors.surface
        : tokens.colors.textPrimary;
    return switch (widget.variant) {
      AppButtonVariant.primary => _ButtonVisualStyle(
        background: tokens.colors.primary,
        foreground: solidForeground,
        border: tokens.colors.primary,
        shadows: tokens.shadows.medium,
      ),
      AppButtonVariant.secondary => _ButtonVisualStyle(
        background: tokens.colors.surface,
        foreground: tokens.colors.textPrimary,
        border: tokens.colors.border,
        shadows: tokens.shadows.low,
      ),
      AppButtonVariant.danger => _ButtonVisualStyle(
        background: tokens.colors.danger,
        foreground: solidForeground,
        border: tokens.colors.danger,
        shadows: tokens.shadows.medium,
      ),
    };
  }
}

final class _ButtonVisualStyle {
  const _ButtonVisualStyle({
    required this.background,
    required this.foreground,
    required this.border,
    required this.shadows,
  });

  final Color background;
  final Color foreground;
  final Color border;
  final List<BoxShadow> shadows;
}
