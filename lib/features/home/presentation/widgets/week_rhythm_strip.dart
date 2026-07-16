import 'package:flutter/material.dart';
import 'package:worker_rest_calendar/core/date/date_labels.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/core/widgets/app_card.dart';
import 'package:worker_rest_calendar/features/schedule/application/day_presentation.dart';
import 'package:worker_rest_calendar/features/schedule/presentation/day_visuals.dart';

class WeekRhythmStrip extends StatelessWidget {
  const WeekRhythmStrip({
    required this.days,
    required this.today,
    required this.onDayTap,
    super.key,
  });

  final List<DayPresentation> days;
  final DayPresentation today;
  final ValueChanged<DayPresentation> onDayTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '本周节奏',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: tokens.spacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 360) {
                final gap = tokens.spacing.xs;
                final itemWidth = (constraints.maxWidth - gap * 3) / 4;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final day in days)
                      SizedBox(
                        width: itemWidth,
                        child: _WeekDay(
                          day: day,
                          isToday: day.date == today.date,
                          onTap: () => onDayTap(day),
                        ),
                      ),
                  ],
                );
              }
              return Row(
                children: [
                  for (final day in days)
                    Expanded(
                      child: _WeekDay(
                        day: day,
                        isToday: day.date == today.date,
                        onTap: () => onDayTap(day),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WeekDay extends StatelessWidget {
  const _WeekDay({
    required this.day,
    required this.isToday,
    required this.onTap,
  });

  final DayPresentation day;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = dayKindColor(tokens, day.effectiveKind);
    return Semantics(
      button: true,
      label: '${day.date.fullDateLabel}，${day.label}${isToday ? '，今天' : ''}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radius.sm),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: tokens.spacing.sm),
          child: Column(
            children: [
              Text(
                day.date.weekdayShortLabel,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: tokens.colors.textSecondary,
                ),
              ),
              SizedBox(height: tokens.spacing.sm),
              Container(
                constraints: BoxConstraints(
                  minWidth: tokens.sizes.minTouch,
                  minHeight: tokens.sizes.minTouch,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isToday
                      ? tokens.colors.primary
                      : color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(tokens.radius.pill),
                  border: Border.all(
                    color: isToday
                        ? tokens.colors.primary
                        : color.withValues(alpha: 0.42),
                  ),
                ),
                child: Text(
                  day.date.day.toString(),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isToday ? tokens.colors.surface : color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(height: tokens.spacing.xs),
              Text(
                day.shortLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
