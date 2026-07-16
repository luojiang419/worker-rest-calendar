import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/features/desktop_widget/presentation/desktop_widget_frame.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

const desktopNoteMaxLength = 4000;

class DesktopNoteCard extends StatefulWidget {
  const DesktopNoteCard({
    required this.note,
    required this.size,
    required this.onChanged,
    required this.onStartDragging,
    required this.positionLocked,
    this.saveDelay = const Duration(milliseconds: 500),
    super.key,
  });

  final String note;
  final DesktopWidgetSize size;
  final ValueChanged<String> onChanged;
  final VoidCallback onStartDragging;
  final bool positionLocked;
  final Duration saveDelay;

  @override
  State<DesktopNoteCard> createState() => _DesktopNoteCardState();
}

class _DesktopNoteCardState extends State<DesktopNoteCard> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  Timer? _saveTimer;
  String? _pendingValue;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.note);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant DesktopNoteCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.note != oldWidget.note &&
        widget.note != _controller.text &&
        !_focusNode.hasFocus) {
      _controller.value = TextEditingValue(
        text: widget.note,
        selection: TextSelection.collapsed(offset: widget.note.length),
      );
      _pendingValue = null;
    }
  }

  void _scheduleSave(String value) {
    setState(() => _pendingValue = value);
    _saveTimer?.cancel();
    _saveTimer = Timer(widget.saveDelay, _flushSave);
  }

  void _flushSave() {
    _saveTimer?.cancel();
    _saveTimer = null;
    final value = _pendingValue;
    if (value == null) return;
    _pendingValue = null;
    widget.onChanged(value);
  }

  @override
  void dispose() {
    _flushSave();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final compact = widget.size == DesktopWidgetSize.small;
    final length = _controller.text.characters.length;
    return DesktopWidgetFrame(
      size: widget.size,
      cardKey: ValueKey('desktop-note-card-${tokens.visualStyle.name}'),
      shadowSafeAreaKey: const ValueKey('desktop-note-shadow-safe-area'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MouseRegion(
            cursor: widget.positionLocked
                ? SystemMouseCursors.basic
                : SystemMouseCursors.move,
            child: GestureDetector(
              key: const ValueKey('desktop-note-drag-handle'),
              behavior: HitTestBehavior.opaque,
              onPanStart: widget.positionLocked
                  ? null
                  : (_) => widget.onStartDragging(),
              child: Row(
                children: [
                  Icon(
                    Icons.drag_indicator_rounded,
                    size: 18,
                    color: tokens.colors.textSecondary,
                  ),
                  SizedBox(width: tokens.spacing.xs),
                  Expanded(
                    child: Text(
                      '快速记事',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    _pendingValue == null
                        ? Icons.cloud_done_outlined
                        : Icons.more_horiz_rounded,
                    size: 16,
                    color: tokens.colors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: tokens.spacing.sm),
          Expanded(
            child: TextField(
              key: const ValueKey('desktop-note-editor'),
              controller: _controller,
              focusNode: _focusNode,
              expands: true,
              minLines: null,
              maxLines: null,
              textAlignVertical: TextAlignVertical.top,
              inputFormatters: [
                LengthLimitingTextInputFormatter(desktopNoteMaxLength),
              ],
              decoration: InputDecoration(
                hintText: compact ? '记点什么…' : '写下待办、灵感或临时信息…',
                filled: true,
                fillColor: tokens.colors.surfaceElevated,
                contentPadding: EdgeInsets.all(tokens.spacing.sm),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tokens.radius.sm),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tokens.radius.sm),
                  borderSide: BorderSide(
                    color: tokens.colors.border,
                    width: tokens.borderWidth,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tokens.radius.sm),
                  borderSide: BorderSide(
                    color: tokens.colors.primary,
                    width: tokens.borderWidth == 0 ? 1 : tokens.borderWidth,
                  ),
                ),
              ),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.45),
              onChanged: _scheduleSave,
            ),
          ),
          if (!compact) ...[
            SizedBox(height: tokens.spacing.xs),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '自动保存 · $length/$desktopNoteMaxLength',
                key: const ValueKey('desktop-note-counter'),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: tokens.colors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
