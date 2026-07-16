import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/core/theme/app_theme.dart';
import 'package:worker_rest_calendar/features/design_system/presentation/component_gallery_page.dart';

void main() {
  testWidgets('组件展示页浅色 golden', (tester) async {
    await _pumpGolden(tester, AppTheme.light);

    await expectLater(
      find.byType(ComponentGalleryPage),
      matchesGoldenFile('goldens/component_gallery_light.png'),
    );
  });

  testWidgets('组件展示页暗黑 golden', (tester) async {
    await _pumpGolden(tester, AppTheme.dark);

    await expectLater(
      find.byType(ComponentGalleryPage),
      matchesGoldenFile('goldens/component_gallery_dark.png'),
    );
  });
}

Future<void> _pumpGolden(WidgetTester tester, ThemeData theme) async {
  await tester.binding.setSurfaceSize(const Size(430, 932));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: const ComponentGalleryPage(),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 400));
}
