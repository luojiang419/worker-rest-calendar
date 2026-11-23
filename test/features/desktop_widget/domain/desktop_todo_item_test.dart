import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/features/desktop_widget/domain/desktop_todo_item.dart';

void main() {
  test('待办列表可往返编码并保留完成状态', () {
    const items = [
      DesktopTodoItem(id: '1', title: '提交周报'),
      DesktopTodoItem(id: '2', title: '预订车票', completed: true),
    ];

    final decoded = DesktopTodoItem.decodeList(
      DesktopTodoItem.encodeList(items),
    );

    expect(decoded, hasLength(2));
    expect(decoded.last.completed, isTrue);
  });

  test('损坏数据安全降级且最多保留八项', () {
    expect(DesktopTodoItem.decodeList('{bad'), isEmpty);
    final items = List.generate(
      10,
      (index) => DesktopTodoItem(id: '$index', title: '事项 $index'),
    );
    expect(
      DesktopTodoItem.decodeList(DesktopTodoItem.encodeList(items)),
      hasLength(8),
    );
  });
}
