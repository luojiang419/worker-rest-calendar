import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_rest_calendar/app/app_dependencies.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/core/widgets/app_state_view.dart';
import 'package:worker_rest_calendar/features/home/application/today_dashboard.dart';
import 'package:worker_rest_calendar/features/home/presentation/widgets/month_summary_card.dart';
import 'package:worker_rest_calendar/features/home/presentation/widgets/next_rest_countdown_card.dart';
import 'package:worker_rest_calendar/features/home/presentation/widgets/today_status_card.dart';
import 'package:worker_rest_calendar/features/home/presentation/widgets/week_rhythm_strip.dart';
import 'package:worker_rest_calendar/features/schedule/application/active_schedule_controller.dart';

class TodayPage extends ConsumerWidget {
  const TodayPage({
    required this.onEditToday,
    required this.onOpenDate,
    this.onOpenReminders,
    this.onOpenDataManagement,
    this.onOpenTheme,
    super.key,
  });

  final VoidCallback onEditToday;
  final ValueChanged<CalendarDate> onOpenDate;
  final VoidCallback? onOpenReminders;
  final VoidCallback? onOpenDataManagement;
  final VoidCallback? onOpenTheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedule = ref.watch(activeScheduleControllerProvider);
    final tokens = context.tokens;
    final horizontalPadding = MediaQuery.sizeOf(context).width >= 600
        ? tokens.sizes.desktopHorizontalPadding
        : tokens.sizes.mobileHorizontalPadding;
    return SafeArea(
      bottom: false,
      child: schedule.when(
        loading: () => const Center(child: AppLoadingState(label: '正在计算今天的安排')),
        error: (error, stackTrace) => Center(
          child: error is StateError
              ? const AppEmptyState(
                  title: '还没有设置班制',
                  message: '先选一个工作节奏，日历就会自动生成',
                )
              : AppErrorState(
                  title: '今日状态加载失败',
                  message: '请稍后重试',
                  onRetry: () =>
                      ref.invalidate(activeScheduleControllerProvider),
                ),
        ),
        data: (state) {
          final dashboard = TodayDashboard.build(
            state,
            ref.watch(todayProvider),
          );
          return LayoutBuilder(
            builder: (context, constraints) => RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(activeScheduleControllerProvider);
                await ref.read(activeScheduleControllerProvider.future);
              },
              child: ListView(
                key: ValueKey(constraints.maxWidth >= 900),
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  tokens.spacing.lg,
                  horizontalPadding,
                  tokens.spacing.xxl,
                ),
                children: [
                  _TodayHeader(
                    onOpenReminders: onOpenReminders,
                    onOpenDataManagement: onOpenDataManagement,
                    onOpenTheme: onOpenTheme,
                  ),
                  SizedBox(height: tokens.spacing.lg),
                  if (constraints.maxWidth >= 900)
                    _DesktopDashboard(
                      dashboard: dashboard,
                      onEditToday: onEditToday,
                      onOpenDate: onOpenDate,
                    )
                  else
                    _SingleColumnDashboard(
                      dashboard: dashboard,
                      onEditToday: onEditToday,
                      onOpenDate: onOpenDate,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TodayHeader extends StatelessWidget {
  const _TodayHeader({
    this.onOpenReminders,
    this.onOpenDataManagement,
    this.onOpenTheme,
  });

  final VoidCallback? onOpenReminders;
  final VoidCallback? onOpenDataManagement;
  final VoidCallback? onOpenTheme;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Row(
      children: [
        Expanded(
          child: Text(
            '今天',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        if (onOpenReminders != null)
          IconButton.outlined(
            tooltip: '提醒设置',
            onPressed: onOpenReminders,
            icon: const Icon(Icons.notifications_outlined),
          ),
        if (onOpenTheme != null) ...[
          SizedBox(width: tokens.spacing.sm),
          IconButton.outlined(
            tooltip: '选择主题',
            onPressed: onOpenTheme,
            icon: const Icon(Icons.palette_outlined),
          ),
        ],
        if (onOpenDataManagement != null) ...[
          SizedBox(width: tokens.spacing.sm),
          IconButton.outlined(
            tooltip: '数据与同步',
            onPressed: onOpenDataManagement,
            icon: const Icon(Icons.storage_outlined),
          ),
        ],
      ],
    );
  }
}

class _SingleColumnDashboard extends StatelessWidget {
  const _SingleColumnDashboard({
    required this.dashboard,
    required this.onEditToday,
    required this.onOpenDate,
  });

  final TodayDashboard dashboard;
  final VoidCallback onEditToday;
  final ValueChanged<CalendarDate> onOpenDate;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      children: [
        TodayStatusCard(day: dashboard.today, onEdit: onEditToday),
        SizedBox(height: tokens.spacing.lg),
        NextRestCountdownCard(
          daysToNextRest: dashboard.daysToNextRest,
          remainingWorkDays: dashboard.remainingWorkDaysBeforeNextRest,
          nextRestDate: dashboard.nextRestDate,
          onTap: () => onOpenDate(dashboard.nextRestDate),
        ),
        SizedBox(height: tokens.spacing.lg),
        WeekRhythmStrip(
          days: dashboard.weekDays,
          today: dashboard.today,
          onDayTap: (day) => onOpenDate(day.date),
        ),
        SizedBox(height: tokens.spacing.lg),
        MonthSummaryCard(summary: dashboard.monthSummary),
      ],
    );
  }
}

class _DesktopDashboard extends StatelessWidget {
  const _DesktopDashboard({
    required this.dashboard,
    required this.onEditToday,
    required this.onOpenDate,
  });

  final TodayDashboard dashboard;
  final VoidCallback onEditToday;
  final ValueChanged<CalendarDate> onOpenDate;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              TodayStatusCard(day: dashboard.today, onEdit: onEditToday),
              SizedBox(height: tokens.spacing.lg),
              NextRestCountdownCard(
                daysToNextRest: dashboard.daysToNextRest,
                remainingWorkDays: dashboard.remainingWorkDaysBeforeNextRest,
                nextRestDate: dashboard.nextRestDate,
                onTap: () => onOpenDate(dashboard.nextRestDate),
              ),
            ],
          ),
        ),
        SizedBox(width: tokens.spacing.lg),
        Expanded(
          child: Column(
            children: [
              WeekRhythmStrip(
                days: dashboard.weekDays,
                today: dashboard.today,
                onDayTap: (day) => onOpenDate(day.date),
              ),
              SizedBox(height: tokens.spacing.lg),
              MonthSummaryCard(summary: dashboard.monthSummary),
            ],
          ),
        ),
      ],
    );
  }
}
