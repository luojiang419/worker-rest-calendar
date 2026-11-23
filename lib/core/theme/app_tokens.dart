import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:worker_rest_calendar/core/theme/app_visual_style.dart';

@immutable
final class AppColorTokens {
  const AppColorTokens({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.primary,
    required this.work,
    required this.rest,
    required this.adjustedWork,
    required this.adjustedRest,
    required this.leave,
    required this.danger,
  });

  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color primary;
  final Color work;
  final Color rest;
  final Color adjustedWork;
  final Color adjustedRest;
  final Color leave;
  final Color danger;

  AppColorTokens lerp(AppColorTokens other, double t) => AppColorTokens(
    background: Color.lerp(background, other.background, t)!,
    surface: Color.lerp(surface, other.surface, t)!,
    surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
    textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
    textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
    border: Color.lerp(border, other.border, t)!,
    primary: Color.lerp(primary, other.primary, t)!,
    work: Color.lerp(work, other.work, t)!,
    rest: Color.lerp(rest, other.rest, t)!,
    adjustedWork: Color.lerp(adjustedWork, other.adjustedWork, t)!,
    adjustedRest: Color.lerp(adjustedRest, other.adjustedRest, t)!,
    leave: Color.lerp(leave, other.leave, t)!,
    danger: Color.lerp(danger, other.danger, t)!,
  );
}

