import 'package:flutter/material.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/core/widgets/app_button.dart';
import 'package:worker_rest_calendar/core/widgets/app_card.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_pattern.dart';

class OnboardingPatternPage extends StatelessWidget {
  const OnboardingPatternPage({
    required this.selected,
    required this.onSelected,
    required this.onBack,
    required this.onContinue,
    super.key,
  });

  final SchedulePatternType? selected;
  final ValueChanged<SchedulePatternType> onSelected;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          children: [
            SizedBox(height: tokens.spacing.lg),
            _Header(onBack: onBack),
            SizedBox(height: tokens.spacing.lg),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(vertical: tokens.spacing.sm),
                itemCount: _patterns.length,
                separatorBuilder: (context, index) =>
                    SizedBox(height: tokens.spacing.md),
                itemBuilder: (context, index) {
                  final option = _patterns[index];
                  final isSelected = selected == option.type;
                  return AppCard(
                    key: ValueKey(option.type),
                    semanticLabel:
                        '${option.title}，${isSelected ? '已选择' : '未选择'}',
                    onTap: () => onSelected(option.type),
                    color: isSelected
                        ? tokens.colors.primary.withValues(alpha: 0.12)
                        : tokens.colors.surface,
                    shadowLevel: isSelected
                        ? AppShadowLevel.medium
                        : AppShadowLevel.low,
                    child: Row(
                      children: [
                        Icon(
                          option.icon,
                          color: isSelected
                              ? tokens.colors.primary
                              : tokens.colors.textSecondary,
                        ),
                        SizedBox(width: tokens.spacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option.title,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              SizedBox(height: tokens.spacing.xs),
                              Text(
                                option.description,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: tokens.colors.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: tokens.spacing.sm),
                        Icon(
                          isSelected
                              ? Icons.check_circle_rounded
                              : Icons.circle_outlined,
                          color: isSelected
                              ? tokens.colors.primary
                              : tokens.colors.border,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: tokens.spacing.lg),
              child: AppButton.primary(
                label: '下一步',
                expand: true,
                onPressed: selected == null ? null : onContinue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton(
        tooltip: '返回欢迎页',
        onPressed: onBack,
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选择你的班制',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              '以后可以在设置中修改',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.tokens.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

final class _PatternOption {
  const _PatternOption(this.type, this.title, this.description, this.icon);

  final SchedulePatternType type;
  final String title;
  final String description;
  final IconData icon;
}

const _patterns = [
  _PatternOption(
    SchedulePatternType.doubleRest,
    '双休',
    '周一至周五上班，周六、周日休息',
    Icons.weekend_outlined,
  ),
  _PatternOption(
    SchedulePatternType.singleRest,
    '单休',
    '周一至周六上班，周日休息',
    Icons.work_outline_rounded,
  ),
  _PatternOption(
    SchedulePatternType.alternatingBigSmallWeek,
    '大小周',
    '大周双休、小周周六上班，按周交替',
    Icons.swap_horiz_rounded,
  ),
  _PatternOption(
    SchedulePatternType.sixOnOneOff,
    '做六休一',
    '连续工作 6 天，再休息 1 天',
    Icons.looks_one_outlined,
  ),
  _PatternOption(
    SchedulePatternType.twoOnTwoOff,
    '做二休二',
    '连续工作 2 天，再休息 2 天',
    Icons.looks_two_outlined,
  ),
  _PatternOption(
    SchedulePatternType.customCycle,
    '自定义循环',
    '自由编辑 1–56 天的工作与休息节奏',
    Icons.tune_rounded,
  ),
];
