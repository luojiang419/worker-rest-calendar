import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/core/theme/app_theme.dart';
import 'package:worker_rest_calendar/core/widgets/app_button.dart';
import 'package:worker_rest_calendar/core/widgets/app_date_pill.dart';
import 'package:worker_rest_calendar/features/design_system/presentation/component_gallery_page.dart';

void main() {
  testWidgets('组件展示页在 130% 字体下无核心溢出', (tester) async {
    await _pumpGallery(tester, textScale: 1.3);

    expect(tester.takeException(), isNull);
    await tester.dragUntilVisible(
      find.text('错误状态'),
      find.byType(SingleChildScrollView),
      const Offset(0, -500),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('暂时无法读取数据'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('交互组件点击区域不小于 44x44', (tester) async {
    await _pumpGallery(tester);

    final buttonSize = tester.getSize(find.byType(AppButton).first);
    final datePillSize = tester.getSize(find.byType(AppDatePill).first);
    expect(buttonSize.height, greaterThanOrEqualTo(44));
    expect(buttonSize.width, greaterThanOrEqualTo(44));
    expect(datePillSize.height, greaterThanOrEqualTo(44));
    expect(datePillSize.width, greaterThanOrEqualTo(44));
  });

  testWidgets('状态标签提供明确语义且不只依赖颜色', (tester) async {
    await _pumpGallery(tester);

    for (final label in ['工作', '休息', '调休上班', '调休休息', '请假']) {
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Semantics && widget.properties.label == label,
        ),
        findsAtLeastNWidgets(1),
        reason: label,
      );
    }
  });

  testWidgets('Toast 与底部弹层可正常展示', (tester) async {
    await _pumpGallery(tester);
    await tester.dragUntilVisible(
      find.text('显示 Toast'),
      find.byType(SingleChildScrollView),
      const Offset(0, -400),
    );

    await tester.tap(find.text('显示 Toast'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('设置已保存'), findsOneWidget);

    await tester.tap(find.text('打开底部弹层'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('修改当天状态'), findsOneWidget);
    expect(find.text('单日调整优先于节假日和基础班制。'), findsOneWidget);
  });
}

Future<void> _pumpGallery(WidgetTester tester, {double textScale = 1}) async {
  await tester.binding.setSurfaceSize(const Size(430, 932));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light,
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: const ComponentGalleryPage(),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 400));
}
