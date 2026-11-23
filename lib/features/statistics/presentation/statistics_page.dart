import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_rest_calendar/core/date/date_labels.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/core/widgets/app_button.dart';
import 'package:worker_rest_calendar/core/widgets/app_card.dart';
import 'package:worker_rest_calendar/core/widgets/app_state_view.dart';
import 'package:worker_rest_calendar/features/schedule/application/day_presentation.dart';
import 'package:worker_rest_calendar/features/schedule/presentation/day_visuals.dart';
import 'package:worker_rest_calendar/features/statistics/application/statistics_controller.dart';
import 'package:worker_rest_calendar/features/statistics/domain/schedule_statistics.dart';

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(statisticsDashboardProvider);
    final controller = ref.read(statisticsPeriodProvider.notifier);
    final tokens = context.tokens;
    final horizontalPadding = MediaQuery.sizeOf(context).width >= 600
        ? tokens.sizes.desktopHorizontalPadding
        : tokens.sizes.mobileHorizontalPadding;

    return SafeArea(
      bottom: false,
      child: dashboard.when(
        loading: () => const Center(child: AppLoadingState(label: '正在汇总统计')),
        error: (error, stackTrace) => const Center(
          child: AppErrorState(title: '统计加载失败', message: '请检查班制后重试'),
        ),
        data: (data) => _StatisticsContent(
          data: data,
          horizontalPadding: horizontalPadding,
          onCurrentMonth: controller.goCurrentMonth,
          onPreviousMonth: controller.previousMonth,
          onNextMonth: controller.nextMonth,
          onPreviousYear: controller.previousYear,
          onNextYear: controller.nextYear,
        ),
      ),
    );
  }
}

class _StatisticsContent extends StatelessWidget {
  const _StatisticsContent({
    required this.data,
    required this.horizontalPadding,
    required this.onCurrentMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onPreviousYear,
    required this.onNextYear,
  });

  final StatisticsDashboard data;
  final double horizontalPadding;
  final VoidCallback onCurrentMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onPreviousYear;
  final VoidCallback onNextYear;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compactDesktop =
            constraints.maxWidth >= 900 && constraints.maxHeight < 800;
        final verticalPadding = compactDesktop
            ? tokens.spacing.sm
            : tokens.spacing.lg;
        final bottomPadding = compactDesktop
            ? tokens.spacing.sm
            : tokens.spacing.xxl;
        final sectionGap = compactDesktop
            ? tokens.spacing.sm
            : tokens.spacing.lg;
        final overviewHeight = _monthlyOverviewHeight(context);
        final annualMinimumHeight =
            tokens.spacing.lg * 2 +
            tokens.sizes.minTouch +
            tokens.spacing.md +
            (tokens.spacing.md + tokens.spacing.xs) * 7 +
            tokens.spacing.sm +
            MediaQuery.textScalerOf(
              context,
            ).scale(Theme.of(context).textTheme.bodySmall?.fontSize ?? 12) +
            tokens.spacing.sm;
        final fixedHeight =
            verticalPadding +
            bottomPadding +
            tokens.sizes.buttonHeight * 2 +
            sectionGap * 3;
        final useDesktopDashboard =
            constraints.maxWidth >= 900 &&
            constraints.maxHeight >=
                fixedHeight + overviewHeight + annualMinimumHeight;
        final header = _buildHeader(context);
        final periodHeader = _PeriodHeader(
          label: '${data.period.year}年${data.period.month}月',
          onPrevious: onPreviousMonth,
          onNext: onNextMonth,
        );

        if (!useDesktopDashboard) {
          return ListView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              verticalPadding,
              horizontalPadding,
              bottomPadding,
            ),
            children: [
              header,
              SizedBox(height: sectionGap),
              periodHeader,
              SizedBox(height: sectionGap),
              _MonthlyOverview(statistics: data.monthly),
              SizedBox(height: sectionGap),
              _StreakCard(data: data),
              SizedBox(height: sectionGap),
              _AnnualHeatmapCard(
                heatmap: data.heatmap,
                onPreviousYear: onPreviousYear,
                onNextYear: onNextYear,
              ),
            ],
          );
        }

        return Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            verticalPadding,
            horizontalPadding,
            bottomPadding,
          ),
          child: Column(
            children: [
              header,
              SizedBox(height: sectionGap),
              periodHeader,
              SizedBox(height: sectionGap),
              SizedBox(
                height: overviewHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _MonthlyOverview(statistics: data.monthly),
                    ),
                    SizedBox(width: sectionGap),
                    Expanded(child: _StreakCard(data: data)),
                  ],
                ),
              ),
              SizedBox(height: sectionGap),
              Expanded(
                child: _AnnualHeatmapCard(
                  heatmap: data.heatmap,
                  onPreviousYear: onPreviousYear,
                  onNextYear: onNextYear,
                  fillAvailableHeight: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          '统计',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      AppButton.secondary(label: '本月', onPressed: onCurrentMonth),
    ],
  );

  double _monthlyOverviewHeight(BuildContext context) {
    final tokens = context.tokens;
    final scaler = MediaQuery.textScalerOf(context);
    final metricExtent = scaler.scale(
      tokens.sizes.minTouch + tokens.spacing.xl,
    );
    final titleExtent =
        scaler.scale(Theme.of(context).textTheme.titleMedium?.fontSize ?? 16) +
        tokens.spacing.sm;
    return tokens.spacing.lg * 2 +
        titleExtent +
        tokens.spacing.lg +
        metricExtent * 2 +
        tokens.spacing.sm +
        tokens.spacing.xs;
  }
}

