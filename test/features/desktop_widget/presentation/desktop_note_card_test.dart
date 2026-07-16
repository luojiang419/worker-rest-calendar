import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/core/theme/app_theme.dart';
import 'package:worker_rest_calendar/features/desktop_widget/presentation/desktop_note_card.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

void main() {
  testWidgets('记事本防抖保存且正文编辑不会触发窗口拖动', (tester) async {
    var saved = '';
    var dragCount = 0;
    await _pumpNote(
      tester,
      size: DesktopWidgetSize.medium,
      note: '原内容',
      onChanged: (value) => saved = value,
      onStartDragging: () => dragCount++,
      saveDelay: const Duration(milliseconds: 500),
    );

    await tester.enterText(
      find.byKey(const ValueKey('desktop-note-editor')),
      '新的桌面便笺',
    );
    await tester.pump(const Duration(milliseconds: 499));
    expect(saved, isEmpty);
    await tester.pump(const Duration(milliseconds: 1));
    expect(saved, '新的桌面便笺');
    expect(dragCount, 0);

    await tester.drag(
      find.byKey(const ValueKey('desktop-note-drag-handle')),
      const Offset(20, 0),
    );
    expect(dragCount, 1);
  });

  testWidgets('锁定位置后拖动手柄不移动但正文仍可编辑', (tester) async {
    var saved = '';
    var dragCount = 0;
    await _pumpNote(
      tester,
      size: DesktopWidgetSize.medium,
      note: '',
      locked: true,
      saveDelay: Duration.zero,
      onChanged: (value) => saved = value,
      onStartDragging: () => dragCount++,
    );

    await tester.drag(
      find.byKey(const ValueKey('desktop-note-drag-handle')),
      const Offset(20, 0),
    );
    expect(dragCount, 0);
    await tester.enterText(
      find.byKey(const ValueKey('desktop-note-editor')),
      '锁定后仍能编辑',
    );
    await tester.pump();
    expect(saved, '锁定后仍能编辑');
  });

  testWidgets('记事本三种尺寸与 130% 字体下无溢出', (tester) async {
    for (final size in DesktopWidgetSize.values) {
      await _pumpNote(
        tester,
        size: size,
        note: '今天完成发布检查\n明天整理需求',
        textScale: 1.3,
      );
      expect(tester.takeException(), isNull, reason: size.name);
    }
  });
}

Future<void> _pumpNote(
  WidgetTester tester, {
  required DesktopWidgetSize size,
  required String note,
  ValueChanged<String>? onChanged,
  VoidCallback? onStartDragging,
  bool locked = false,
  double textScale = 1,
  Duration saveDelay = const Duration(milliseconds: 500),
}) async {
  final dimensions = switch (size) {
    DesktopWidgetSize.small => const Size(180, 220),
    DesktopWidgetSize.medium => const Size(360, 220),
    DesktopWidgetSize.large => const Size(420, 360),
  };
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = dimensions;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: dimensions,
        textScaler: TextScaler.linear(textScale),
      ),
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: DesktopNoteCard(
            note: note,
            size: size,
            positionLocked: locked,
            onChanged: onChanged ?? (_) {},
            onStartDragging: onStartDragging ?? () {},
            saveDelay: saveDelay,
          ),
        ),
      ),
    ),
  );
}
