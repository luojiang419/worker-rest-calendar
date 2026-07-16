import 'package:flutter/material.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';

class AppSegmentedControl<T> extends StatelessWidget {
  const AppSegmentedControl({
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
    super.key,
    this.emptySelectionAllowed = false,
  });

  final List<ButtonSegment<T>> segments;
  final Set<T> selected;
  final ValueChanged<Set<T>>? onSelectionChanged;
  final bool emptySelectionAllowed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: EdgeInsets.all(tokens.spacing.xs),
      decoration: BoxDecoration(
        color: tokens.colors.surface,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: tokens.colors.border),
        boxShadow: tokens.shadows.low,
      ),
      child: SegmentedButton<T>(
        segments: segments,
        selected: selected,
        onSelectionChanged: onSelectionChanged,
        emptySelectionAllowed: emptySelectionAllowed,
        showSelectedIcon: false,
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(
            Size(tokens.sizes.minTouch, tokens.sizes.minTouch),
          ),
          tapTargetSize: MaterialTapTargetSize.padded,
          visualDensity: VisualDensity.compact,
          side: const WidgetStatePropertyAll(BorderSide.none),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(tokens.radius.sm),
            ),
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? tokens.colors.primary
                : tokens.colors.textSecondary,
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? tokens.colors.primary.withValues(alpha: 0.12)
                : Colors.transparent,
          ),
        ),
      ),
    );
  }
}
