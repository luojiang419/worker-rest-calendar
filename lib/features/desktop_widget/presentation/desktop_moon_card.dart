import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/features/desktop_widget/domain/moon_phase.dart';
import 'package:worker_rest_calendar/features/desktop_widget/presentation/desktop_widget_frame.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

class DesktopMoonCard extends StatefulWidget {
  const DesktopMoonCard({required this.size, this.now, super.key});

  final DesktopWidgetSize size;
  final DateTime Function()? now;

  @override
  State<DesktopMoonCard> createState() => _DesktopMoonCardState();
}

class _DesktopMoonCardState extends State<DesktopMoonCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(hours: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final now = (widget.now ?? DateTime.now)();
    final phase = MoonPhase.forDate(now);
    final compact = widget.size == DesktopWidgetSize.small;
    final diameter = compact
        ? 92.0
        : widget.size == DesktopWidgetSize.medium
        ? 132.0
        : 176.0;
    return DesktopWidgetFrame(
      size: widget.size,
      cardKey: ValueKey('desktop-moonPhase-card-${tokens.visualStyle.name}'),
      shadowSafeAreaKey: const ValueKey('desktop-moon-shadow-safe-area'),
      child: Semantics(
        label: '${phase.name.label}，照明 ${(phase.illumination * 100).round()}%',
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.nightlight_round, color: tokens.colors.adjustedWork),
                SizedBox(width: tokens.spacing.sm),
                Expanded(
                  child: Text(
                    '今夜月相',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${(phase.illumination * 100).round()}%',
                  key: const ValueKey('desktop-moon-illumination'),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: tokens.colors.textSecondary,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: Container(
                  width: diameter,
                  height: diameter,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: tokens.shadows.todayGlow,
                  ),
                  child: CustomPaint(
                    key: const ValueKey('desktop-moon-disc'),
                    painter: _MoonDiscPainter(
                      phase: phase.cycleFraction,
                      lightColor: tokens.colors.adjustedWork,
                      darkColor: tokens.colors.surfaceElevated,
                      craterColor: tokens.colors.textSecondary.withValues(
                        alpha: 0.18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Text(
              phase.name.label,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            if (!compact)
              Text(
                '月龄 ${phase.ageInDays.toStringAsFixed(1)} 天 · 距满月 ${phase.daysUntilNextFullMoon.ceil()} 天',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tokens.colors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MoonDiscPainter extends CustomPainter {
  const _MoonDiscPainter({
    required this.phase,
    required this.lightColor,
    required this.darkColor,
    required this.craterColor,
  });

  final double phase;
  final Color lightColor;
  final Color darkColor;
  final Color craterColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2;
    canvas.drawCircle(center, radius, Paint()..color = darkColor);
    final path = Path();
    const samples = 48;
    final terminator = math.cos(2 * math.pi * phase);
    for (var index = 0; index <= samples; index++) {
      final y = -radius + (2 * radius * index / samples);
      final outer = math.sqrt(math.max(0, radius * radius - y * y));
      final x = phase <= 0.5 ? outer : terminator * outer;
      final point = center + Offset(x, y);
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    for (var index = samples; index >= 0; index--) {
      final y = -radius + (2 * radius * index / samples);
      final outer = math.sqrt(math.max(0, radius * radius - y * y));
      final x = phase <= 0.5 ? terminator * outer : -outer;
      final point = center + Offset(x, y);
      path.lineTo(point.dx, point.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = lightColor);
    canvas.drawCircle(
      center + Offset(-radius * 0.24, -radius * 0.18),
      radius * 0.1,
      Paint()..color = craterColor,
    );
    canvas.drawCircle(
      center + Offset(radius * 0.2, radius * 0.28),
      radius * 0.07,
      Paint()..color = craterColor,
    );
  }

  @override
  bool shouldRepaint(covariant _MoonDiscPainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.lightColor != lightColor ||
      oldDelegate.darkColor != darkColor;
}
