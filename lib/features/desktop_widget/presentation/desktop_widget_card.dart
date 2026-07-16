import 'package:flutter/material.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/core/theme/app_visual_style.dart';
import 'package:worker_rest_calendar/core/widgets/app_card.dart';
import 'package:worker_rest_calendar/features/desktop_widget/domain/desktop_widget_snapshot.dart';
import 'package:worker_rest_calendar/features/desktop_widget/presentation/desktop_widget_date_surface.dart';
import 'package:worker_rest_calendar/features/schedule/application/day_presentation.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/schedule/presentation/day_visuals.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

class DesktopWidgetCard extends StatelessWidget {
  const DesktopWidgetCard({
    required this.snapshot,
    required this.size,
    required this.onOpenDate,
    this.largeDateShape = DesktopWidgetLargeDateShape.roundedRectangle,
    this.todayHighlightStyle = DesktopWidgetTodayHighlightStyle.glowOutline,
    super.key,
  });

  final DesktopWidgetSnapshot snapshot;
  final DesktopWidgetSize size;
  final DesktopWidgetLargeDateShape largeDateShape;
  final DesktopWidgetTodayHighlightStyle todayHighlightStyle;
  final ValueChanged<DayPresentation> onOpenDate;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final desktopShadows = tokens.shadows.medium.isEmpty
        ? AppTokens.resolve(
            AppVisualStyle.classic,
            Theme.of(context).brightness,
          ).shadows.medium
        : tokens.shadows.medium;
    return Material(
      type: MaterialType.transparency,
      child: Padding(
        key: const ValueKey('desktop-widget-shadow-safe-area'),
        padding: const EdgeInsets.all(8),
        child: AppCard(
          key: ValueKey('desktop-widget-card-${tokens.visualStyle.name}'),
          showBorder: false,
          boxShadow: desktopShadows,
          padding: EdgeInsets.all(
            size == DesktopWidgetSize.large
                ? tokens.spacing.md
                : tokens.spacing.sm + tokens.spacing.xs,
          ),
          child: switch (size) {
            DesktopWidgetSize.small => _SmallSnapshot(snapshot: snapshot),
            DesktopWidgetSize.medium => _MediumSnapshot(
              snapshot: snapshot,
              todayHighlightStyle: todayHighlightStyle,
            ),
            DesktopWidgetSize.large => _LargeSnapshot(
              snapshot: snapshot,
              dateShape: largeDateShape,
              todayHighlightStyle: todayHighlightStyle,
              onOpenDate: onOpenDate,
            ),
          },
        ),
      ),
    );
  }
}

class _SmallSnapshot extends StatelessWidget {
  const _SmallSnapshot({required this.snapshot});

  final DesktopWidgetSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final statusColor = dayKindColor(tokens, snapshot.today.effectiveKind);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(label: '今日状态', color: statusColor),
        const Spacer(),
        _SmallMetricSurface(
          surfaceKey: const ValueKey('desktop-widget-small-status-surface'),
          child: Text(
            snapshot.today.label,
            maxLines: 1,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(height: tokens.spacing.md),
        Text('距离休息还有', style: Theme.of(context).textTheme.bodySmall),
        SizedBox(height: tokens.spacing.xs),
        _SmallMetricSurface(
          surfaceKey: const ValueKey('desktop-widget-small-countdown-surface'),
          child: Text(
            '${snapshot.daysToNextRest}天',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: tokens.colors.adjustedRest,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Spacer(),
        Text(
          '下次休息 ${snapshot.nextRestDate.month}月${snapshot.nextRestDate.day}日',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: tokens.colors.textSecondary),
        ),
      ],
    );
  }
}

class _MediumSnapshot extends StatelessWidget {
  const _MediumSnapshot({
    required this.snapshot,
    required this.todayHighlightStyle,
  });

