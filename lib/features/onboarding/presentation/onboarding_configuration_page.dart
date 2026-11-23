import 'package:flutter/material.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/core/widgets/app_button.dart';
import 'package:worker_rest_calendar/core/widgets/app_card.dart';
import 'package:worker_rest_calendar/core/widgets/app_segmented_control.dart';
import 'package:worker_rest_calendar/features/onboarding/domain/onboarding_draft.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_pattern.dart';

class OnboardingConfigurationPage extends StatelessWidget {
  const OnboardingConfigurationPage({
    required this.draft,
    required this.onAnchorDateChanged,
    required this.onWeekTypeChanged,
    required this.onCycleLengthChanged,
    required this.onCycleDayChanged,
    required this.onBack,
    required this.onContinue,
    super.key,
  });

  final OnboardingDraft draft;
  final ValueChanged<CalendarDate> onAnchorDateChanged;
  final ValueChanged<WeekType> onWeekTypeChanged;
  final ValueChanged<int> onCycleLengthChanged;
  final void Function(int index, DayKind kind) onCycleDayChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  bool get _isAlternating =>
      draft.patternType == SchedulePatternType.alternatingBigSmallWeek;
  bool get _isCustom => draft.patternType == SchedulePatternType.customCycle;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          children: [
            SizedBox(height: tokens.spacing.lg),
            Row(
              children: [
                IconButton(
                  tooltip: '返回班制选择',
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                Expanded(
                  child: Text(
                    _isAlternating ? '确认本周大小周' : '设置循环起点',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spacing.lg),
            Expanded(
              child: ListView(
                children: [
                  if (_isAlternating) ...[
                    Text(
                      '本周是大周还是小周？',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: tokens.spacing.sm),
                    Text(
                      '大周周六、周日休息；小周周六上班、周日休息。锚点固定为所选日期所在周的周一。',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: tokens.colors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: tokens.spacing.lg),
                    AppSegmentedControl<WeekType>(
                      emptySelectionAllowed: true,
                      segments: const [
                        ButtonSegment(value: WeekType.big, label: Text('大周')),
                        ButtonSegment(value: WeekType.small, label: Text('小周')),
                      ],
                      selected: draft.anchorWeekType == null
                          ? const {}
                          : {draft.anchorWeekType!},
                      onSelectionChanged: (selection) =>
                          onWeekTypeChanged(selection.single),
                    ),
                    SizedBox(height: tokens.spacing.xl),
                  ],
                  AppCard(
                    shadowLevel: AppShadowLevel.low,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isAlternating ? '锚点周' : '第 1 天从哪天开始？',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: tokens.spacing.md),
                        AppButton.secondary(
                          label: _dateLabel(draft.anchorDate),
                          icon: Icons.event_outlined,
                          expand: true,
                          onPressed: () => _pickDate(context),
                        ),
                        if (_isAlternating) ...[
                          SizedBox(height: tokens.spacing.sm),
                          Text(
                            '实际保存：${_dateLabel(draft.anchorDate?.monday)}（周一）',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: tokens.colors.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (_isCustom) ...[
                    SizedBox(height: tokens.spacing.xl),
                    _CustomCycleEditor(
                      cycleDays: draft.cycleDays,
                      onLengthChanged: onCycleLengthChanged,
                      onDayChanged: onCycleDayChanged,
                    ),
                  ] else if (!_isAlternating) ...[
                    SizedBox(height: tokens.spacing.lg),
                    Text(
                      _presetDescription(draft.patternType),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: tokens.colors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: tokens.spacing.lg),
              child: AppButton.primary(
                label: '查看未来 30 天',
                expand: true,
                onPressed: onContinue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final initial =
        draft.anchorDate ?? CalendarDate.fromDateTime(DateTime.now());
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime(initial.year, initial.month, initial.day),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: _isAlternating ? '选择锚点周中的任意一天' : '选择循环第 1 天',
      cancelText: '取消',
      confirmText: '确定',
    );
    if (selected != null) {
      final date = CalendarDate.fromDateTime(selected);
      onAnchorDateChanged(_isAlternating ? date.monday : date);
    }
  }
}

class _CustomCycleEditor extends StatelessWidget {
  const _CustomCycleEditor({
    required this.cycleDays,
    required this.onLengthChanged,
    required this.onDayChanged,
  });

  final List<DayKind> cycleDays;
  final ValueChanged<int> onLengthChanged;
  final void Function(int index, DayKind kind) onDayChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '编辑循环（1–56 天）',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: tokens.spacing.sm),
          Text(
            '点击每一天切换“班/休”，循环中至少保留一个休息日。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: tokens.colors.textSecondary,
            ),
          ),
          SizedBox(height: tokens.spacing.lg),
          Row(
            children: [
              IconButton.outlined(
                tooltip: '减少一天',
                onPressed: cycleDays.length > 1
                    ? () => onLengthChanged(cycleDays.length - 1)
                    : null,
                icon: const Icon(Icons.remove_rounded),
              ),
              Expanded(
                child: Text(
                  '${cycleDays.length} 天',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton.outlined(
                tooltip: '增加一天',
                onPressed: cycleDays.length < 56
                    ? () => onLengthChanged(cycleDays.length + 1)
                    : null,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.lg),
          Wrap(
            spacing: tokens.spacing.sm,
            runSpacing: tokens.spacing.sm,
            children: [
              for (var index = 0; index < cycleDays.length; index++)
                _CycleDayButton(
                  index: index,
                  kind: cycleDays[index],
                  onTap: () => onDayChanged(
                    index,
                    cycleDays[index] == DayKind.work
                        ? DayKind.rest
                        : DayKind.work,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CycleDayButton extends StatelessWidget {
  const _CycleDayButton({
    required this.index,
    required this.kind,
    required this.onTap,
  });

  final int index;
  final DayKind kind;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isRest = kind == DayKind.rest;
    final color = isRest ? tokens.colors.rest : tokens.colors.work;
    return Semantics(
      button: true,
      label: '第 ${index + 1} 天，${isRest ? '休息' : '工作'}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radius.sm),
        child: Container(
          constraints: BoxConstraints(
            minWidth: tokens.sizes.minTouch + tokens.spacing.md,
            minHeight: tokens.sizes.minTouch,
          ),
          padding: EdgeInsets.all(tokens.spacing.sm),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(tokens.radius.sm),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('第 ${index + 1} 天'),
              Text(
                isRest ? '休' : '班',
                style: TextStyle(color: color, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _dateLabel(CalendarDate? date) =>
    date == null ? '请选择日期' : '${date.year}年${date.month}月${date.day}日';

String _presetDescription(SchedulePatternType? type) => switch (type) {
  SchedulePatternType.sixOnOneOff => '将从所选日期开始，按“工作 6 天、休息 1 天”循环。',
  SchedulePatternType.twoOnTwoOff => '将从所选日期开始，按“工作 2 天、休息 2 天”循环。',
  _ => '',
};
