import 'package:flutter/material.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/core/date/date_labels.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/core/widgets/app_card.dart';

class NextRestCountdownCard extends StatelessWidget {
  const NextRestCountdownCard({
    required this.daysToNextRest,
    required this.remainingWorkDays,
    required this.nextRestDate,
    required this.onTap,
    super.key,
  });

  final int daysToNextRest;
  final int remainingWorkDays;
  final CalendarDate nextRestDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final countdown = daysToNextRest == 0
        ? '今天就是休息日'
        : remainingWorkDays == 1
        ? '再上 1 天班'
        : '再上 $remainingWorkDays 天班';
    return AppCard(
      onTap: onTap,
      semanticLabel: '$countdown，下次休息${nextRestDate.fullDateLabel}',
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(tokens.spacing.md),
            decoration: BoxDecoration(
              color: tokens.colors.rest.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(tokens.radius.lg),
            ),
            child: Icon(
              Icons.hourglass_bottom_rounded,
              color: tokens.colors.rest,
            ),
          ),
          SizedBox(width: tokens.spacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  countdown,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                SizedBox(height: tokens.spacing.xs),
                Text(
                  '下次休息：${nextRestDate.monthDayLabel} ${nextRestDate.weekdayLabel}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: tokens.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: tokens.colors.textSecondary),
        ],
      ),
    );
  }
}
