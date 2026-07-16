import 'dart:async';

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
    final time = '${_two(_current.hour)}:${_two(_current.minute)}';
    final seconds = _two(_current.second);
    final date = '${_current.month}月${_current.day}日';
    final weekday = _weekdays[_current.weekday - 1];
    final compact = widget.size == DesktopWidgetSize.small;
    return DesktopWidgetFrame(
      size: widget.size,
      cardKey: ValueKey('desktop-clock-card-${tokens.visualStyle.name}'),
      shadowSafeAreaKey: const ValueKey('desktop-clock-shadow-safe-area'),
      child: Semantics(
        label: '$time $seconds 秒，$date$weekday，${widget.snapshot.today.label}',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    '现在时间',
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
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                time,
                key: const ValueKey('desktop-clock-time'),
                maxLines: 1,
                style:
                    (compact
                            ? Theme.of(context).textTheme.displaySmall
                            : Theme.of(context).textTheme.displayLarge)
                        ?.copyWith(
                          color: tokens.colors.textPrimary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -2,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
              ),
            ),
            SizedBox(height: tokens.spacing.sm),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$date · $weekday',
                    key: const ValueKey('desktop-clock-date'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: tokens.colors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: tokens.spacing.sm,
                    vertical: tokens.spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(tokens.radius.pill),
                  ),
                  child: Text(
                    widget.snapshot.today.label,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (!compact) ...[
              SizedBox(height: tokens.spacing.sm),
              Text(
                '下次休息 ${widget.snapshot.nextRestDate.month}月${widget.snapshot.nextRestDate.day}日 · 还有${widget.snapshot.daysToNextRest}天',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tokens.colors.adjustedRest,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const Spacer(),
          ],
        ),
      ),
    );
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}

const _weekdays = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
