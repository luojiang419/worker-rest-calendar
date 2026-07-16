import 'package:flutter/material.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/core/theme/app_visual_style.dart';
import 'package:worker_rest_calendar/core/widgets/app_bottom_sheet.dart';
import 'package:worker_rest_calendar/core/widgets/app_segmented_control.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

Future<void> showThemePickerSheet({
  required BuildContext context,
  required AppPreferences preferences,
  required ValueChanged<AppPreferences> onChanged,
}) => showAppBottomSheet<void>(
  context: context,
  builder: (sheetContext) =>
      _ThemePicker(initialPreferences: preferences, onChanged: onChanged),
);

class _ThemePicker extends StatefulWidget {
  const _ThemePicker({
    required this.initialPreferences,
    required this.onChanged,
  });

  final AppPreferences initialPreferences;
  final ValueChanged<AppPreferences> onChanged;

  @override
  State<_ThemePicker> createState() => _ThemePickerState();
}

class _ThemePickerState extends State<_ThemePicker> {
  late AppPreferences _preferences = widget.initialPreferences;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.78;
    return SizedBox(
      height: maxHeight.clamp(420.0, 680.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: tokens.colors.textSecondary.withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(tokens.radius.pill),
              ),
            ),
          ),
          SizedBox(height: tokens.spacing.lg),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '选择主题',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: tokens.spacing.xs),
                    Text(
                      '外观模式和视觉风格可以自由组合',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: tokens.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: '关闭主题选择',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.lg),
          AppSegmentedControl<AppThemePreference>(
            segments: const [
              ButtonSegment(
                value: AppThemePreference.system,
                icon: Icon(Icons.brightness_auto_outlined),
                label: Text('跟随'),
              ),
              ButtonSegment(
                value: AppThemePreference.light,
                icon: Icon(Icons.light_mode_outlined),
                label: Text('浅色'),
              ),
              ButtonSegment(
                value: AppThemePreference.dark,
                icon: Icon(Icons.dark_mode_outlined),
                label: Text('暗色'),
              ),
            ],
            selected: {_preferences.themeMode},
            onSelectionChanged: (selection) =>
                _update(_preferences.copyWith(themeMode: selection.single)),
          ),
          SizedBox(height: tokens.spacing.lg),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.only(bottom: tokens.spacing.sm),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.sizeOf(context).width >= 620 ? 2 : 1,
                mainAxisExtent: 116,
                crossAxisSpacing: tokens.spacing.md,
                mainAxisSpacing: tokens.spacing.md,
              ),
              itemCount: AppVisualStyle.values.length,
              itemBuilder: (context, index) {
                final style = AppVisualStyle.values[index];
                return _StyleTile(
                  style: style,
                  selected: style == _preferences.visualStyle,
                  onTap: () =>
                      _update(_preferences.copyWith(visualStyle: style)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _update(AppPreferences value) {
    setState(() => _preferences = value);
    widget.onChanged(value);
  }
}

class _StyleTile extends StatelessWidget {
  const _StyleTile({
    required this.style,
    required this.selected,
    required this.onTap,
  });

  final AppVisualStyle style;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final preview = AppTokens.resolve(style, Theme.of(context).brightness);
    final radius = BorderRadius.circular(tokens.radius.md);
    return Semantics(
      button: true,
      selected: selected,
      label: '${style.label}，${style.description}',
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: AnimatedContainer(
            duration: tokens.motion.fast,
            padding: EdgeInsets.all(tokens.spacing.md),
            decoration: BoxDecoration(
              color: preview.colors.background,
              borderRadius: radius,
              border: Border.all(
                color: selected ? tokens.colors.primary : preview.colors.border,
                width: selected ? 2 : 1,
              ),
              boxShadow: selected ? tokens.shadows.low : const [],
            ),
            child: Row(
              children: [
                _StyleSwatch(tokens: preview),
                SizedBox(width: tokens.spacing.md),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        style.label,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: tokens.spacing.xs),
                      Text(
                        style.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: tokens.colors.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StyleSwatch extends StatelessWidget {
  const _StyleSwatch({required this.tokens});

  final AppTokens tokens;

  @override
  Widget build(BuildContext context) => Container(
    width: 62,
    height: 72,
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: tokens.colors.surface,
      borderRadius: BorderRadius.circular(tokens.radius.sm),
      border: tokens.borderWidth == 0
          ? null
          : Border.all(color: tokens.colors.border, width: tokens.borderWidth),
      boxShadow: tokens.shadows.low,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 7,
          decoration: BoxDecoration(
            color: tokens.colors.primary,
            borderRadius: BorderRadius.circular(tokens.radius.pill),
          ),
        ),
        const Spacer(),
        Row(
          children: [
            _dot(tokens.colors.rest),
            const SizedBox(width: 4),
            _dot(tokens.colors.adjustedWork),
            const SizedBox(width: 4),
            _dot(tokens.colors.leave),
          ],
        ),
      ],
    ),
  );

  Widget _dot(Color color) => Container(
    width: 8,
    height: 8,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
