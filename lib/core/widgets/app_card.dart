import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';

enum AppShadowLevel { none, low, medium, high }

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    super.key,
    this.padding,
    this.shadowLevel = AppShadowLevel.medium,
    this.radius,
    this.color,
    this.onTap,
    this.semanticLabel,
    this.showBorder = true,
    this.borderColor,
    this.boxShadow,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final AppShadowLevel shadowLevel;
  final double? radius;
  final Color? color;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool showBorder;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final borderRadius = BorderRadius.circular(radius ?? tokens.radius.lg);
    final shadows =
        boxShadow ??
        switch (shadowLevel) {
          AppShadowLevel.none => const <BoxShadow>[],
          AppShadowLevel.low => tokens.shadows.low,
          AppShadowLevel.medium => tokens.shadows.medium,
          AppShadowLevel.high => tokens.shadows.high,
        };

    final decoration = BoxDecoration(
      color: color ?? tokens.colors.surface,
      gradient: color == null && tokens.surfaceHighlight != Colors.transparent
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [tokens.surfaceHighlight, tokens.colors.surface],
            )
          : null,
      borderRadius: borderRadius,
      border: !showBorder || tokens.borderWidth == 0
          ? null
          : Border.all(
              color: borderColor ?? tokens.colors.border,
              width: tokens.borderWidth,
            ),
      boxShadow: shadows,
    );
    Widget content = Container(
      padding: padding ?? EdgeInsets.all(tokens.spacing.lg),
      decoration: decoration,
      child: child,
    );
    if (tokens.blurSigma > 0) {
      content = ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: tokens.blurSigma,
            sigmaY: tokens.blurSigma,
          ),
          child: content,
        ),
      );
    }

    if (onTap == null) {
      return Semantics(container: true, label: semanticLabel, child: content);
    }
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: content,
        ),
      ),
    );
  }
}