  final DesktopWidgetSnapshot snapshot;
  final DesktopWidgetTodayHighlightStyle todayHighlightStyle;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final weekLabel = switch (snapshot.currentWeekType) {
      WeekType.big => '大周 · 双休',
      WeekType.small => '小周 · 周日休',
      null => '循环班制',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(label: '本周节奏'),
        SizedBox(height: tokens.spacing.sm),
        Text(
          '本周：$weekLabel',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: tokens.spacing.xs),
        Text(
          '本周还要再上${snapshot.remainingWeekWorkDays}天班',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: tokens.colors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Row(
          children: List.generate(7, (index) {
            final day = snapshot.weekDays[index];
            final color = dayKindColor(tokens, day.effectiveKind);
            final isToday = day.date == snapshot.today.date;
            return Expanded(
              child: Column(
                children: [
                  Text(
                    const ['一', '二', '三', '四', '五', '六', '日'][index],
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: tokens.colors.textSecondary,
                    ),
                  ),
                  SizedBox(height: tokens.spacing.sm),
                  DesktopWidgetDateSurface(
                    accentColor: color,
                    isToday: isToday,
                    todayHighlightStyle: todayHighlightStyle,
                    shape: BoxShape.rectangle,
                    surfaceKey: ValueKey(
                      'desktop-widget-week-date-${day.date}',
                    ),
                    child: Text(
                      day.shortLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color:
                            isToday &&
                                todayHighlightStyle ==
                                    DesktopWidgetTodayHighlightStyle.filled
                            ? Colors.white
                            : color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        const Spacer(),
        _Legend(compact: true),
      ],
    );
  }
}

class _LargeSnapshot extends StatelessWidget {
  const _LargeSnapshot({
    required this.snapshot,
    required this.dateShape,
    required this.todayHighlightStyle,
    required this.onOpenDate,
  });

  final DesktopWidgetSnapshot snapshot;
  final DesktopWidgetLargeDateShape dateShape;
  final DesktopWidgetTodayHighlightStyle todayHighlightStyle;
  final ValueChanged<DayPresentation> onOpenDate;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${snapshot.month.year}年${snapshot.month.month}月',
                maxLines: 1,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              '本月还要再上${snapshot.remainingMonthWorkDays}天班',
              maxLines: 1,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: tokens.colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: tokens.spacing.sm),
        Row(
          children: const ['一', '二', '三', '四', '五', '六', '日']
              .map(
                (label) => Expanded(
                  child: Center(
                    child: Text(
                      label,
                      textScaler: const TextScaler.linear(0.9),
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        ),
        SizedBox(height: tokens.spacing.xs),
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.12,
            ),
            itemCount: snapshot.monthDays.length,
            itemBuilder: (context, index) {
              final day = snapshot.monthDays[index];
              final isCurrentMonth = day.date.month == snapshot.month.month;
              final color = dayKindColor(tokens, day.effectiveKind);
              final isToday = day.date == snapshot.today.date;
              return InkWell(
                borderRadius: BorderRadius.circular(tokens.radius.pill),
                onTap: () => onOpenDate(day),
                child: Center(
                  child: DesktopWidgetDateSurface(
                    accentColor: color,
                    isToday: isToday,
                    isMuted: !isCurrentMonth,
                    todayHighlightStyle: todayHighlightStyle,
                    shape: switch (dateShape) {
                      DesktopWidgetLargeDateShape.roundedRectangle =>
                        BoxShape.rectangle,
                      DesktopWidgetLargeDateShape.circle => BoxShape.circle,
                    },
                    surfaceKey: ValueKey(
                      'desktop-widget-month-date-${day.date}',
                    ),
                    child: Text(
                      '${day.date.day}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color:
                            isToday &&
                                todayHighlightStyle ==
                                    DesktopWidgetTodayHighlightStyle.filled
                            ? Colors.white
                            : isCurrentMonth
                            ? day.effectiveKind.isRest
                                  ? color
                                  : tokens.colors.textPrimary
                            : tokens.colors.textSecondary.withValues(
                                alpha: 0.45,
                              ),
                        fontWeight: day.effectiveKind.isRest || isToday
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: tokens.spacing.xs),
        _Legend(compact: true),
      ],
    );
  }
}

class _SmallMetricSurface extends StatelessWidget {
  const _SmallMetricSurface({required this.child, required this.surfaceKey});

  final Widget child;
  final Key surfaceKey;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isNeumorphic = tokens.visualStyle == AppVisualStyle.neumorphic;
    final isFlat = tokens.visualStyle == AppVisualStyle.flat;
    return DecoratedBox(
      key: surfaceKey,
      decoration: BoxDecoration(
        color: tokens.colors.surfaceElevated,
        borderRadius: BorderRadius.circular(tokens.radius.sm),
        border: isNeumorphic || tokens.borderWidth == 0
            ? null
            : Border.all(
                color: tokens.colors.border,
                width: tokens.borderWidth,
              ),
        boxShadow: isFlat ? const [] : tokens.shadows.low,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.sm,
          vertical: tokens.spacing.xs,
        ),
        child: child,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color ?? tokens.colors.adjustedRest,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: tokens.spacing.sm),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final items = <(String, Color)>[
      ('工作', tokens.colors.work),
      ('休息', tokens.colors.rest),
      ('调休', tokens.colors.adjustedWork),
      ('请假', tokens.colors.leave),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items
          .map(
            (item) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: compact ? 7 : 8,
                  height: compact ? 7 : 8,
                  decoration: BoxDecoration(
                    color: item.$2,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 3),
                Text(item.$1, style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          )
          .toList(growable: false),
    );
  }
}
