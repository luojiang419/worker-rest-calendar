import 'package:flutter/material.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';

class WeekTypeBadge extends StatelessWidget {
  const WeekTypeBadge({required this.type, super.key});

  final WeekType type;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isBig = type == WeekType.big;
    final color = isBig ? tokens.colors.rest : tokens.colors.adjustedWork;
    final label = isBig ? '本周大周｜周六、周日休息' : '本周小周｜周六上班、周日休息';
    return Semantics(
      label: label,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.md,
          vertical: tokens.spacing.sm,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(tokens.radius.pill),
          border: Border.all(color: color.withValues(alpha: 0.42)),
        ),
        child: Text(
          isBig ? '本周大周' : '本周小周',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
