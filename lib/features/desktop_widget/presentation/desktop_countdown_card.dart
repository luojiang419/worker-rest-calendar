import 'package:flutter/material.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/features/desktop_widget/domain/countdown_target.dart';
import 'package:worker_rest_calendar/features/desktop_widget/presentation/desktop_widget_frame.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

class DesktopCountdownCard extends StatelessWidget {
  const DesktopCountdownCard({
    required this.title,
    required this.isoDate,
    required this.size,
    required this.positionLocked,
    required this.onStartDragging,
    required this.onChanged,
    this.now,
    super.key,
  });

  final String title;
  final String isoDate;
  final DesktopWidgetSize size;
  final bool positionLocked;
  final VoidCallback onStartDragging;
  final void Function(String title, DateTime date) onChanged;
  final DateTime Function()? now;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final target = CountdownTarget.tryParse(title: title, isoDate: isoDate);
    final current = (now ?? DateTime.now)();
    final days = target?.daysFrom(current);
    final compact = size == DesktopWidgetSize.small;
    final dayText = switch (days) {
      null => '--',
      0 => '今天',
      final int value => value.abs().toString(),
    };
    final caption = switch (days) {
      null => '设置一个值得期待的日子',
      0 => '就是今天',
      final int value when value > 0 => '还有 $value 天',
      final int value => '已经过去 ${value.abs()} 天',
    };
    return DesktopWidgetFrame(
      size: size,
      cardKey: ValueKey('desktop-countdown-card-${tokens.visualStyle.name}'),
      shadowSafeAreaKey: const ValueKey('desktop-countdown-shadow-safe-area'),
      child: Semantics(
        label: '${target?.title ?? '倒数日'}，$caption',
        child: Column(
          children: [
            _DragHeader(
              locked: positionLocked,
              onStartDragging: onStartDragging,
              onEdit: () => _configure(context, target, current),
            ),
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        dayText,
                        key: const ValueKey('desktop-countdown-days'),
                        style:
                            (compact
                                    ? Theme.of(context).textTheme.displayMedium
                                    : Theme.of(context).textTheme.displayLarge)
                                ?.copyWith(
                                  color: days != null && days < 0
                                      ? tokens.colors.textSecondary
                                      : tokens.colors.primary,
                                  fontWeight: FontWeight.w800,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                      ),
                      SizedBox(height: tokens.spacing.xs),
                      Text(
                        target?.title ?? '倒数日',
                        maxLines: 1,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        caption,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (target != null && !compact)
              Text(
                '${target.date.year}年${target.date.month}月${target.date.day}日',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: tokens.colors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _configure(
    BuildContext context,
    CountdownTarget? target,
    DateTime current,
  ) async {
    final titleController = TextEditingController(text: target?.title ?? title);
    var selectedDate = target?.date ?? current.add(const Duration(days: 30));
    final result = await showDialog<(String, DateTime)>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('设置倒数日'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                maxLength: 30,
                decoration: const InputDecoration(labelText: '名称'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('目标日期'),
                subtitle: Text(
                  '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: dialogContext,
                    initialDate: selectedDate,
                    firstDate: DateTime(1970),
                    lastDate: DateTime(2100, 12, 31),
                  );
                  if (picked != null) {
                    setDialogState(() => selectedDate = picked);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, (
                titleController.text,
                selectedDate,
              )),
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
    titleController.dispose();
    if (result != null) onChanged(result.$1, result.$2);
  }
}

class _DragHeader extends StatelessWidget {
  const _DragHeader({
    required this.locked,
    required this.onStartDragging,
    required this.onEdit,
  });

  final bool locked;
  final VoidCallback onStartDragging;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      MouseRegion(
        cursor: locked ? SystemMouseCursors.basic : SystemMouseCursors.move,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: locked ? null : (_) => onStartDragging(),
          child: Padding(
            padding: EdgeInsets.all(context.tokens.spacing.xs),
            child: const Icon(Icons.drag_indicator_rounded, size: 18),
          ),
        ),
      ),
      Expanded(
        child: Text(
          '倒数日',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      IconButton(
        key: const ValueKey('desktop-countdown-edit'),
        tooltip: '设置倒数日',
        onPressed: onEdit,
        icon: const Icon(Icons.edit_calendar_outlined, size: 18),
      ),
    ],
  );
}
