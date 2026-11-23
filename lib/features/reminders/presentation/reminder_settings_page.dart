import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/core/widgets/app_button.dart';
import 'package:worker_rest_calendar/core/widgets/app_card.dart';
import 'package:worker_rest_calendar/core/widgets/app_state_view.dart';
import 'package:worker_rest_calendar/core/widgets/app_toast.dart';
import 'package:worker_rest_calendar/features/reminders/application/reminder_controller.dart';
import 'package:worker_rest_calendar/features/reminders/application/reminder_platform_adapter.dart';
import 'package:worker_rest_calendar/features/reminders/domain/reminder_preferences.dart';

class ReminderSettingsPage extends ConsumerWidget {
  const ReminderSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminder = ref.watch(reminderControllerProvider);
    final tokens = context.tokens;
    return Scaffold(
      appBar: AppBar(title: const Text('提醒设置')),
      body: SafeArea(
        top: false,
        child: reminder.when(
          loading: () =>
              const Center(child: AppLoadingState(label: '正在读取提醒状态')),
          error: (error, stackTrace) => Center(
            child: AppErrorState(
              title: '提醒设置加载失败',
              message: '请稍后重试',
              onRetry: () => ref.invalidate(reminderControllerProvider),
            ),
          ),
          data: (state) => ListView(
            padding: EdgeInsets.all(tokens.sizes.mobileHorizontalPadding),
            children: [
              _PermissionCard(state: state),
              SizedBox(height: tokens.spacing.lg),
              _ReminderSection(
                title: '明日状态',
                description: '每天固定时间告诉你第二天上班还是休息。',
                enabled: state.preferences.dailyNextDayEnabled,
                onEnabledChanged: (value) => _save(
                  context,
                  ref,
                  state.preferences.copyWith(dailyNextDayEnabled: value),
                ),
                trailing: AppButton.secondary(
                  label: state.preferences.dailyNextDayTime,
                  icon: Icons.schedule_outlined,
                  onPressed: () => _pickTime(
                    context,
                    initial: state.preferences.dailyNextDayTime,
                    onSelected: (value) => _save(
                      context,
                      ref,
                      state.preferences.copyWith(dailyNextDayTime: value),
                    ),
                  ),
                ),
              ),
              SizedBox(height: tokens.spacing.lg),
              _ReminderSection(
                title: '调休上班',
                description: '对调休上班日额外提醒，避免被周末误导。',
                enabled: state.preferences.adjustedWorkEnabled,
                onEnabledChanged: (value) => _save(
                  context,
                  ref,
                  state.preferences.copyWith(adjustedWorkEnabled: value),
                ),
                trailing: _LeadDaysEditor(
                  days: state.preferences.adjustedWorkLeadDays,
                  onChanged: (value) => _save(
                    context,
                    ref,
                    state.preferences.copyWith(adjustedWorkLeadDays: value),
                  ),
                ),
              ),
              SizedBox(height: tokens.spacing.lg),
              _ReminderSection(
                title: '周预览',
                description: '每周指定日期预览下一周工作和休息节奏。',
                enabled: state.preferences.weeklyPreviewEnabled,
                onEnabledChanged: (value) => _save(
                  context,
                  ref,
                  state.preferences.copyWith(weeklyPreviewEnabled: value),
                ),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    DropdownButton<int>(
                      value: state.preferences.weeklyPreviewWeekday,
                      items: List.generate(
                        7,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text(_weekdayLabel(index + 1)),
                        ),
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          _save(
                            context,
                            ref,
                            state.preferences.copyWith(
                              weeklyPreviewWeekday: value,
                            ),
                          );
                        }
                      },
                    ),
                    AppButton.secondary(
                      label: state.preferences.weeklyPreviewTime,
                      icon: Icons.schedule_outlined,
                      onPressed: () => _pickTime(
                        context,
                        initial: state.preferences.weeklyPreviewTime,
                        onSelected: (value) => _save(
                          context,
                          ref,
                          state.preferences.copyWith(weeklyPreviewTime: value),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: tokens.spacing.lg),
              _ReminderSection(
                title: '休息倒计时',
                description: '在明日状态提醒时间告诉你距离下次休息还有几天。',
                enabled: state.preferences.countdownEnabled,
                onEnabledChanged: (value) => _save(
                  context,
                  ref,
                  state.preferences.copyWith(countdownEnabled: value),
                ),
              ),
              SizedBox(height: tokens.spacing.lg),
              Text(
                '当前已计划 ${state.pendingCount} 条通知。修改班制后会自动替换旧计划。',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tokens.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save(
    BuildContext context,
    WidgetRef ref,
    ReminderPreferences preferences,
  ) async {
    try {
      await ref
          .read(reminderControllerProvider.notifier)
          .savePreferences(preferences);
    } on Object {
      if (context.mounted) {
        showAppToast(
          context,
          message: '提醒设置保存失败',
          icon: Icons.error_outline_rounded,
        );
      }
    }
  }

  Future<void> _pickTime(
    BuildContext context, {
    required String initial,
    required ValueChanged<String> onSelected,
  }) async {
    final parts = initial.split(':').map(int.parse).toList();
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: parts[0], minute: parts[1]),
      helpText: '选择提醒时间',
      cancelText: '取消',
      confirmText: '确定',
    );
    if (selected != null) {
      onSelected(
        '${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}',
      );
    }
  }
}

class _PermissionCard extends ConsumerWidget {
  const _PermissionCard({required this.state});

  final ReminderControllerState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final (icon, title, message, color) = switch (state.permissionStatus) {
      ReminderPermissionStatus.granted => (
        Icons.notifications_active_outlined,
        '通知已开启',
        '排班提醒会按当前设置在本机触发。',
        tokens.colors.rest,
      ),
      ReminderPermissionStatus.systemDisabled => (
        Icons.notifications_off_outlined,
        '通知权限未开启或已被系统关闭',
        '请授权通知；如果之前拒绝过，请在系统设置中开启后返回刷新。',
        tokens.colors.adjustedWork,
      ),
      ReminderPermissionStatus.unsupported => (
        Icons.info_outline_rounded,
        '当前平台暂不支持通知',
        '统计和日历仍可正常使用。',
        tokens.colors.textSecondary,
      ),
    };
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              SizedBox(width: tokens.spacing.md),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.sm),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: tokens.colors.textSecondary,
            ),
          ),
          if (state.permissionStatus ==
              ReminderPermissionStatus.systemDisabled) ...[
            SizedBox(height: tokens.spacing.lg),
            Row(
              children: [
                Expanded(
                  child: AppButton.primary(
                    label: '授权通知',
                    onPressed: () => ref
                        .read(reminderControllerProvider.notifier)
                        .requestPermission(),
                  ),
                ),
                SizedBox(width: tokens.spacing.sm),
                Expanded(
                  child: AppButton.secondary(
                    label: '刷新状态',
                    onPressed: () => ref
                        .read(reminderControllerProvider.notifier)
                        .refreshPermission(),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ReminderSection extends StatelessWidget {
  const _ReminderSection({
    required this.title,
    required this.description,
    required this.enabled,
    required this.onEnabledChanged,
    this.trailing,
  });

  final String title;
  final String description;
  final bool enabled;
  final ValueChanged<bool> onEnabledChanged;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: tokens.spacing.xs),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: enabled,
                activeThumbColor: tokens.colors.surface,
                activeTrackColor: tokens.colors.primary,
                onChanged: onEnabledChanged,
              ),
            ],
          ),
          if (trailing != null) ...[
            SizedBox(height: tokens.spacing.md),
            Align(alignment: Alignment.centerRight, child: trailing),
          ],
        ],
      ),
    );
  }
}

class _LeadDaysEditor extends StatelessWidget {
  const _LeadDaysEditor({required this.days, required this.onChanged});

  final int days;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton.outlined(
        tooltip: '减少提前天数',
        onPressed: days > 0 ? () => onChanged(days - 1) : null,
        icon: const Icon(Icons.remove_rounded),
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: context.tokens.spacing.md),
        child: Text('提前 $days 天'),
      ),
      IconButton.outlined(
        tooltip: '增加提前天数',
        onPressed: days < 30 ? () => onChanged(days + 1) : null,
        icon: const Icon(Icons.add_rounded),
      ),
    ],
  );
}

String _weekdayLabel(int weekday) =>
    const ['周一', '周二', '周三', '周四', '周五', '周六', '周日'][weekday - 1];
