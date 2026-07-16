import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/core/theme/app_visual_style.dart';

void main() {
  test('Dart 令牌与 design_tokens.json 保持一致', () {
    final json =
        jsonDecode(File('config/design_tokens.json').readAsStringSync())
            as Map<String, dynamic>;

    _expectThemeColors(
      AppTokens.light.colors,
      (json['colors'] as Map<String, dynamic>)['light'] as Map<String, dynamic>,
    );
    _expectThemeColors(
      AppTokens.dark.colors,
      (json['colors'] as Map<String, dynamic>)['dark'] as Map<String, dynamic>,
    );

    final radius = json['radius'] as Map<String, dynamic>;
    expect(AppTokens.light.radius.xs, radius['xs']);
    expect(AppTokens.light.radius.sm, radius['sm']);
    expect(AppTokens.light.radius.md, radius['md']);
    expect(AppTokens.light.radius.lg, radius['lg']);
    expect(AppTokens.light.radius.xl, radius['xl']);
    expect(AppTokens.light.radius.sheet, radius['sheet']);
    expect(AppTokens.light.radius.pill, radius['pill']);

    final spacing = json['spacing'] as Map<String, dynamic>;
    expect(AppTokens.light.spacing.xs, spacing['xs']);
    expect(AppTokens.light.spacing.sm, spacing['sm']);
    expect(AppTokens.light.spacing.md, spacing['md']);
    expect(AppTokens.light.spacing.lg, spacing['lg']);
    expect(AppTokens.light.spacing.xl, spacing['xl']);
    expect(AppTokens.light.spacing.xxl, spacing['xxl']);

    final motion = json['motion'] as Map<String, dynamic>;
    expect(AppTokens.light.motion.fast.inMilliseconds, motion['fastMs']);
    expect(AppTokens.light.motion.normal.inMilliseconds, motion['normalMs']);
    expect(AppTokens.light.motion.sheet.inMilliseconds, motion['sheetMs']);

    final sizes = json['sizes'] as Map<String, dynamic>;
    expect(AppTokens.light.sizes.minTouch, sizes['minTouch']);
    expect(AppTokens.light.sizes.buttonHeight, sizes['buttonHeight']);
    expect(
      AppTokens.light.sizes.mobileHorizontalPadding,
      sizes['mobileHorizontalPadding'],
    );
    expect(
      AppTokens.light.sizes.desktopHorizontalPadding,
      sizes['desktopHorizontalPadding'],
    );

    _expectShadows(
      AppTokens.light.shadows,
      (json['shadow'] as Map<String, dynamic>)['light'] as Map<String, dynamic>,
    );

    final visualStyles = json['visualStyles'] as Map<String, dynamic>;
    for (final style in AppVisualStyle.values.where(
      (style) => style != AppVisualStyle.classic,
    )) {
      final styleJson = visualStyles[style.name] as Map<String, dynamic>;
      _expectThemeColors(
        AppTokens.resolve(style, Brightness.light).colors,
        styleJson['light'] as Map<String, dynamic>,
      );
      _expectThemeColors(
        AppTokens.resolve(style, Brightness.dark).colors,
        styleJson['dark'] as Map<String, dynamic>,
      );
    }
    _expectShadows(
      AppTokens.dark.shadows,
      (json['shadow'] as Map<String, dynamic>)['dark'] as Map<String, dynamic>,
    );
  });

  test('浅色与暗黑使用不同表面和阴影', () {
    expect(
      AppTokens.light.colors.background,
      isNot(AppTokens.dark.colors.background),
    );
    expect(
      AppTokens.light.shadows.medium.first.color,
      isNot(AppTokens.dark.shadows.medium.first.color),
    );
  });

  test('视觉风格具有可辨识的材质特征', () {
    final flat = AppTokens.resolve(AppVisualStyle.flat, Brightness.light);
    final neumorphic = AppTokens.resolve(
      AppVisualStyle.neumorphic,
      Brightness.light,
    );
    final glass = AppTokens.resolve(AppVisualStyle.glass, Brightness.dark);
    final paper = AppTokens.resolve(AppVisualStyle.paper, Brightness.light);

    expect(flat.shadows.medium, isEmpty);
    expect(neumorphic.shadows.medium, hasLength(2));
    expect(neumorphic.borderWidth, 0);
    expect(glass.blurSigma, greaterThan(0));
    expect(glass.colors.surface.a, lessThan(1));
    expect(paper.radius.lg, lessThan(AppTokens.light.radius.lg));
  });
}

void _expectThemeColors(AppColorTokens actual, Map<String, dynamic> expected) {
  final colors = {
    'background': actual.background,
    'surface': actual.surface,
    'surfaceElevated': actual.surfaceElevated,
    'textPrimary': actual.textPrimary,
    'textSecondary': actual.textSecondary,
    'border': actual.border,
    'primary': actual.primary,
    'work': actual.work,
    'rest': actual.rest,
    'adjustedWork': actual.adjustedWork,
    'adjustedRest': actual.adjustedRest,
    'leave': actual.leave,
    'danger': actual.danger,
  };
  for (final entry in colors.entries) {
    expect(
      entry.value.toARGB32(),
      _parseColor(expected[entry.key] as String).toARGB32(),
      reason: entry.key,
    );
  }
}

void _expectShadows(AppShadowTokens actual, Map<String, dynamic> expected) {
  final levels = {
    'low': actual.low,
    'medium': actual.medium,
    'high': actual.high,
  };
  for (final entry in levels.entries) {
    final expectedList = (expected[entry.key] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    expect(entry.value, hasLength(expectedList.length));
    for (var index = 0; index < expectedList.length; index++) {
      final shadow = entry.value[index];
      final json = expectedList[index];
      expect(
        shadow.offset,
        Offset((json['x'] as num).toDouble(), (json['y'] as num).toDouble()),
      );
      expect(shadow.blurRadius, json['blur']);
      expect(shadow.spreadRadius, json['spread']);
      expect(
        shadow.color.toARGB32(),
        _parseColor(json['color'] as String).toARGB32(),
      );
    }
  }
}

Color _parseColor(String value) {
  if (value.startsWith('#')) {
    return Color(int.parse(value.substring(1), radix: 16) | 0xFF000000);
  }
  final match = RegExp(
    r'^rgba\((\d+),(\d+),(\d+),([\d.]+)\)$',
  ).firstMatch(value);
  if (match == null) {
    throw FormatException('无法解析颜色', value);
  }
  return Color.fromRGBO(
    int.parse(match.group(1)!),
    int.parse(match.group(2)!),
    int.parse(match.group(3)!),
    double.parse(match.group(4)!),
  );
}
