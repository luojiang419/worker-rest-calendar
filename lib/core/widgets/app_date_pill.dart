import 'package:flutter/material.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/core/widgets/app_status_chip.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';

class AppDatePill extends StatelessWidget {
  const AppDatePill({
    required this.date,
    required this.kind,
    super.key,
    this.selected = false,
    this.onTap,
  });

  final CalendarDate date;
  final DayKind kind;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final borderRadius = BorderRadius.circular(tokens.radius.md);
    final content = AnimatedContainer(
      duration: tokens.motion.normal,
      constraints: BoxConstraints(
        minWidth: tokens.sizes.minTouch,
        minHeight: 76,
      ),
      padding: EdgeInsets.all(tokens.spacing.sm),
      decoration: BoxDecoration(
        color: selected
            ? tokens.colors.primary.withValues(alpha: 0.12)
            : tokens.colors.surface,
        borderRadius: borderRadius,
        border: Border.all(
          color: selected ? tokens.colors.primary : tokens.colors.border,
        ),
        boxShadow: selected ? tokens.shadows.medium : tokens.shadows.low,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${date.month}月${date.day}日',
            maxLines: 1,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: selected
                  ? tokens.colors.primary
                  : tokens.colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: tokens.spacing.xs),
          AppStatusChip(kind: kind, compact: true),
        ],
      ),
    );

    return Semantics(
      button: onTap != null,
      selected: selected,
      label: '${date.month}月${date.day}日',
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
