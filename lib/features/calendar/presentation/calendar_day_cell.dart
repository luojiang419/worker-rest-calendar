import 'package:flutter/material.dart';
import 'package:worker_rest_calendar/core/date/date_labels.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/features/schedule/application/day_presentation.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_override.dart';
import 'package:worker_rest_calendar/features/schedule/presentation/day_visuals.dart';

class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.isInDisplayedMonth,
    required this.onTap,
    required this.onLongPress,
    super.key,
  });

  final DayPresentation day;
  final bool isToday;
  final bool isSelected;
  final bool isInDisplayedMonth;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final statusColor = dayKindColor(tokens, day.effectiveKind);
    final holidayTitle = day.appliedOverrideSource == DayOverrideSource.holiday
        ? day.note
        : null;
    final isRestDay = switch (day.effectiveKind) {
      DayKind.rest || DayKind.adjustedRest => true,
      _ => false,
    };
    final isHoliday = holidayTitle != null;
    final isEmphasized = isRestDay || isHoliday;
    final backgroundAlpha = isHoliday ? 0.18 : (isRestDay ? 0.14 : 0.06);
    final borderAlpha = isHoliday ? 0.58 : (isRestDay ? 0.44 : 0.24);
    final shadows = <BoxShadow>[
      if (isEmphasized) ...tokens.shadows.low,
      if (isToday) ...tokens.shadows.todayGlow,
    ];
    return Semantics(
      button: true,
      label:
          '${day.date.fullDateLabel}，${day.label}${holidayTitle == null ? '' : '，$holidayTitle'}${isToday ? '，今天' : ''}${day.hasManualOverride ? '，已手动调整' : ''}',
      child: Opacity(
        opacity: isInDisplayedMonth ? 1 : 0.48,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(tokens.radius.sm),
            child: AnimatedContainer(
              duration: tokens.motion.fast,
              padding: EdgeInsets.all(tokens.spacing.xs),
              decoration: BoxDecoration(
                color: isSelected
                    ? tokens.colors.primary.withValues(alpha: 0.12)
                    : statusColor.withValues(alpha: backgroundAlpha),
                borderRadius: BorderRadius.circular(tokens.radius.sm),
                border: Border.all(
                  color: isSelected
                      ? tokens.colors.primary
                      : statusColor.withValues(alpha: borderAlpha),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: shadows,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          day.date.day.toString(),
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        if (isToday)
                          Positioned(
                            left: 0,
                            child: Container(
                              width: tokens.spacing.sm,
                              height: tokens.spacing.sm,
                              decoration: BoxDecoration(
                                color: tokens.colors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: tokens.spacing.xs),
                  Text(
                    holidayTitle ?? day.shortLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (day.overtimeMinutes > 0)
                    Icon(
                      Icons.schedule_rounded,
                      size: tokens.spacing.md,
                      color: statusColor,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
