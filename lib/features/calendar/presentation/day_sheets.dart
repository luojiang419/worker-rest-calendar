import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/core/date/date_labels.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/core/widgets/app_bottom_sheet.dart';
import 'package:worker_rest_calendar/core/widgets/app_button.dart';
import 'package:worker_rest_calendar/core/widgets/app_card.dart';
import 'package:worker_rest_calendar/core/widgets/app_status_chip.dart';
import 'package:worker_rest_calendar/core/widgets/app_toast.dart';
import 'package:worker_rest_calendar/features/schedule/application/active_schedule_controller.dart';
import 'package:worker_rest_calendar/features/schedule/application/day_presentation.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/schedule/presentation/day_visuals.dart';

enum _DayDetailsAction { edit, delete }

Future<void> showDayDetailsSheet({
  required BuildContext context,
  required WidgetRef ref,
  required CalendarDate date,
}) async {
  final schedule = ref.read(activeScheduleControllerProvider).value;
  if (schedule == null) {
    return;
  }
  final day = schedule.day(date);
  final action = await showAppBottomSheet<_DayDetailsAction>(
    context: context,
    builder: (sheetContext) => DayDetailsSheet(
      day: day,
      onEdit: () => Navigator.pop(sheetContext, _DayDetailsAction.edit),
      onDelete: day.hasManualOverride
          ? () => Navigator.pop(sheetContext, _DayDetailsAction.delete)
          : null,
    ),
  );
  if (!context.mounted) {
    return;
  }
  if (action == _DayDetailsAction.edit) {
    await showDayEditorSheet(context: context, ref: ref, date: date);
  } else if (action == _DayDetailsAction.delete) {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('删除当天调整？'),
        content: const Text('删除当天调整后，将恢复为基础班制计算结果。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref
          .read(activeScheduleControllerProvider.notifier)
          .deleteManualOverride(date);
      if (context.mounted) {
        showAppToast(context, message: '已恢复基础班制');
      }
    }
  }
}

Future<void> showDayEditorSheet({
  required BuildContext context,
  required WidgetRef ref,
  required CalendarDate date,
}) async {
  final schedule = ref.read(activeScheduleControllerProvider).value;
  if (schedule == null) {
    return;
  }
  final saved = await showAppBottomSheet<bool>(
    context: context,
    builder: (sheetContext) => DayEditorSheet(
      day: schedule.day(date),
      onSave: ({required kind, required overtimeMinutes, note}) async {
        await ref
            .read(activeScheduleControllerProvider.notifier)
            .saveManualOverride(
              date: date,
              kind: kind,
              overtimeMinutes: overtimeMinutes,
              note: note,
            );
        if (sheetContext.mounted) {
          Navigator.pop(sheetContext, true);
        }
      },
    ),
  );
  if (saved == true && context.mounted) {
    showAppToast(context, message: '当天安排已保存');
  }
}

