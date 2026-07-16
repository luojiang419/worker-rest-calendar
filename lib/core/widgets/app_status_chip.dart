import 'package:flutter/material.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';

class AppStatusChip extends StatelessWidget {
  const AppStatusChip({required this.kind, super.key, this.compact = false});

  final DayKind kind;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final presentation = _presentation(tokens);
    return Semantics(
      label: presentation.label,
      excludeSemantics: true,
      child: Container(
        constraints: BoxConstraints(minHeight: tokens.sizes.minTouch),
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.md,
          vertical: tokens.spacing.sm,
        ),
        decoration: BoxDecoration(
          color: presentation.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(tokens.radius.pill),
          border: Border.all(color: presentation.color.withValues(alpha: 0.42)),
          boxShadow: tokens.shadows.low,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(presentation.icon, size: 16, color: presentation.color),
            SizedBox(width: tokens.spacing.xs),
            Text(
              compact ? presentation.shortLabel : presentation.label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: presentation.color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _StatusPresentation _presentation(AppTokens tokens) => switch (kind) {
    DayKind.work => _StatusPresentation(
      label: '工作',
      shortLabel: '班',
      icon: Icons.work_outline_rounded,
      color: tokens.colors.work,
    ),
    DayKind.rest => _StatusPresentation(
      label: '休息',
      shortLabel: '休',
      icon: Icons.weekend_outlined,
      color: tokens.colors.rest,
    ),
    DayKind.adjustedWork => _StatusPresentation(
      label: '调休上班',
      shortLabel: '调班',
      icon: Icons.event_busy_outlined,
      color: tokens.colors.adjustedWork,
    ),
    DayKind.adjustedRest => _StatusPresentation(
      label: '调休休息',
      shortLabel: '调休',
      icon: Icons.event_available_outlined,
      color: tokens.colors.adjustedRest,
    ),
    DayKind.leave => _StatusPresentation(
      label: '请假',
      shortLabel: '假',
      icon: Icons.beach_access_outlined,
      color: tokens.colors.leave,
    ),
  };
}

final class _StatusPresentation {
  const _StatusPresentation({
    required this.label,
    required this.shortLabel,
    required this.icon,
    required this.color,
  });

  final String label;
  final String shortLabel;
  final IconData icon;
  final Color color;
}
