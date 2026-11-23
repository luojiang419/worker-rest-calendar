import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/features/desktop_widget/domain/desktop_widget_snapshot.dart';
import 'package:worker_rest_calendar/features/desktop_widget/presentation/desktop_widget_frame.dart';
import 'package:worker_rest_calendar/features/schedule/presentation/day_visuals.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

class DesktopClockCard extends StatefulWidget {
  const DesktopClockCard({
    required this.snapshot,
    required this.size,
    this.now,
    this.tickInterval = const Duration(seconds: 1),
    super.key,
  });

  final DesktopWidgetSnapshot snapshot;
  final DesktopWidgetSize size;
  final DateTime Function()? now;
  final Duration tickInterval;

  @override
  State<DesktopClockCard> createState() => _DesktopClockCardState();
}

class _DesktopClockCardState extends State<DesktopClockCard>
    with WidgetsBindingObserver {
  late DateTime _current;
  Timer? _timer;

  DateTime get _now => (widget.now ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _current = _now;
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant DesktopClockCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tickInterval != widget.tickInterval ||
        oldWidget.now != widget.now) {
      _current = _now;
      _startTimer();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.tickInterval, (_) => _refresh());
  }

  void _refresh() {
    if (mounted) setState(() => _current = _now);
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final statusColor = dayKindColor(
      tokens,
      widget.snapshot.today.effectiveKind,
    );
    final compact = widget.size == DesktopWidgetSize.small;
    final time = '${_two(_current.hour)}:${_two(_current.minute)}';
    final seconds = _two(_current.second);
    final date = '${_current.month}月${_current.day}日';
    final weekday = _weekdays[_current.weekday - 1];
    return DesktopWidgetFrame(
      size: widget.size,
      cardKey: ValueKey('desktop-clock-card-${tokens.visualStyle.name}'),
      shadowSafeAreaKey: const ValueKey('desktop-clock-shadow-safe-area'),
      child: Semantics(
        label: '$time $seconds 秒，$date$weekday，${widget.snapshot.today.label}',
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: tokens.spacing.sm),
                Expanded(
                  child: Text(
                    '模拟时钟',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  seconds,
                  key: const ValueKey('desktop-clock-seconds'),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: tokens.colors.textSecondary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spacing.xs),
            Expanded(
              child: compact
                  ? _ClockFace(current: _current)
                  : Row(
                      children: [
                        Expanded(flex: 5, child: _ClockFace(current: _current)),
                        SizedBox(width: tokens.spacing.md),
                        Expanded(
                          flex: 4,
                          child: _ClockDetails(
                            time: time,
                            date: date,
                            weekday: weekday,
                            statusLabel: widget.snapshot.today.label,
                            statusColor: statusColor,
                            nextRestLabel:
                                '${widget.snapshot.nextRestDate.month}月${widget.snapshot.nextRestDate.day}日休息',
                          ),
                        ),
                      ],
                    ),
            ),
            if (compact)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '$date · $weekday',
                      key: const ValueKey('desktop-clock-date'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: tokens.colors.textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    time,
                    key: const ValueKey('desktop-clock-time'),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}

class _ClockFace extends StatelessWidget {
  const _ClockFace({required this.current});

  final DateTime current;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return LayoutBuilder(
      builder: (context, constraints) {
        final diameter = math.min(constraints.maxWidth, constraints.maxHeight);
        return Center(
          child: Container(
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.35, -0.4),
                colors: [tokens.colors.surfaceElevated, tokens.colors.surface],
              ),
              boxShadow: [
                ...tokens.shadows.medium,
                BoxShadow(
                  color: tokens.surfaceHighlight,
                  blurRadius: tokens.spacing.sm,
                  offset: Offset(-tokens.spacing.xs, -tokens.spacing.xs),
                ),
              ],
            ),
            child: CustomPaint(
              key: const ValueKey('desktop-analog-clock-face'),
              painter: _AnalogClockPainter(
                current: current,
                tickColor: tokens.colors.textSecondary,
                hourHandColor: tokens.colors.textPrimary,
                minuteHandColor: tokens.colors.primary,
                secondHandColor: tokens.colors.adjustedWork,
                centerColor: tokens.colors.surfaceElevated,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ClockDetails extends StatelessWidget {
  const _ClockDetails({
    required this.time,
    required this.date,
    required this.weekday,
    required this.statusLabel,
    required this.statusColor,
    required this.nextRestLabel,
  });

  final String time;
  final String date;
  final String weekday;
  final String statusLabel;
  final Color statusColor;
  final String nextRestLabel;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      FittedBox(
        child: Text(
          time,
          key: const ValueKey('desktop-clock-time'),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
      SizedBox(height: context.tokens.spacing.sm),
      Text(
        '$date · $weekday',
        key: const ValueKey('desktop-clock-date'),
        maxLines: 1,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: context.tokens.colors.textSecondary,
        ),
      ),
      SizedBox(height: context.tokens.spacing.sm),
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.tokens.spacing.sm,
          vertical: context.tokens.spacing.xs,
        ),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(context.tokens.radius.pill),
        ),
        child: Text(
          statusLabel,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: statusColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      SizedBox(height: context.tokens.spacing.xs),
      Text(
        nextRestLabel,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: context.tokens.colors.adjustedRest,
        ),
      ),
    ],
  );
}

class _AnalogClockPainter extends CustomPainter {
  const _AnalogClockPainter({
    required this.current,
    required this.tickColor,
    required this.hourHandColor,
    required this.minuteHandColor,
    required this.secondHandColor,
    required this.centerColor,
  });

  final DateTime current;
  final Color tickColor;
  final Color hourHandColor;
  final Color minuteHandColor;
  final Color secondHandColor;
  final Color centerColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2;
    for (var index = 0; index < 60; index++) {
      final major = index % 5 == 0;
      final angle = index * math.pi / 30 - math.pi / 2;
      final outer =
          center + Offset(math.cos(angle), math.sin(angle)) * (radius * 0.86);
      final inner =
          center +
          Offset(math.cos(angle), math.sin(angle)) *
              (radius * (major ? 0.72 : 0.79));
      canvas.drawLine(
        inner,
        outer,
        Paint()
          ..color = tickColor.withValues(alpha: major ? 0.9 : 0.42)
          ..strokeWidth = major ? radius * 0.026 : radius * 0.011
          ..strokeCap = StrokeCap.round,
      );
    }
    final hourAngle =
        ((current.hour % 12) + current.minute / 60) * math.pi / 6 - math.pi / 2;
    final minuteAngle =
        (current.minute + current.second / 60) * math.pi / 30 - math.pi / 2;
    final secondAngle = current.second * math.pi / 30 - math.pi / 2;
    _hand(
      canvas,
      center,
      hourAngle,
      radius * 0.43,
      radius * 0.055,
      hourHandColor,
    );
    _hand(
      canvas,
      center,
      minuteAngle,
      radius * 0.62,
      radius * 0.038,
      minuteHandColor,
    );
    _hand(
      canvas,
      center,
      secondAngle,
      radius * 0.69,
      radius * 0.018,
      secondHandColor,
    );
    canvas.drawCircle(center, radius * 0.07, Paint()..color = centerColor);
    canvas.drawCircle(center, radius * 0.035, Paint()..color = secondHandColor);
  }

  void _hand(
    Canvas canvas,
    Offset center,
    double angle,
    double length,
    double width,
    Color color,
  ) {
    final endpoint = center + Offset(math.cos(angle), math.sin(angle)) * length;
    canvas.drawLine(
      center,
      endpoint,
      Paint()
        ..color = color
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _AnalogClockPainter oldDelegate) =>
      oldDelegate.current != current ||
      oldDelegate.tickColor != tickColor ||
      oldDelegate.minuteHandColor != minuteHandColor;
}

const _weekdays = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
