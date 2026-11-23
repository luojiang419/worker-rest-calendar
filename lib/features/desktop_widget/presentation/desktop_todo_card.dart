import 'package:flutter/material.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/features/desktop_widget/domain/desktop_todo_item.dart';
import 'package:worker_rest_calendar/features/desktop_widget/presentation/desktop_widget_frame.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

class DesktopTodoCard extends StatefulWidget {
  const DesktopTodoCard({
    required this.items,
    required this.size,
    required this.positionLocked,
    required this.onStartDragging,
    required this.onChanged,
    super.key,
  });

  final List<DesktopTodoItem> items;
  final DesktopWidgetSize size;
  final bool positionLocked;
  final VoidCallback onStartDragging;
  final ValueChanged<List<DesktopTodoItem>> onChanged;

  @override
  State<DesktopTodoCard> createState() => _DesktopTodoCardState();
}

class _DesktopTodoCardState extends State<DesktopTodoCard> {
  late List<DesktopTodoItem> _items;
  final _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _items = [...widget.items];
  }

  @override
  void didUpdateWidget(covariant DesktopTodoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) _items = [...widget.items];
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _save(List<DesktopTodoItem> value) {
    setState(() => _items = value);
    widget.onChanged(List.unmodifiable(value));
  }

  void _add() {
    final title = _inputController.text.trim();
    if (title.isEmpty || _items.length >= 8) return;
    _inputController.clear();
    _save([
      ..._items,
      DesktopTodoItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final compact = widget.size == DesktopWidgetSize.small;
    final visibleCount = compact
        ? 3
        : widget.size == DesktopWidgetSize.medium
        ? 4
        : 6;
    final completed = _items.where((item) => item.completed).length;
    return DesktopWidgetFrame(
      size: widget.size,
      cardKey: ValueKey('desktop-todo-card-${tokens.visualStyle.name}'),
      shadowSafeAreaKey: const ValueKey('desktop-todo-shadow-safe-area'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MouseRegion(
                cursor: widget.positionLocked
                    ? SystemMouseCursors.basic
                    : SystemMouseCursors.move,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: widget.positionLocked
                      ? null
                      : (_) => widget.onStartDragging(),
                  child: Padding(
                    padding: EdgeInsets.all(tokens.spacing.xs),
                    child: const Icon(Icons.drag_indicator_rounded, size: 18),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  '待办清单',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '$completed/${_items.length}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: tokens.colors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.xs),
          Expanded(
            child: _items.isEmpty
                ? Center(
                    child: Text(
                      '今天想完成什么？',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.colors.textSecondary,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _items.length.clamp(0, visibleCount),
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return SizedBox(
                        height: compact ? 31 : 34,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 30,
                              child: Checkbox(
                                value: item.completed,
                                visualDensity: VisualDensity.compact,
                                onChanged: (value) {
                                  final next = [..._items];
                                  next[index] = item.copyWith(
                                    completed: value ?? false,
                                  );
                                  _save(next);
                                },
                              ),
                            ),
                            Expanded(
                              child: Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      decoration: item.completed
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: item.completed
                                          ? tokens.colors.textSecondary
                                          : tokens.colors.textPrimary,
                                    ),
                              ),
                            ),
                            if (!compact)
                              IconButton(
                                tooltip: '删除',
                                visualDensity: VisualDensity.compact,
                                onPressed: () {
                                  final next = [..._items]..removeAt(index);
                                  _save(next);
                                },
                                icon: const Icon(Icons.close_rounded, size: 16),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          SizedBox(height: tokens.spacing.xs),
          SizedBox(
            height: 38,
            child: TextField(
              key: const ValueKey('desktop-todo-input'),
              controller: _inputController,
              enabled: _items.length < 8,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _add(),
              decoration: InputDecoration(
                hintText: _items.length >= 8 ? '最多 8 项' : '添加待办…',
                contentPadding: EdgeInsets.only(left: tokens.spacing.sm),
                suffixIcon: IconButton(
                  tooltip: '添加',
                  onPressed: _items.length < 8 ? _add : null,
                  icon: const Icon(Icons.add_rounded, size: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
