import 'package:flutter/material.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/core/widgets/app_button.dart';
import 'package:worker_rest_calendar/core/widgets/app_card.dart';
import 'package:worker_rest_calendar/features/onboarding/domain/onboarding_draft.dart';
import 'package:worker_rest_calendar/features/onboarding/domain/onboarding_preview.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_pattern.dart';

class OnboardingPreviewPage extends StatelessWidget {
  const OnboardingPreviewPage({
    required this.draft,
    required this.startDate,
    required this.onBack,
    required this.onComplete,
    super.key,
  });

  final OnboardingDraft draft;
  final CalendarDate startDate;
  final VoidCallback onBack;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final preview = buildOnboardingPreview(draft: draft, startDate: startDate);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(
          children: [
            SizedBox(height: tokens.spacing.lg),
            Row(
              children: [
                IconButton(
                  tooltip: '返回修改设置',
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '未来 30 天预览',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        _patternName(draft.patternType),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: tokens.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spacing.lg),
            Expanded(
              child: ListView(
                children: [
                  _ThirtyDayPreview(days: preview),
                  if (draft.patternType ==
                      SchedulePatternType.alternatingBigSmallWeek) ...[
                    SizedBox(height: tokens.spacing.xl),
                    _EightWeekPreview(
                      draft: draft,
                      startDate: startDate.monday,
                    ),
                  ],
                  SizedBox(height: tokens.spacing.xl),
                  AppCard(
                    shadowLevel: AppShadowLevel.low,
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: tokens.colors.primary,
                        ),
                        SizedBox(width: tokens.spacing.md),
                        const Expanded(child: Text('法定节假日和手动调整会在后续覆盖基础班制。')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: tokens.spacing.lg),
              child: AppButton.primary(
                label: '确认并进入今日',
                icon: Icons.check_rounded,
                expand: true,
                onPressed: onComplete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThirtyDayPreview extends StatelessWidget {
  const _ThirtyDayPreview({required this.days});

  final List<OnboardingPreviewDay> days;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return AppCard(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: tokens.spacing.sm,
        runSpacing: tokens.spacing.sm,
        children: days.map((day) => _PreviewDay(day: day)).toList(),
      ),
    );
  }
}

class _PreviewDay extends StatelessWidget {
  const _PreviewDay({required this.day});

  final OnboardingPreviewDay day;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isRest = day.kind == DayKind.rest;
    final color = isRest ? tokens.colors.rest : tokens.colors.work;
    return Semantics(
      label: '${day.date.month}月${day.date.day}日，${isRest ? '休息' : '工作'}',
      child: Container(
        width: tokens.sizes.minTouch + tokens.spacing.lg,
        constraints: BoxConstraints(minHeight: tokens.sizes.minTouch),
        padding: EdgeInsets.all(tokens.spacing.sm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(tokens.radius.sm),
          border: Border.all(color: color.withValues(alpha: 0.42)),
        ),
        child: Column(
          children: [
            Text('${day.date.month}/${day.date.day}'),
            Text(
              isRest ? '休' : '班',
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _EightWeekPreview extends StatelessWidget {
  const _EightWeekPreview({required this.draft, required this.startDate});

  final OnboardingDraft draft;
  final CalendarDate startDate;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final days = buildOnboardingPreview(
      draft: draft,
      startDate: startDate,
      dayCount: 56,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '连续 8 周交替检查',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        SizedBox(height: tokens.spacing.md),
        for (var week = 0; week < 8; week++) ...[
          _WeekRow(days: days.skip(week * 7).take(7).toList()),
          if (week < 7) SizedBox(height: tokens.spacing.sm),
        ],
      ],
    );
  }
}

class _WeekRow extends StatelessWidget {
  const _WeekRow({required this.days});

  final List<OnboardingPreviewDay> days;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final type = days.first.weekType!;
    final color = type == WeekType.big
        ? tokens.colors.rest
        : tokens.colors.adjustedWork;
    return AppCard(
      shadowLevel: AppShadowLevel.low,
      padding: EdgeInsets.all(tokens.spacing.md),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.spacing.md,
              vertical: tokens.spacing.sm,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(tokens.radius.pill),
            ),
            child: Text(
              type == WeekType.big ? '大周' : '小周',
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(width: tokens.spacing.md),
          Expanded(
            child: Text(
              '${days.first.date.month}/${days.first.date.day} – ${days.last.date.month}/${days.last.date.day}',
            ),
          ),
          Text(type == WeekType.big ? '周六休' : '周六班'),
        ],
      ),
    );
  }
}

String _patternName(SchedulePatternType? type) => switch (type) {
  SchedulePatternType.doubleRest => '双休',
  SchedulePatternType.singleRest => '单休',
  SchedulePatternType.alternatingBigSmallWeek => '大小周',
  SchedulePatternType.sixOnOneOff => '做六休一',
  SchedulePatternType.twoOnTwoOff => '做二休二',
  SchedulePatternType.customCycle => '自定义循环',
  null => '',
};