class DayDetailsSheet extends StatelessWidget {
  const DayDetailsSheet({
    required this.day,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final DayPresentation day;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.82,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: tokens.sizes.minTouch,
                height: tokens.spacing.xs,
                decoration: BoxDecoration(
                  color: tokens.colors.border,
                  borderRadius: BorderRadius.circular(tokens.radius.pill),
                ),
              ),
            ),
            SizedBox(height: tokens.spacing.lg),
            Text(
              day.date.fullDateLabel,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            SizedBox(height: tokens.spacing.lg),
            Align(
              alignment: Alignment.centerLeft,
              child: AppStatusChip(kind: day.effectiveKind),
            ),
            SizedBox(height: tokens.spacing.lg),
            AppCard(
              shadowLevel: AppShadowLevel.low,
              child: Column(
                children: [
                  _DetailRow(label: '基础班制', value: day.plannedKind.fullLabel),
                  _DetailRow(label: '当前状态', value: day.effectiveKind.fullLabel),
                  _DetailRow(label: '加班', value: '${day.overtimeMinutes} 分钟'),
                  _DetailRow(label: '备注', value: day.note ?? '无', isLast: true),
                ],
              ),
            ),
            SizedBox(height: tokens.spacing.lg),
            AppButton.primary(
              label: '编辑当天',
              icon: Icons.edit_outlined,
              expand: true,
              onPressed: onEdit,
            ),
            if (onDelete != null) ...[
              SizedBox(height: tokens.spacing.md),
              AppButton.danger(
                label: '删除当天调整',
                icon: Icons.delete_outline_rounded,
                expand: true,
                onPressed: onDelete,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: EdgeInsets.symmetric(vertical: tokens.spacing.md),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: tokens.colors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: tokens.sizes.minTouch * 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: tokens.colors.textSecondary,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

typedef SaveDayCallback =
    Future<void> Function({
      required DayKind kind,
      required int overtimeMinutes,
      String? note,
    });

class DayEditorSheet extends StatefulWidget {
  const DayEditorSheet({required this.day, required this.onSave, super.key});

  final DayPresentation day;
  final SaveDayCallback onSave;

  @override
  State<DayEditorSheet> createState() => _DayEditorSheetState();
}

class _DayEditorSheetState extends State<DayEditorSheet> {
  late DayKind _kind;
  late final TextEditingController _overtimeController;
  late final TextEditingController _noteController;
  var _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _kind = widget.day.effectiveKind;
    _overtimeController = TextEditingController(
      text: widget.day.overtimeMinutes.toString(),
    );
    _noteController = TextEditingController(text: widget.day.note ?? '');
  }

  @override
  void dispose() {
    _overtimeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: tokens.sizes.minTouch,
                height: tokens.spacing.xs,
                decoration: BoxDecoration(
                  color: tokens.colors.border,
                  borderRadius: BorderRadius.circular(tokens.radius.pill),
                ),
              ),
            ),
            SizedBox(height: tokens.spacing.lg),
            Text(
              '编辑 ${widget.day.date.fullDateLabel}',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            SizedBox(height: tokens.spacing.lg),
            Text(
              '当天状态',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: tokens.spacing.md),
            Wrap(
              spacing: tokens.spacing.sm,
              runSpacing: tokens.spacing.sm,
              children: [
                for (final kind in DayKind.values)
                  _StatusChoice(
                    kind: kind,
                    selected: _kind == kind,
                    onTap: () => setState(() => _kind = kind),
                  ),
              ],
            ),
            SizedBox(height: tokens.spacing.lg),
            TextField(
              controller: _overtimeController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: '加班分钟数',
                hintText: '0',
                prefixIcon: Icon(Icons.schedule_outlined),
              ),
            ),
            SizedBox(height: tokens.spacing.lg),
            TextField(
              controller: _noteController,
              maxLines: 3,
              maxLength: 200,
              decoration: const InputDecoration(
                labelText: '备注',
                hintText: '可选',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.notes_rounded),
              ),
            ),
            if (_error case final error?) ...[
              SizedBox(height: tokens.spacing.sm),
              Text(
                error,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: tokens.colors.danger),
              ),
            ],
            SizedBox(height: tokens.spacing.lg),
            AppButton.primary(
              label: _saving ? '正在保存' : '保存当天调整',
              icon: Icons.check_rounded,
              expand: true,
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final overtime = int.tryParse(_overtimeController.text.trim());
    if (overtime == null || overtime < 0) {
      setState(() => _error = '加班分钟数必须是大于或等于 0 的整数');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave(
        kind: _kind,
        overtimeMinutes: overtime,
        note: _noteController.text,
      );
    } on Object {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = '保存失败，请稍后重试';
        });
      }
    }
  }
}

class _StatusChoice extends StatelessWidget {
  const _StatusChoice({
    required this.kind,
    required this.selected,
    required this.onTap,
  });

  final DayKind kind;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = dayKindColor(tokens, kind);
    return Semantics(
      button: true,
      selected: selected,
      label: kind.fullLabel,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        child: AnimatedContainer(
          duration: tokens.motion.fast,
          constraints: BoxConstraints(minHeight: tokens.sizes.minTouch),
          padding: EdgeInsets.symmetric(
            horizontal: tokens.spacing.md,
            vertical: tokens.spacing.sm,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: selected ? 0.2 : 0.08),
            borderRadius: BorderRadius.circular(tokens.radius.md),
            border: Border.all(color: color, width: selected ? 2 : 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(dayKindIcon(kind), size: 18, color: color),
              SizedBox(width: tokens.spacing.xs),
              Text(
                kind.fullLabel,
                style: TextStyle(color: color, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
