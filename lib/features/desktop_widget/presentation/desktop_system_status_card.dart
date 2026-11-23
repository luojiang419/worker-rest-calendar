import 'dart:async';

import 'package:flutter/material.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/features/desktop_widget/application/system_status_service.dart';
import 'package:worker_rest_calendar/features/desktop_widget/domain/system_status_snapshot.dart';
import 'package:worker_rest_calendar/features/desktop_widget/presentation/desktop_widget_frame.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

class DesktopSystemStatusCard extends StatefulWidget {
  const DesktopSystemStatusCard({
    required this.size,
    required this.service,
    this.refreshInterval = const Duration(seconds: 2),
    super.key,
  });

  final DesktopWidgetSize size;
  final SystemStatusService service;
  final Duration refreshInterval;

  @override
  State<DesktopSystemStatusCard> createState() =>
      _DesktopSystemStatusCardState();
}

class _DesktopSystemStatusCardState extends State<DesktopSystemStatusCard> {
  SystemStatusSnapshot? _snapshot;
  Timer? _timer;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
    _timer = Timer.periodic(widget.refreshInterval, (_) => _refresh());
  }

  @override
  void didUpdateWidget(covariant DesktopSystemStatusCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.service != widget.service) _refresh();
  }

  Future<void> _refresh() async {
    final value = await widget.service.read();
    if (mounted) {
      setState(() {
        _snapshot = value;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final compact = widget.size == DesktopWidgetSize.small;
    return DesktopWidgetFrame(
      size: widget.size,
      cardKey: ValueKey('desktop-systemStatus-card-${tokens.visualStyle.name}'),
      shadowSafeAreaKey: const ValueKey(
        'desktop-system-status-shadow-safe-area',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.monitor_heart_outlined, color: tokens.colors.primary),
              SizedBox(width: tokens.spacing.sm),
              Expanded(
                child: Text(
                  '系统状态',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                tooltip: '刷新',
                onPressed: _refresh,
                icon: const Icon(Icons.refresh_rounded, size: 18),
              ),
            ],
          ),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_snapshot == null)
            Expanded(
              child: Center(
                child: Text(
                  '当前平台暂不可读取',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: tokens.colors.textSecondary,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatusMeter(
                    label: 'CPU',
                    value: _snapshot!.cpuUsage,
                    color: tokens.colors.primary,
                    compact: compact,
                  ),
                  _StatusMeter(
                    label: '内存',
                    value: _snapshot!.memoryUsage,
                    color: tokens.colors.leave,
                    compact: compact,
                  ),
                  if (_snapshot!.batteryLevel != null)
                    _StatusMeter(
                      label: _snapshot!.isCharging == true ? '电池⚡' : '电池',
                      value: _snapshot!.batteryLevel!.toDouble(),
                      color: tokens.colors.rest,
                      compact: compact,
                    )
                  else if (!compact)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '台式设备 · 无电池',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.colors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusMeter extends StatelessWidget {
  const _StatusMeter({
    required this.label,
    required this.value,
    required this.color,
    required this.compact,
  });

  final String label;
  final double value;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final normalized = value.clamp(0, 100);
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: compact ? 42 : 54,
              child: Text(label, style: Theme.of(context).textTheme.bodySmall),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(context.tokens.radius.pill),
                child: LinearProgressIndicator(
                  value: normalized / 100,
                  minHeight: compact ? 6 : 8,
                  color: color,
                  backgroundColor: context.tokens.colors.surfaceElevated,
                ),
              ),
            ),
            SizedBox(width: context.tokens.spacing.sm),
            SizedBox(
              width: 36,
              child: Text(
                '${normalized.round()}%',
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
