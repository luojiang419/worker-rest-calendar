import 'package:flutter/material.dart';
import 'package:worker_rest_calendar/core/date/date_labels.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/core/widgets/app_button.dart';
import 'package:worker_rest_calendar/core/widgets/app_card.dart';
import 'package:worker_rest_calendar/features/home/presentation/widgets/week_type_badge.dart';
import 'package:worker_rest_calendar/features/schedule/application/day_presentation.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/schedule/presentation/day_visuals.dart';

class TodayStatusCard extends StatelessWidget {
  const TodayStatusCard({required this.day, required this.onEdit, super.key});

  final DayPresentation day;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = dayKindColor(tokens, day.effectiveKind);
    return AppCard(
      radius: tokens.radius.xl,
      padding: EdgeInsets.all(tokens.spacing.xl),
      semanticLabel:
          '${day.date.fullDateLabel}，${_todayLabel(day.effectiveKind)}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  day.date.fullDateLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: tokens.colors.textSecondary,
                  ),
                ),
              ),
              if (day.weekType case final type?) WeekTypeBadge(type: type),
            ],
          ),
          SizedBox(height: tokens.spacing.xl),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(tokens.spacing.lg),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(tokens.radius.xl),
                ),
                child: Icon(
                  dayKindIcon(day.effectiveKind),
                  color: color,
                  size: tokens.sizes.minTouch,
                ),
              ),
              SizedBox(width: tokens.spacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _todayLabel(day.effectiveKind),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800, color: color),
                    ),
                    if (day.overtimeMinutes > 0)
                      Text(
                        '已记录加班 ${day.overtimeMinutes} 分钟',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: tokens.colors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (day.note case final note?) ...[
            SizedBox(height: tokens.spacing.lg),
            Text(
              note,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: tokens.colors.textSecondary,
              ),
            ),
          ],
          SizedBox(height: tokens.spacing.xl),
          AppButton.secondary(
            label: '修改今天',
            icon: Icons.edit_outlined,
            expand: true,
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}

String _todayLabel(DayKind kind) => switch (kind) {
  DayKind.work => '今天上班',
  DayKind.rest => '今天休息',
  DayKind.adjustedWork => '今天调休上班',
  DayKind.adjustedRest => '今天调休休息',
  DayKind.leave => '今天请假',
};