@immutable
final class AppRadiusTokens {
  const AppRadiusTokens({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.sheet,
    required this.pill,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double sheet;
  final double pill;

  AppRadiusTokens lerp(AppRadiusTokens other, double t) => AppRadiusTokens(
    xs: lerpDouble(xs, other.xs, t)!,
    sm: lerpDouble(sm, other.sm, t)!,
    md: lerpDouble(md, other.md, t)!,
    lg: lerpDouble(lg, other.lg, t)!,
    xl: lerpDouble(xl, other.xl, t)!,
    sheet: lerpDouble(sheet, other.sheet, t)!,
    pill: lerpDouble(pill, other.pill, t)!,
  );
}

@immutable
final class AppSpacingTokens {
  const AppSpacingTokens({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;

  AppSpacingTokens lerp(AppSpacingTokens other, double t) => AppSpacingTokens(
    xs: lerpDouble(xs, other.xs, t)!,
    sm: lerpDouble(sm, other.sm, t)!,
    md: lerpDouble(md, other.md, t)!,
    lg: lerpDouble(lg, other.lg, t)!,
    xl: lerpDouble(xl, other.xl, t)!,
    xxl: lerpDouble(xxl, other.xxl, t)!,
  );
}

@immutable
final class AppShadowTokens {
  const AppShadowTokens({
    required this.low,
    required this.medium,
    required this.high,
    required this.todayGlow,
  });

  final List<BoxShadow> low;
  final List<BoxShadow> medium;
  final List<BoxShadow> high;
  final List<BoxShadow> todayGlow;

  AppShadowTokens lerp(AppShadowTokens other, double t) => AppShadowTokens(
    low: BoxShadow.lerpList(low, other.low, t)!,
    medium: BoxShadow.lerpList(medium, other.medium, t)!,
    high: BoxShadow.lerpList(high, other.high, t)!,
    todayGlow: BoxShadow.lerpList(todayGlow, other.todayGlow, t)!,
  );
}

@immutable
final class AppMotionTokens {
  const AppMotionTokens({
    required this.fast,
    required this.normal,
    required this.sheet,
    required this.ambient,
  });

  final Duration fast;
  final Duration normal;
  final Duration sheet;
  final Duration ambient;
}

@immutable
final class AppSizeTokens {
  const AppSizeTokens({
    required this.minTouch,
    required this.buttonHeight,
    required this.mobileHorizontalPadding,
    required this.desktopHorizontalPadding,
  });

  final double minTouch;
  final double buttonHeight;
  final double mobileHorizontalPadding;
  final double desktopHorizontalPadding;

  AppSizeTokens lerp(AppSizeTokens other, double t) => AppSizeTokens(
    minTouch: lerpDouble(minTouch, other.minTouch, t)!,
    buttonHeight: lerpDouble(buttonHeight, other.buttonHeight, t)!,
    mobileHorizontalPadding: lerpDouble(
      mobileHorizontalPadding,
      other.mobileHorizontalPadding,
      t,
    )!,
    desktopHorizontalPadding: lerpDouble(
      desktopHorizontalPadding,
      other.desktopHorizontalPadding,
      t,
    )!,
  );
}

@immutable
final class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.colors,
    required this.radius,
    required this.spacing,
    required this.shadows,
    required this.motion,
    required this.sizes,
    this.visualStyle = AppVisualStyle.classic,
    this.backgroundAccent = Colors.transparent,
    this.surfaceHighlight = Colors.transparent,
    this.borderWidth = 1,
    this.blurSigma = 0,
  });

  static const _radius = AppRadiusTokens(
    xs: 8,
    sm: 12,
    md: 16,
    lg: 20,
    xl: 24,
    sheet: 28,
    pill: 999,
  );
  static const _spacing = AppSpacingTokens(
    xs: 4,
    sm: 8,
    md: 12,
    lg: 16,
    xl: 24,
    xxl: 32,
  );
  static const _motion = AppMotionTokens(
    fast: Duration(milliseconds: 160),
    normal: Duration(milliseconds: 240),
    sheet: Duration(milliseconds: 320),
    ambient: Duration(milliseconds: 1600),
  );
  static const _sizes = AppSizeTokens(
    minTouch: 44,
    buttonHeight: 48,
    mobileHorizontalPadding: 16,
    desktopHorizontalPadding: 24,
  );

  static const light = AppTokens(
    colors: AppColorTokens(
      background: Color(0xFFF5F5F7),
      surface: Color(0xFFFFFFFF),
      surfaceElevated: Color(0xFFFFFFFF),
      textPrimary: Color(0xFF1D1D1F),
      textSecondary: Color(0xFF6E6E73),
      border: Color(0x1F3C3C43),
      primary: Color(0xFF3478F6),
      work: Color(0xFF74839A),
      rest: Color(0xFF38B889),
      adjustedWork: Color(0xFFF29A38),
      adjustedRest: Color(0xFF26A69A),
      leave: Color(0xFF8E7CF0),
      danger: Color(0xFFEF5B5B),
    ),
    radius: _radius,
    spacing: _spacing,
    shadows: AppShadowTokens(
      low: [
        BoxShadow(
          color: Color(0x0F14233C),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
      medium: [
        BoxShadow(
          color: Color(0x1A14233C),
          blurRadius: 24,
          offset: Offset(0, 8),
        ),
        BoxShadow(
          color: Color(0x0D14233C),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
      high: [
        BoxShadow(
          color: Color(0x2914233C),
          blurRadius: 44,
          offset: Offset(0, 18),
        ),
      ],
      todayGlow: [
        BoxShadow(color: Color(0x3D3478F6), blurRadius: 12, spreadRadius: 1),
      ],
    ),
    motion: _motion,
    sizes: _sizes,
  );

  static const dark = AppTokens(
    colors: AppColorTokens(
      background: Color(0xFF0E1116),
      surface: Color(0xFF171C23),
      surfaceElevated: Color(0xFF1D242D),
      textPrimary: Color(0xFFF6F7F9),
      textSecondary: Color(0xFFA8B0BB),
      border: Color(0x14FFFFFF),
      primary: Color(0xFF5D96FF),
      work: Color(0xFF94A3B8),
      rest: Color(0xFF49D49B),
      adjustedWork: Color(0xFFFFAD4D),
      adjustedRest: Color(0xFF36C2B4),
      leave: Color(0xFFAA98FF),
      danger: Color(0xFFFF7070),
    ),
    radius: _radius,
    spacing: _spacing,
    shadows: AppShadowTokens(
      low: [
        BoxShadow(
          color: Color(0x47000000),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
      medium: [
        BoxShadow(
          color: Color(0x73000000),
          blurRadius: 30,
          offset: Offset(0, 12),
        ),
      ],
      high: [
        BoxShadow(
          color: Color(0x94000000),
          blurRadius: 48,
          offset: Offset(0, 20),
        ),
      ],
      todayGlow: [
        BoxShadow(color: Color(0x525D96FF), blurRadius: 14, spreadRadius: 1),
      ],
    ),
    motion: _motion,
    sizes: _sizes,
  );

  static AppTokens resolve(AppVisualStyle style, Brightness brightness) {
    final base = brightness == Brightness.light ? light : dark;
    return switch ((style, brightness)) {
      (AppVisualStyle.classic, _) => base,
      (AppVisualStyle.flat, Brightness.light) => base.copyWith(
        visualStyle: style,
        colors: const AppColorTokens(
          background: Color(0xFFF4F6F8),
          surface: Color(0xFFFFFFFF),
          surfaceElevated: Color(0xFFFFFFFF),
          textPrimary: Color(0xFF17202A),
          textSecondary: Color(0xFF66727F),
          border: Color(0x1F334155),
          primary: Color(0xFF2563EB),
          work: Color(0xFF64748B),
          rest: Color(0xFF15966A),
          adjustedWork: Color(0xFFE58622),
          adjustedRest: Color(0xFF0F8F83),
          leave: Color(0xFF7C6CE0),
          danger: Color(0xFFDC5151),
        ),
        radius: const AppRadiusTokens(
          xs: 6,
          sm: 8,
          md: 12,
          lg: 14,
          xl: 18,
          sheet: 22,
          pill: 999,
        ),
        shadows: _flatShadows,
      ),
      (AppVisualStyle.flat, Brightness.dark) => base.copyWith(
        visualStyle: style,
        colors: const AppColorTokens(
          background: Color(0xFF101419),
          surface: Color(0xFF181E25),
          surfaceElevated: Color(0xFF202832),
          textPrimary: Color(0xFFF3F5F7),
          textSecondary: Color(0xFFA4AFBA),
          border: Color(0x1FFFFFFF),
          primary: Color(0xFF6A9CFF),
          work: Color(0xFF9AA9BC),
          rest: Color(0xFF43CE98),
          adjustedWork: Color(0xFFFFAE55),
          adjustedRest: Color(0xFF39C1B4),
          leave: Color(0xFFAB9AFF),
          danger: Color(0xFFFF7474),
        ),
        radius: const AppRadiusTokens(
          xs: 6,
          sm: 8,
          md: 12,
          lg: 14,
          xl: 18,
          sheet: 22,
          pill: 999,
        ),
        shadows: _flatShadows,
      ),
      (AppVisualStyle.neumorphic, Brightness.light) => base.copyWith(
        visualStyle: style,
        colors: base.colors.lerp(
          const AppColorTokens(
            background: Color(0xFFE8EDF3),
            surface: Color(0xFFE8EDF3),
            surfaceElevated: Color(0xFFF0F4F8),
            textPrimary: Color(0xFF263240),
            textSecondary: Color(0xFF687686),
            border: Color(0x00FFFFFF),
            primary: Color(0xFF3979DF),
            work: Color(0xFF718096),
            rest: Color(0xFF2EA77A),
            adjustedWork: Color(0xFFE48B2D),
            adjustedRest: Color(0xFF249C91),
            leave: Color(0xFF8574E5),
            danger: Color(0xFFE15A5A),
          ),
          1,
        ),
        shadows: _neumorphicLightShadows,
        borderWidth: 0,
      ),
      (AppVisualStyle.neumorphic, Brightness.dark) => base.copyWith(
        visualStyle: style,
        colors: const AppColorTokens(
          background: Color(0xFF171C23),
          surface: Color(0xFF171C23),
          surfaceElevated: Color(0xFF1C222B),
          textPrimary: Color(0xFFF2F5F8),
          textSecondary: Color(0xFFA8B1BD),
          border: Color(0x00FFFFFF),
          primary: Color(0xFF6A9FFF),
          work: Color(0xFF9AA9BC),
          rest: Color(0xFF49D49B),
          adjustedWork: Color(0xFFFFAD4D),
          adjustedRest: Color(0xFF36C2B4),
          leave: Color(0xFFAA98FF),
          danger: Color(0xFFFF7070),
        ),
        shadows: _neumorphicDarkShadows,
        borderWidth: 0,
      ),
      (AppVisualStyle.glass, Brightness.light) => base.copyWith(
        visualStyle: style,
        colors: const AppColorTokens(
          background: Color(0xFFEAF1FA),
          surface: Color(0xBFFFFFFF),
          surfaceElevated: Color(0xE6FFFFFF),
          textPrimary: Color(0xFF172438),
          textSecondary: Color(0xFF5F6F84),
          border: Color(0x80FFFFFF),
          primary: Color(0xFF3677E8),
          work: Color(0xFF6F8098),
          rest: Color(0xFF219D73),
          adjustedWork: Color(0xFFE68B2B),
          adjustedRest: Color(0xFF188F87),
          leave: Color(0xFF7F6FE0),
          danger: Color(0xFFE2525B),
        ),
        backgroundAccent: const Color(0xFFDCCFFB),
        surfaceHighlight: const Color(0x80FFFFFF),
        blurSigma: 18,
      ),
      (AppVisualStyle.glass, Brightness.dark) => base.copyWith(
        visualStyle: style,
        colors: const AppColorTokens(
          background: Color(0xFF101827),
          surface: Color(0xB3243145),
          surfaceElevated: Color(0xE62B3950),
          textPrimary: Color(0xFFF4F7FC),
          textSecondary: Color(0xFFB3BED0),
          border: Color(0x38FFFFFF),
          primary: Color(0xFF74A6FF),
          work: Color(0xFFA0AFC4),
          rest: Color(0xFF54D6A2),
          adjustedWork: Color(0xFFFFB25B),
          adjustedRest: Color(0xFF43C9BC),
          leave: Color(0xFFB2A1FF),
          danger: Color(0xFFFF7B82),
        ),
        backgroundAccent: const Color(0xFF312A5C),
        surfaceHighlight: const Color(0x1FFFFFFF),
        blurSigma: 18,
      ),
      (AppVisualStyle.paper, Brightness.light) => base.copyWith(
        visualStyle: style,
        colors: const AppColorTokens(
          background: Color(0xFFF4F0E7),
          surface: Color(0xFFFFFCF5),
          surfaceElevated: Color(0xFFFFFEFA),
          textPrimary: Color(0xFF312E29),
          textSecondary: Color(0xFF746D62),
          border: Color(0x246E6253),
          primary: Color(0xFF536F91),
          work: Color(0xFF7A8290),
          rest: Color(0xFF4A9475),
          adjustedWork: Color(0xFFC88442),
          adjustedRest: Color(0xFF468F87),
          leave: Color(0xFF8176B5),
          danger: Color(0xFFC65E5E),
        ),
        radius: const AppRadiusTokens(
          xs: 4,
          sm: 8,
          md: 10,
          lg: 12,
          xl: 16,
          sheet: 20,
          pill: 999,
        ),
        shadows: _paperLightShadows,
      ),
      (AppVisualStyle.paper, Brightness.dark) => base.copyWith(
        visualStyle: style,
        colors: const AppColorTokens(
          background: Color(0xFF1C1A17),
          surface: Color(0xFF26231F),
          surfaceElevated: Color(0xFF2D2924),
          textPrimary: Color(0xFFF2EDE4),
          textSecondary: Color(0xFFB7AEA1),
          border: Color(0x24E7DCCB),
          primary: Color(0xFF91ACCE),
          work: Color(0xFFA7ACB5),
          rest: Color(0xFF70C29A),
          adjustedWork: Color(0xFFE0A467),
          adjustedRest: Color(0xFF6BBAB0),
          leave: Color(0xFFA99ED7),
          danger: Color(0xFFE07D7D),
        ),
        radius: const AppRadiusTokens(
          xs: 4,
          sm: 8,
          md: 10,
          lg: 12,
          xl: 16,
          sheet: 20,
          pill: 999,
        ),
        shadows: _paperDarkShadows,
      ),
    };
  }

  static const _flatShadows = AppShadowTokens(
    low: [],
    medium: [],
    high: [],
    todayGlow: [
      BoxShadow(color: Color(0x243478F6), blurRadius: 8, spreadRadius: 1),
    ],
  );

  static const _neumorphicLightShadows = AppShadowTokens(
    low: [
      BoxShadow(
        color: Color(0xFFFFFFFF),
        blurRadius: 8,
        offset: Offset(-3, -3),
      ),
      BoxShadow(color: Color(0x337A8796), blurRadius: 10, offset: Offset(4, 4)),
    ],
    medium: [
      BoxShadow(
        color: Color(0xE6FFFFFF),
        blurRadius: 14,
        offset: Offset(-6, -6),
      ),
      BoxShadow(color: Color(0x407A8796), blurRadius: 18, offset: Offset(7, 7)),
    ],
    high: [
      BoxShadow(
        color: Color(0xFFFFFFFF),
        blurRadius: 20,
        offset: Offset(-8, -8),
      ),
      BoxShadow(
        color: Color(0x4D6E7A88),
        blurRadius: 26,
        offset: Offset(10, 10),
      ),
    ],
    todayGlow: [BoxShadow(color: Color(0x333979DF), blurRadius: 12)],
  );

  static const _neumorphicDarkShadows = AppShadowTokens(
    low: [
      BoxShadow(color: Color(0x26000000), blurRadius: 10, offset: Offset(4, 4)),
      BoxShadow(
        color: Color(0x12FFFFFF),
        blurRadius: 8,
        offset: Offset(-3, -3),
      ),
    ],
    medium: [
      BoxShadow(color: Color(0x59000000), blurRadius: 18, offset: Offset(7, 7)),
      BoxShadow(
        color: Color(0x14FFFFFF),
        blurRadius: 14,
        offset: Offset(-6, -6),
      ),
    ],
    high: [
      BoxShadow(
        color: Color(0x73000000),
        blurRadius: 28,
        offset: Offset(10, 10),
      ),
      BoxShadow(
        color: Color(0x17FFFFFF),
        blurRadius: 20,
        offset: Offset(-8, -8),
      ),
    ],
    todayGlow: [BoxShadow(color: Color(0x405D96FF), blurRadius: 14)],
  );

  static const _paperLightShadows = AppShadowTokens(
    low: [
      BoxShadow(color: Color(0x146C5B45), blurRadius: 4, offset: Offset(0, 1)),
    ],
    medium: [
      BoxShadow(color: Color(0x1F6C5B45), blurRadius: 12, offset: Offset(0, 5)),
    ],
    high: [
      BoxShadow(
        color: Color(0x296C5B45),
        blurRadius: 24,
        offset: Offset(0, 10),
      ),
    ],
    todayGlow: [BoxShadow(color: Color(0x30536F91), blurRadius: 10)],
  );

  static const _paperDarkShadows = AppShadowTokens(
    low: [
      BoxShadow(color: Color(0x3D000000), blurRadius: 5, offset: Offset(0, 2)),
    ],
    medium: [
      BoxShadow(color: Color(0x59000000), blurRadius: 14, offset: Offset(0, 6)),
    ],
    high: [
      BoxShadow(
        color: Color(0x73000000),
        blurRadius: 28,
        offset: Offset(0, 12),
      ),
    ],
    todayGlow: [BoxShadow(color: Color(0x3091ACCE), blurRadius: 10)],
  );

  final AppColorTokens colors;
  final AppRadiusTokens radius;
  final AppSpacingTokens spacing;
  final AppShadowTokens shadows;
  final AppMotionTokens motion;
  final AppSizeTokens sizes;
  final AppVisualStyle visualStyle;
  final Color backgroundAccent;
  final Color surfaceHighlight;
  final double borderWidth;
  final double blurSigma;

  static AppTokens of(BuildContext context) =>
      Theme.of(context).extension<AppTokens>()!;

  @override
  AppTokens copyWith({
    AppColorTokens? colors,
    AppRadiusTokens? radius,
    AppSpacingTokens? spacing,
    AppShadowTokens? shadows,
    AppMotionTokens? motion,
    AppSizeTokens? sizes,
    AppVisualStyle? visualStyle,
    Color? backgroundAccent,
    Color? surfaceHighlight,
    double? borderWidth,
    double? blurSigma,
  }) => AppTokens(
    colors: colors ?? this.colors,
    radius: radius ?? this.radius,
    spacing: spacing ?? this.spacing,
    shadows: shadows ?? this.shadows,
    motion: motion ?? this.motion,
    sizes: sizes ?? this.sizes,
    visualStyle: visualStyle ?? this.visualStyle,
    backgroundAccent: backgroundAccent ?? this.backgroundAccent,
    surfaceHighlight: surfaceHighlight ?? this.surfaceHighlight,
    borderWidth: borderWidth ?? this.borderWidth,
    blurSigma: blurSigma ?? this.blurSigma,
  );

  @override
  AppTokens lerp(covariant AppTokens? other, double t) {
    if (other == null) {
      return this;
    }
    return AppTokens(
      colors: colors.lerp(other.colors, t),
      radius: radius.lerp(other.radius, t),
      spacing: spacing.lerp(other.spacing, t),
      shadows: shadows.lerp(other.shadows, t),
      motion: t < 0.5 ? motion : other.motion,
      sizes: sizes.lerp(other.sizes, t),
      visualStyle: t < 0.5 ? visualStyle : other.visualStyle,
      backgroundAccent: Color.lerp(
        backgroundAccent,
        other.backgroundAccent,
        t,
      )!,
      surfaceHighlight: Color.lerp(
        surfaceHighlight,
        other.surfaceHighlight,
        t,
      )!,
      borderWidth: lerpDouble(borderWidth, other.borderWidth, t)!,
      blurSigma: lerpDouble(blurSigma, other.blurSigma, t)!,
    );
  }
}

extension AppTokensBuildContext on BuildContext {
  AppTokens get tokens => AppTokens.of(this);
}
