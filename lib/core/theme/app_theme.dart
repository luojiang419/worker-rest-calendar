import 'package:flutter/material.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/core/theme/app_visual_style.dart';

abstract final class AppTheme {
  static ThemeData get light => _theme(Brightness.light, AppTokens.light);

  static ThemeData get dark => _theme(Brightness.dark, AppTokens.dark);

  static ThemeData lightFor(AppVisualStyle style) =>
      _theme(Brightness.light, AppTokens.resolve(style, Brightness.light));

  static ThemeData darkFor(AppVisualStyle style) =>
      _theme(Brightness.dark, AppTokens.resolve(style, Brightness.dark));

  static ThemeData _theme(Brightness brightness, AppTokens tokens) {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: tokens.colors.primary,
          brightness: brightness,
        ).copyWith(
          primary: tokens.colors.primary,
          surface: tokens.colors.surface,
          error: tokens.colors.danger,
          outline: tokens.colors.border,
        );
    final textTheme = ThemeData(brightness: brightness).textTheme.apply(
      bodyColor: tokens.colors.textPrimary,
      displayColor: tokens.colors.textPrimary,
    );

    return ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: tokens.visualStyle == AppVisualStyle.glass
          ? Colors.transparent
          : tokens.colors.background,
      textTheme: textTheme,
      extensions: [tokens],
      dividerColor: tokens.colors.border,
      disabledColor: tokens.colors.textSecondary.withValues(alpha: 0.4),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: tokens.colors.surfaceElevated,
        modalBackgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(tokens.radius.sheet),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: tokens.colors.surfaceElevated,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: tokens.colors.textPrimary,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radius.md),
          side: BorderSide(color: tokens.colors.border),
        ),
        elevation: 0,
      ),
      useMaterial3: true,
    );
  }
}