class _PeriodHeader extends StatelessWidget {
  const _PeriodHeader({
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton.outlined(
        tooltip: '上个月',
        onPressed: onPrevious,
        icon: const Icon(Icons.chevron_left_rounded),
      ),
      Expanded(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      IconButton.outlined(
        tooltip: '下个月',
        onPressed: onNext,
        icon: const Icon(Icons.chevron_right_rounded),
      ),
    ],
  );
}

class _MonthlyOverview extends StatelessWidget {
  const _MonthlyOverview({required this.statistics});

  final MonthlyScheduleStatistics statistics;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final items = [
      _Metric('计划工作', statistics.plannedWorkDays, tokens.colors.work),
      _Metric('实际工作', statistics.actualWorkDays, tokens.colors.primary),
      _Metric('休息', statistics.restDays, tokens.colors.rest),
      _Metric('请假', statistics.leaveDays, tokens.colors.leave),
      _Metric('调休上班', statistics.adjustedWorkDays, tokens.colors.adjustedWork),
      _Metric('调休休息', statistics.adjustedRestDays, tokens.colors.adjustedRest),
    ];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '月度概览',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: tokens.spacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 560 ? 3 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisExtent: MediaQuery.textScalerOf(
                    context,
                  ).scale(tokens.sizes.minTouch + tokens.spacing.xl),
                  crossAxisSpacing: tokens.spacing.sm,
                  mainAxisSpacing: tokens.spacing.sm,
                ),
                itemBuilder: (context, index) => _MetricTile(items[index]),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile(this.metric);

  final _Metric metric;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Semantics(
      label: '${metric.label}${metric.value}天',
      child: Container(
        padding: EdgeInsets.all(tokens.spacing.md),
        decoration: BoxDecoration(
          color: metric.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(tokens.radius.md),
          border: Border.all(color: metric.color.withValues(alpha: 0.32)),
        ),
        child: Row(
          children: [
            Expanded(child: Text(metric.label)),
            Text(
              '${metric.value}天',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: metric.color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.data});

  final StatisticsDashboard data;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '连续工作',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: tokens.spacing.lg),
          _StreakRow(
            label: '截至今天',
            planned: data.currentStreak.plannedDays,
            actual: data.currentStreak.actualDays,
          ),
          Divider(color: tokens.colors.border),
          _StreakRow(
            label: '本月最长',
            planned: data.monthly.longestPlannedWorkStreak,
            actual: data.monthly.longestActualWorkStreak,
          ),
        ],
      ),
    );
  }
}

class _StreakRow extends StatelessWidget {
  const _StreakRow({
    required this.label,
    required this.planned,
    required this.actual,
  });

  final String label;
  final int planned;
  final int actual;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: context.tokens.spacing.sm),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text('计划 $planned 天'),
        SizedBox(width: context.tokens.spacing.lg),
        Text(
          '实际 $actual 天',
          style: TextStyle(
            color: context.tokens.colors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _AnnualHeatmapCard extends StatelessWidget {
  const _AnnualHeatmapCard({
    required this.heatmap,
    required this.onPreviousYear,
    required this.onNextYear,
    this.fillAvailableHeight = false,
  });

  final AnnualScheduleHeatmap heatmap;
  final VoidCallback onPreviousYear;
  final VoidCallback onNextYear;
  final bool fillAvailableHeight;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final leadingEmpty = heatmap.days.first.date.weekday - 1;
    final cells = <ScheduleHeatmapDay?>[
      ...List.filled(leadingEmpty, null),
      ...heatmap.days,
    ];
    final columnCount = (cells.length / 7).ceil();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${heatmap.year} 年度节奏',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: '上一年',
                onPressed: onPreviousYear,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              IconButton(
                tooltip: '下一年',
                onPressed: onNextYear,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.md),
          if (fillAvailableHeight) const Spacer(),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var column = 0; column < columnCount; column++)
                  Padding(
                    padding: EdgeInsets.only(right: tokens.spacing.xs),
                    child: Column(
                      children: [
                        for (var row = 0; row < 7; row++)
                          Padding(
                            padding: EdgeInsets.only(bottom: tokens.spacing.xs),
                            child: _HeatmapCell(
                              day: column * 7 + row < cells.length
                                  ? cells[column * 7 + row]
                                  : null,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (fillAvailableHeight) const Spacer(),
          SizedBox(height: tokens.spacing.sm),
          Text(
            '颜色分别表示工作、休息、调休与请假；每格对应一天。',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: tokens.colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _HeatmapCell extends StatelessWidget {
  const _HeatmapCell({required this.day});

  final ScheduleHeatmapDay? day;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final value = day;
    if (value == null) {
      return SizedBox.square(dimension: tokens.spacing.md);
    }
    final color = dayKindColor(tokens, value.effectiveKind);
    return Semantics(
      label: '${value.date.fullDateLabel}，${value.effectiveKind.fullLabel}',
      child: Tooltip(
        message: value.date.fullDateLabel,
        child: Container(
          width: tokens.spacing.md,
          height: tokens.spacing.md,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(tokens.radius.xs / 2),
          ),
        ),
      ),
    );
  }
}

final class _Metric {
  const _Metric(this.label, this.value, this.color);

  final String label;
  final int value;
  final Color color;
}
