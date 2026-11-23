import 'package:flutter/material.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/core/widgets/app_card.dart';
import 'package:worker_rest_calendar/features/home/application/today_dashboard.dart';

class MonthSummaryCard extends StatelessWidget {
  const MonthSummaryCard({required this.summary, super.key});

  final MonthSummary summary;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final items = [
      _SummaryItem('工作', summary.workDays, tokens.colors.work),
      _SummaryItem('休息', summary.restDays, tokens.colors.rest),
      _SummaryItem('调休', summary.adjustedDays, tokens.colors.adjustedWork),
      _SummaryItem('请假', summary.leaveDays, tokens.colors.leave),
    ];
    return AppCard(
      semanticLabel: items
          .map((item) => '${item.label}${item.value}天')
          .join('，'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '本月概览',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: tokens.spacing.lg),
          Row(
            children: [
              for (final item in items)
                Expanded(child: _SummaryColumn(item: item)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  const _SummaryColumn({required this.item});

  final _SummaryItem item;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      children: [
        Text(
          item.label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: item.color),
        ),
        SizedBox(height: tokens.spacing.xs),
        Text(
          '${item.value}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: item.color,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          '天',
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: tokens.colors.textSecondary),
        ),
      ],
    );
  }
}

final class _SummaryItem {
  const _SummaryItem(this.label, this.value, this.color);

  final String label;
  final int value;
  final Color color;
}
