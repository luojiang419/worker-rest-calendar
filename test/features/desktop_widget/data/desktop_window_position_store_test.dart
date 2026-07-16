import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker_rest_calendar/features/desktop_widget/data/desktop_window_position_store.dart';
import 'package:worker_rest_calendar/features/desktop_widget/domain/desktop_window_placement.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const store = DesktopWindowPositionStore();
  const placement = DesktopWindowPlacement(
    horizontal: DesktopWindowAxisPlacement(
      anchor: DesktopWindowAnchor.endEdge,
      value: 24,
    ),
    vertical: DesktopWindowAxisPlacement(
      anchor: DesktopWindowAnchor.proportional,
      value: 0.4,
    ),
  );

  setUp(() => SharedPreferences.setMockInitialValues(const {}));

  test('V2 按显示器保存锚点与比例并恢复最后使用项', () async {
    await store.savePlacement('display-a', placement);

    final loaded = await store.loadLastPlacement(migrateLegacy: (_, _) => null);

    expect(loaded?.displayId, 'display-a');
    expect(loaded?.placement.horizontal.anchor, DesktopWindowAnchor.endEdge);
    expect(loaded?.placement.horizontal.value, 24);
    expect(loaded?.placement.vertical.anchor, DesktopWindowAnchor.proportional);
    expect(loaded?.placement.vertical.value, 0.4);

    final preferences = await SharedPreferences.getInstance();
    final raw =
        jsonDecode(preferences.getString('desktop_widget_placements_v2')!)
            as Map<String, dynamic>;
    expect(raw['display-a']['schemaVersion'], 2);
    expect(raw['display-a']['horizontal']['anchor'], 'endEdge');
  });

  test('不同显示器分别保存且最后使用显示器随保存更新', () async {
    await store.savePlacement('display-a', placement);
    await store.savePlacement(
      'display-b',
      const DesktopWindowPlacement(
        horizontal: DesktopWindowAxisPlacement(
          anchor: DesktopWindowAnchor.startEdge,
          value: 16,
        ),
        vertical: DesktopWindowAxisPlacement(
          anchor: DesktopWindowAnchor.startEdge,
          value: 20,
        ),
      ),
    );

    final displayA = await store.loadPlacement(
      'display-a',
      migrateLegacy: (_, _) => null,
    );
    final last = await store.loadLastPlacement(migrateLegacy: (_, _) => null);

    expect(displayA?.horizontal.anchor, DesktopWindowAnchor.endEdge);
    expect(displayA?.horizontal.value, 24);
    expect(last?.displayId, 'display-b');
    expect(last?.placement.horizontal.value, 16);
  });

  test('首次读取 V1 坐标时迁移为 V2 且以后不重复迁移', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'desktop_widget_positions_v1': jsonEncode(<String, Object>{
        'display-a': <String, double>{'dx': 1716, 'dy': 796},
      }),
      'desktop_widget_last_display_v1': 'display-a',
    });
    var migrationCount = 0;
    DesktopWindowPlacement? migrate(
      String displayId,
      DesktopWindowPosition position,
    ) {
      migrationCount += 1;
      expect(displayId, 'display-a');
      return DesktopWindowPlacement.capture(
        position: position,
        windowSize: const DesktopWindowSize(180, 220),
        workArea: const DesktopWindowWorkArea(
          left: 0,
          top: 0,
          width: 1920,
          height: 1040,
        ),
      );
    }

    final migrated = await store.loadLastPlacement(migrateLegacy: migrate);
    final loadedAgain = await store.loadLastPlacement(
      migrateLegacy: (displayId, position) {
        migrationCount += 1;
        return null;
      },
    );

    expect(migrationCount, 1);
    expect(migrated?.placement.horizontal.anchor, DesktopWindowAnchor.endEdge);
    expect(migrated?.placement.horizontal.value, 24);
    expect(loadedAgain?.placement.horizontal.value, 24);

    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getString('desktop_widget_placements_v2'),
      contains('display-a'),
    );
    expect(
      preferences.getString('desktop_widget_last_display_v2'),
      'display-a',
    );
  });

  test('指定显示器可独立迁移且不改变最后使用显示器', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'desktop_widget_positions_v1': jsonEncode(<String, Object>{
        'display-a': <String, double>{'dx': 20, 'dy': 30},
        'display-b': <String, double>{'dx': 40, 'dy': 50},
      }),
      'desktop_widget_last_display_v1': 'display-a',
    });

    final migrated = await store.loadPlacement(
      'display-b',
      migrateLegacy: (_, position) => DesktopWindowPlacement.capture(
        position: position,
        windowSize: const DesktopWindowSize(180, 220),
        workArea: const DesktopWindowWorkArea(
          left: 0,
          top: 0,
          width: 1920,
          height: 1040,
        ),
      ),
    );

    expect(migrated?.horizontal.value, 40);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('desktop_widget_last_display_v2'), isNull);
  });

  test('损坏的 V2 数据回退到有效 V1 坐标迁移', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'desktop_widget_placements_v2': jsonEncode(<String, Object>{
        'display-a': <String, Object>{
          'schemaVersion': 2,
          'horizontal': <String, Object>{'anchor': 'proportional', 'value': 8},
          'vertical': <String, Object>{'anchor': 'startEdge', 'value': 12},
        },
      }),
      'desktop_widget_last_display_v2': 'display-a',
      'desktop_widget_positions_v1': jsonEncode(<String, Object>{
        'display-a': <String, double>{'dx': 24, 'dy': 32},
      }),
    });

    final loaded = await store.loadLastPlacement(
      migrateLegacy: (_, position) => DesktopWindowPlacement.capture(
        position: position,
        windowSize: const DesktopWindowSize(180, 220),
        workArea: const DesktopWindowWorkArea(
          left: 0,
          top: 0,
          width: 1920,
          height: 1040,
        ),
      ),
    );

    expect(loaded?.placement.horizontal.anchor, DesktopWindowAnchor.startEdge);
    expect(loaded?.placement.horizontal.value, 24);
  });

  test('损坏 JSON 和无效 V1 坐标安全返回空结果', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'desktop_widget_placements_v2': '{invalid',
      'desktop_widget_last_display_v2': 'display-a',
      'desktop_widget_positions_v1': jsonEncode(<String, Object>{
        'display-a': <String, Object>{'dx': 'wrong', 'dy': 20},
      }),
    });

    final loaded = await store.loadLastPlacement(
      migrateLegacy: (_, _) => placement,
    );

    expect(loaded, isNull);
  });

  test('拒绝保存超出范围的比例值', () async {
    expect(
      () => store.savePlacement(
        'display-a',
        const DesktopWindowPlacement(
          horizontal: DesktopWindowAxisPlacement(
            anchor: DesktopWindowAnchor.proportional,
            value: 1.1,
          ),
          vertical: DesktopWindowAxisPlacement(
            anchor: DesktopWindowAnchor.startEdge,
            value: 0,
          ),
        ),
      ),
      throwsArgumentError,
    );
  });
}
