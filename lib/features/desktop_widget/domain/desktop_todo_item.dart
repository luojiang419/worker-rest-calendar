import 'dart:convert';

final class DesktopTodoItem {
  const DesktopTodoItem({
    required this.id,
    required this.title,
    this.completed = false,
  });

  final String id;
  final String title;
  final bool completed;

  DesktopTodoItem copyWith({String? title, bool? completed}) => DesktopTodoItem(
    id: id,
    title: title ?? this.title,
    completed: completed ?? this.completed,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'completed': completed,
  };

  static List<DesktopTodoItem> decodeList(String source) {
    try {
      final decoded = jsonDecode(source);
      if (decoded is! List<Object?>) return const [];
      return decoded
          .whereType<Map<String, Object?>>()
          .map((item) {
            final id = item['id'];
            final title = item['title'];
            final completed = item['completed'];
            if (id is! String || title is! String || completed is! bool) {
              return null;
            }
            final normalized = title.trim();
            if (normalized.isEmpty) return null;
            return DesktopTodoItem(
              id: id,
              title: normalized,
              completed: completed,
            );
          })
          .whereType<DesktopTodoItem>()
          .take(8)
          .toList(growable: false);
    } on FormatException {
      return const [];
    }
  }

  static String encodeList(List<DesktopTodoItem> items) => jsonEncode(
    items.take(8).map((item) => item.toJson()).toList(growable: false),
  );
}
