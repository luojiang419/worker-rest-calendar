import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/core/theme/theme_controller.dart';
import 'package:worker_rest_calendar/core/widgets/app_widgets.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';

class ComponentGalleryPage extends ConsumerWidget {
  const ComponentGalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final themeMode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('设计系统'),
        backgroundColor: tokens.colors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.sizeOf(context).width >= 720
                ? tokens.sizes.desktopHorizontalPadding
                : tokens.sizes.mobileHorizontalPadding,
            vertical: tokens.spacing.lg,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '工作日历',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: tokens.spacing.xs),
                  Text(
                    '统一组件与主题预览',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: tokens.colors.textSecondary,
                    ),
                  ),
                  SizedBox(height: tokens.spacing.xl),
                  _GallerySection(
                    title: '主题',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppSegmentedControl<ThemeMode>(
                          segments: _themeSegments,
                          selected: {themeMode},
                          onSelectionChanged: (selection) => ref
                              .read(themeModeProvider.notifier)
                              .setThemeMode(selection.single),
                        ),
                        SizedBox(height: tokens.spacing.sm),
                        const AppSegmentedControl<ThemeMode>(
                          segments: _themeSegments,
                          selected: {ThemeMode.system},
                          onSelectionChanged: null,
                        ),
                      ],
                    ),
                  ),
                  _gap(tokens),
                  _GallerySection(
                    title: '按钮',
                    child: Wrap(
                      spacing: tokens.spacing.md,
                      runSpacing: tokens.spacing.md,
                      children: [
                        AppButton.primary(
                          label: '保存设置',
                          icon: Icons.check_rounded,
                          onPressed: () {},
                        ),
                        AppButton.secondary(label: '稍后再说', onPressed: () {}),
                        AppButton.danger(
                          label: '删除调整',
                          icon: Icons.delete_outline_rounded,
                          onPressed: () {},
                        ),
                        const AppButton.primary(
                          label: '主按钮不可用',
                          onPressed: null,
                        ),
                        const AppButton.secondary(
                          label: '次按钮不可用',
                          onPressed: null,
                        ),
                        const AppButton.danger(
                          label: '危险按钮不可用',
                          onPressed: null,
                        ),
                      ],
                    ),
                  ),
                  _gap(tokens),
                  _GallerySection(
                    title: '日期状态',
                    child: Wrap(
                      spacing: tokens.spacing.sm,
                      runSpacing: tokens.spacing.sm,
                      children: DayKind.values
                          .map((kind) => AppStatusChip(kind: kind))
                          .toList(growable: false),
                    ),
                  ),
                  _gap(tokens),
                  _GallerySection(
                    title: '日期胶囊',
                    child: Wrap(
                      spacing: tokens.spacing.sm,
                      runSpacing: tokens.spacing.sm,
                      children: [
                        AppDatePill(
                          date: CalendarDate(2026, 7, 18),
                          kind: DayKind.work,
                          onTap: () {},
                        ),
                        AppDatePill(
                          date: CalendarDate(2026, 7, 19),
                          kind: DayKind.rest,
                          selected: true,
                          onTap: () {},
                        ),
                        AppDatePill(
                          date: CalendarDate(2026, 7, 20),
                          kind: DayKind.adjustedRest,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  _gap(tokens),
                  _GallerySection(
                    title: '卡片层级',
                    child: Column(
                      children: [
                        const AppCard(
                          shadowLevel: AppShadowLevel.low,
                          child: _CardExample(
                            title: '本周节奏',
                            message: '周一至周五上班，周末休息',
                          ),
                        ),
                        SizedBox(height: tokens.spacing.lg),
                        const AppCard(
                          shadowLevel: AppShadowLevel.high,
                          child: _CardExample(
                            title: '今天休息',
                            message: '距离下个休息日 0 天',
                          ),
                        ),
                      ],
                    ),
                  ),
                  _gap(tokens),
                  _GallerySection(
                    title: '反馈',
                    child: Wrap(
                      spacing: tokens.spacing.md,
                      runSpacing: tokens.spacing.md,
                      children: [
                        AppButton.secondary(
                          label: '显示 Toast',
                          onPressed: () =>
                              showAppToast(context, message: '设置已保存'),
                        ),
                        AppButton.secondary(
                          label: '打开底部弹层',
                          onPressed: () => _showExampleSheet(context, tokens),
                        ),
                      ],
                    ),
                  ),
                  _gap(tokens),
                  const _GallerySection(
                    title: '加载状态',
                    child: AppLoadingState(),
                  ),
                  _gap(tokens),
                  _GallerySection(
                    title: '空状态',
                    child: AppEmptyState(
                      title: '还没有设置班制',
                      message: '先选一个工作节奏，日历就会自动生成',
                      actionLabel: '选择班制',
                      onAction: () {},
                    ),
                  ),
                  _gap(tokens),
                  _GallerySection(
                    title: '错误状态',
                    child: AppErrorState(
                      title: '暂时无法读取数据',
                      message: '本地数据没有丢失，请稍后重试',
                      onRetry: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showExampleSheet(BuildContext context, AppTokens tokens) {
    return showAppBottomSheet<void>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('修改当天状态', style: Theme.of(sheetContext).textTheme.titleLarge),
          SizedBox(height: tokens.spacing.sm),
          Text(
            '单日调整优先于节假日和基础班制。',
            style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
              color: tokens.colors.textSecondary,
            ),
          ),
          SizedBox(height: tokens.spacing.xl),
          AppButton.primary(
            label: '知道了',
            expand: true,
            onPressed: () => Navigator.pop(sheetContext),
          ),
        ],
      ),
    );
  }

  Widget _gap(AppTokens tokens) => SizedBox(height: tokens.spacing.lg);

  static const _themeSegments = [
    ButtonSegment(value: ThemeMode.system, label: Text('跟随系统')),
    ButtonSegment(value: ThemeMode.light, label: Text('浅色')),
    ButtonSegment(value: ThemeMode.dark, label: Text('暗黑')),
  ];
}

class _GallerySection extends StatelessWidget {
  const _GallerySection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return AppCard(
      shadowLevel: AppShadowLevel.low,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: tokens.spacing.md),
          child,
        ],
      ),
    );
  }
}

class _CardExample extends StatelessWidget {
  const _CardExample({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: tokens.spacing.xs),
        Text(
          message,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: tokens.colors.textSecondary),
        ),
      ],
    );
  }
}
