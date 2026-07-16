import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/core/widgets/app_card.dart';
import 'package:worker_rest_calendar/core/widgets/app_segmented_control.dart';
import 'package:worker_rest_calendar/core/widgets/app_state_view.dart';
import 'package:worker_rest_calendar/features/desktop_widget/application/desktop_widget_controller.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';
import 'package:worker_rest_calendar/features/updater/application/update_controller.dart';
import 'package:worker_rest_calendar/features/updater/domain/update_models.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({
    required this.onOpenTheme,
    required this.onOpenReminders,
    required this.onOpenDataManagement,
    super.key,
  });

  final VoidCallback onOpenTheme;
  final VoidCallback onOpenReminders;
  final VoidCallback onOpenDataManagement;

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  var _saving = false;
  double? _opacityDraft;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(desktopWidgetControllerProvider);
    final updater = ref.watch(updateControllerProvider);
    final updaterSupported = ref.watch(updatePlatformSupportedProvider);
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: state.when(
          loading: () => const Center(child: AppLoadingState(label: '正在读取设置')),
          error: (error, stackTrace) => Center(
            child: AppErrorState(
              title: '设置加载失败',
              message: '请稍后重试',
              onRetry: () => ref.invalidate(desktopWidgetControllerProvider),
            ),
          ),
          data: (desktopState) {
            final preferences = desktopState.preferences;
            final opacity = _opacityDraft ?? preferences.desktopWidgetOpacity;
            return ListView(
              padding: EdgeInsets.fromLTRB(
                context.tokens.sizes.desktopHorizontalPadding,
                context.tokens.spacing.lg,
                context.tokens.sizes.desktopHorizontalPadding,
                context.tokens.spacing.xxl,
              ),
              children: [
                Text(
                  '设置',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: context.tokens.spacing.lg),
                _SettingsSection(
                  title: '通用',
                  children: [
                    _SwitchSetting(
                      title: '开机自启',
                      description: '登录系统后自动启动工作日历并显示桌面摆件',
                      value: preferences.desktopLaunchAtStartup,
                      enabled: !_saving,
                      onChanged: (value) => _apply(
                        () => ref
                            .read(desktopWidgetControllerProvider.notifier)
                            .setLaunchAtStartup(value),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.tokens.spacing.lg),
                _SettingsSection(
                  title: '日历浏览',
                  children: [
                    _SegmentedSetting<CalendarScrollAxis>(
                      title: '滚动方向',
                      description: '自由滚动可停在任意位置，不会自动吸附到整月',
                      selected: preferences.calendarScrollAxis,
                      enabled: !_saving,
                      segments: const [
                        ButtonSegment(
                          value: CalendarScrollAxis.horizontal,
                          icon: Icon(Icons.swap_horiz_rounded),
                          label: Text('左右'),
                        ),
                        ButtonSegment(
                          value: CalendarScrollAxis.vertical,
                          icon: Icon(Icons.swap_vert_rounded),
                          label: Text('上下'),
                        ),
                      ],
                      onChanged: (value) => _apply(
                        () => ref
                            .read(desktopWidgetControllerProvider.notifier)
                            .setCalendarScrollAxis(value),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.tokens.spacing.lg),
                _SettingsSection(
                  title: '桌面摆件',
                  children: [
                    _SegmentedSetting<DesktopWidgetSize>(
                      title: '摆件尺寸',
                      selected: preferences.desktopWidgetSize,
                      enabled: !_saving,
                      segments: const [
                        ButtonSegment(
                          value: DesktopWidgetSize.small,
                          label: Text('小'),
                        ),
                        ButtonSegment(
                          value: DesktopWidgetSize.medium,
                          label: Text('中'),
                        ),
                        ButtonSegment(
                          value: DesktopWidgetSize.large,
                          label: Text('大'),
                        ),
                      ],
                      onChanged: (value) => _apply(
                        () => ref
                            .read(desktopWidgetControllerProvider.notifier)
                            .setSize(value),
                      ),
                    ),
                    const _SettingDivider(),
                    _SegmentedSetting<DesktopWidgetLargeDateShape>(
                      title: '大号日期形状',
                      selected: preferences.desktopWidgetLargeDateShape,
                      enabled: !_saving,
                      segments: const [
                        ButtonSegment(
                          value: DesktopWidgetLargeDateShape.roundedRectangle,
                          label: Text('圆角'),
                        ),
                        ButtonSegment(
                          value: DesktopWidgetLargeDateShape.circle,
                          label: Text('圆形'),
                        ),
                      ],
                      onChanged: (value) => _apply(
                        () => ref
                            .read(desktopWidgetControllerProvider.notifier)
                            .setLargeDateShape(value),
                      ),
                    ),
                    const _SettingDivider(),
                    _SegmentedSetting<DesktopWidgetTodayHighlightStyle>(
                      title: '今天突出方式',
                      selected: preferences.desktopWidgetTodayHighlightStyle,
                      enabled: !_saving,
                      segments: const [
                        ButtonSegment(
                          value: DesktopWidgetTodayHighlightStyle.glowOutline,
                          label: Text('微光描边'),
                        ),
                        ButtonSegment(
                          value: DesktopWidgetTodayHighlightStyle.filled,
                          label: Text('填充高亮'),
                        ),
                      ],
                      onChanged: (value) => _apply(
                        () => ref
                            .read(desktopWidgetControllerProvider.notifier)
                            .setTodayHighlightStyle(value),
                      ),
                    ),
                    const _SettingDivider(),
                    _SliderSetting(
                      title: '摆件透明度',
                      value: opacity,
                      enabled: !_saving,
                      onChanged: (value) =>
                          setState(() => _opacityDraft = value),
                      onChangeEnd: (value) => _apply(() async {
                        await ref
                            .read(desktopWidgetControllerProvider.notifier)
                            .setOpacity(value);
                        if (mounted) setState(() => _opacityDraft = null);
                      }),
                    ),
                    const _SettingDivider(),
                    _SwitchSetting(
                      title: '窗口置顶',
                      description: preferences.desktopWidgetLocked
                          ? '锁定到桌面层时不能同时置顶'
                          : '仅对桌面摆件生效',
                      value: preferences.desktopWidgetAlwaysOnTop,
                      enabled: !_saving && !preferences.desktopWidgetLocked,
                      onChanged: (value) => _apply(
                        () => ref
                            .read(desktopWidgetControllerProvider.notifier)
                            .setAlwaysOnTop(value),
                      ),
                    ),
                    const _SettingDivider(),
                    _SwitchSetting(
                      title: '锁定位置（桌面层）',
                      description: '锁定后摆件不可拖动，并保持在普通窗口下方',
                      value: preferences.desktopWidgetLocked,
                      enabled: !_saving,
                      onChanged: (value) => _apply(
                        () => ref
                            .read(desktopWidgetControllerProvider.notifier)
                            .setLocked(value),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.tokens.spacing.lg),
                if (updaterSupported) ...[
                  _SettingsSection(
                    title: '软件更新',
                    children: [
                      updater.when(
                        loading: () => const AppLoadingState(label: '正在读取更新设置'),
                        error: (error, stackTrace) => AppErrorState(
                          title: '更新设置加载失败',
                          message: '请稍后重试',
                          onRetry: () =>
                              ref.invalidate(updateControllerProvider),
                        ),
                        data: (updateState) => _UpdateSettings(
                          state: updateState,
                          saving: _saving,
                          onPolicyChanged: (value) => _apply(
                            () => ref
                                .read(updateControllerProvider.notifier)
                                .setPolicy(value),
                          ),
                          onNetworkModeChanged: (value) => _apply(
                            () => ref
                                .read(updateControllerProvider.notifier)
                                .setNetworkMode(value),
                          ),
                          onManualProxySaved: (value) => _apply(
                            () => ref
                                .read(updateControllerProvider.notifier)
                                .setManualProxyUrl(value),
                          ),
                          onCheck: () => _apply(
                            () => ref
                                .read(updateControllerProvider.notifier)
                                .checkManually(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.tokens.spacing.lg),
                ],
                _SettingsSection(
                  title: '更多',
                  children: [
                    _LinkSetting(
                      icon: Icons.palette_outlined,
                      title: '外观与主题',
                      onTap: widget.onOpenTheme,
                    ),
                    const _SettingDivider(),
                    _LinkSetting(
                      icon: Icons.notifications_outlined,
                      title: '提醒设置',
                      onTap: widget.onOpenReminders,
                    ),
                    const _SettingDivider(),
                    _LinkSetting(
                      icon: Icons.storage_outlined,
                      title: '数据与同步',
                      onTap: widget.onOpenDataManagement,
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _apply(Future<void> Function() operation) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await operation();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('设置保存失败，请稍后重试')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _UpdateSettings extends StatelessWidget {
  const _UpdateSettings({
    required this.state,
    required this.saving,
    required this.onPolicyChanged,
    required this.onNetworkModeChanged,
    required this.onManualProxySaved,
    required this.onCheck,
  });

  final UpdateControllerState state;
  final bool saving;
  final ValueChanged<UpdatePolicy> onPolicyChanged;
  final ValueChanged<UpdateNetworkMode> onNetworkModeChanged;
  final ValueChanged<String> onManualProxySaved;
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    final busy =
        saving ||
        state.status == UpdateControllerStatus.checking ||
        state.status == UpdateControllerStatus.downloading ||
        state.status == UpdateControllerStatus.installing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SegmentedSetting<UpdatePolicy>(
          title: '更新策略',
          description: '自动更新会在启动后检测并下载；手动更新只在点击检查时联网',
          selected: state.settings.policy,
          enabled: !busy,
          segments: const [
            ButtonSegment(value: UpdatePolicy.automatic, label: Text('自动更新')),
            ButtonSegment(value: UpdatePolicy.manual, label: Text('手动更新')),
            ButtonSegment(value: UpdatePolicy.disabled, label: Text('禁止更新')),
          ],
          onChanged: onPolicyChanged,
        ),
        const _SettingDivider(),
        _SegmentedSetting<UpdateNetworkMode>(
          title: '更新网络',
          description: '自动检测代理找不到可用代理时会改用直连',
          selected: state.settings.networkMode,
          enabled: !busy,
          segments: const [
            ButtonSegment(
              value: UpdateNetworkMode.automaticProxy,
              label: Text('自动代理'),
            ),
            ButtonSegment(
              value: UpdateNetworkMode.manualProxy,
              label: Text('手动代理'),
            ),
            ButtonSegment(value: UpdateNetworkMode.direct, label: Text('直连')),
          ],
          onChanged: onNetworkModeChanged,
        ),
        if (state.settings.networkMode == UpdateNetworkMode.manualProxy) ...[
          SizedBox(height: context.tokens.spacing.md),
          TextFormField(
            key: ValueKey(state.settings.manualProxyUrl),
            initialValue: state.settings.manualProxyUrl,
            enabled: !busy,
            decoration: const InputDecoration(
              labelText: '手动代理地址',
              hintText: 'http://127.0.0.1:7890',
              helperText: '支持 HTTP、HTTPS、SOCKS4 与 SOCKS5，回车保存',
            ),
            onFieldSubmitted: onManualProxySaved,
          ),
        ],
        const _SettingDivider(),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: busy || !state.settings.allowsManualCheck
                ? null
                : onCheck,
            icon: const Icon(Icons.system_update_alt_rounded),
            label: Text(
              state.status == UpdateControllerStatus.checking
                  ? '正在检查'
                  : state.status == UpdateControllerStatus.downloading
                  ? '正在下载'
                  : '检查更新',
            ),
          ),
        ),
        if (state.message != null) ...[
          SizedBox(height: context.tokens.spacing.sm),
          Text(
            state.message!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: state.status == UpdateControllerStatus.error
                  ? context.tokens.colors.danger
                  : context.tokens.colors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.only(left: context.tokens.spacing.xs),
        child: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      SizedBox(height: context.tokens.spacing.sm),
      AppCard(
        padding: EdgeInsets.all(context.tokens.spacing.md),
        child: Column(children: children),
      ),
    ],
  );
}

class _SegmentedSetting<T> extends StatelessWidget {
  const _SegmentedSetting({
    required this.title,
    required this.selected,
    required this.enabled,
    required this.segments,
    required this.onChanged,
    this.description,
  });

  final String title;
  final String? description;
  final T selected;
  final bool enabled;
  final List<ButtonSegment<T>> segments;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
      if (description != null) ...[
        SizedBox(height: context.tokens.spacing.xs),
        Text(
          description!,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.tokens.colors.textSecondary,
          ),
        ),
      ],
      SizedBox(height: context.tokens.spacing.sm),
      SizedBox(
        width: double.infinity,
        child: AppSegmentedControl<T>(
          segments: segments,
          selected: {selected},
          onSelectionChanged: enabled
              ? (selection) => onChanged(selection.single)
              : null,
        ),
      ),
    ],
  );
}

class _SwitchSetting extends StatelessWidget {
  const _SwitchSetting({
    required this.title,
    required this.description,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String title;
  final String description;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: context.tokens.spacing.xs),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.tokens.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      SizedBox(width: context.tokens.spacing.md),
      Switch.adaptive(value: value, onChanged: enabled ? onChanged : null),
    ],
  );
}

class _SliderSetting extends StatelessWidget {
  const _SliderSetting({
    required this.title,
    required this.value,
    required this.enabled,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final String title;
  final double value;
  final bool enabled;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Text('${(value * 100).round()}%'),
        ],
      ),
      Slider(
        value: value,
        min: 0.7,
        max: 1,
        divisions: 6,
        label: '${(value * 100).round()}%',
        onChanged: enabled ? onChanged : null,
        onChangeEnd: enabled ? onChangeEnd : null,
      ),
    ],
  );
}

class _LinkSetting extends StatelessWidget {
  const _LinkSetting({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    minTileHeight: context.tokens.sizes.minTouch,
    leading: Icon(icon),
    title: Text(title),
    trailing: const Icon(Icons.chevron_right_rounded),
    onTap: onTap,
  );
}

class _SettingDivider extends StatelessWidget {
  const _SettingDivider();

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: context.tokens.spacing.md),
    child: Divider(height: 1, color: context.tokens.colors.border),
  );
}
