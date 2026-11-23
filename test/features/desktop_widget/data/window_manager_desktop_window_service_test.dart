import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker_rest_calendar/features/desktop_widget/application/desktop_display_configuration_service.dart';
import 'package:worker_rest_calendar/features/desktop_widget/data/desktop_window_position_store.dart';
import 'package:worker_rest_calendar/features/desktop_widget/data/window_manager_desktop_window_service.dart';
import 'package:worker_rest_calendar/features/desktop_widget/domain/desktop_window_placement.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('window_manager');
  final calls = <MethodCall>[];
  var windowBounds = const Rect.fromLTWH(0, 0, 1100, 720);
  var display = _display(width: 1920, height: 1040);

  WindowManagerDesktopWindowService createService({
    FakeDesktopDisplayConfigurationService? displayConfiguration,
    Duration displayChangeDebounce = const Duration(milliseconds: 350),
  }) => WindowManagerDesktopWindowService(
    displayConfigurationService:
        displayConfiguration ?? FakeDesktopDisplayConfigurationService(),
    getAllDisplays: () async => <Display>[display],
    getPrimaryDisplay: () async => display,
    displayChangeDebounce: displayChangeDebounce,
    isWindows: true,
    isMacOS: false,
  );

  setUp(() {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    calls.clear();
    windowBounds = const Rect.fromLTWH(0, 0, 1100, 720);
    display = _display(width: 1920, height: 1040);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'setBounds') {
            final arguments = Map<String, Object?>.from(call.arguments as Map);
            windowBounds = Rect.fromLTWH(
              (arguments['x'] as num?)?.toDouble() ?? windowBounds.left,
              (arguments['y'] as num?)?.toDouble() ?? windowBounds.top,
              (arguments['width'] as num?)?.toDouble() ?? windowBounds.width,
              (arguments['height'] as num?)?.toDouble() ?? windowBounds.height,
            );
            return true;
          }
          return switch (call.method) {
            'getBounds' => <String, double>{
              'x': windowBounds.left,
              'y': windowBounds.top,
              'width': windowBounds.width,
              'height': windowBounds.height,
            },
            'isMinimized' => false,
            _ => true,
          };
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('Windows 摆件使用真正无边框宿主并重新应用透明背景', () async {
    final service = createService();

    await service.showWidget(DesktopWidgetSize.small);

    final framelessIndex = calls.indexWhere(
      (call) => call.method == 'setAsFrameless',
    );
    final backgroundIndex = calls.indexWhere(
      (call) => call.method == 'setBackgroundColor',
    );
    expect(framelessIndex, greaterThanOrEqualTo(0));
    expect(backgroundIndex, greaterThan(framelessIndex));
    expect(calls.where((call) => call.method == 'setTitleBarStyle'), isEmpty);
    expect(calls[backgroundIndex].arguments, <String, int>{
      'backgroundColorA': 0,
      'backgroundColorR': 0,
      'backgroundColorG': 0,
      'backgroundColorB': 0,
    });
  });

  test('退出先隐藏窗口再解除关闭拦截并销毁且只执行一次', () async {
    final service = createService();

    await service.exit();
    await service.exit();

    final methods = calls.map((call) => call.method).toList();
    final hideIndex = methods.indexOf('hide');
    final preventCloseIndex = methods.indexOf('setPreventClose');
    final destroyIndex = methods.indexOf('destroy');
    expect(hideIndex, greaterThanOrEqualTo(0));
    expect(preventCloseIndex, greaterThan(hideIndex));
    expect(destroyIndex, greaterThan(preventCloseIndex));
    expect(methods.where((method) => method == 'hide'), hasLength(1));
    expect(methods.where((method) => method == 'destroy'), hasLength(1));
  });

  test('用户拖动摆件后保存当前显示器的 V2 自适应位置', () async {
    final service = createService();
    await service.showWidget(DesktopWidgetSize.small);
    windowBounds = const Rect.fromLTWH(1716, 796, 180, 220);

    service.onWindowMoved();
    await Future<void>.delayed(Duration.zero);

    final placement = await const DesktopWindowPositionStore().loadPlacement(
      'display-a',
      migrateLegacy: (_, _) => null,
    );
    expect(placement?.horizontal.anchor, DesktopWindowAnchor.endEdge);
    expect(placement?.horizontal.value, 24);
    expect(placement?.vertical.anchor, DesktopWindowAnchor.endEdge);
    expect(placement?.vertical.value, 24);
  });

  test('分辨率从 1080p 切换到 2K 后保持右下角边距', () async {
    const placement = DesktopWindowPlacement(
      horizontal: DesktopWindowAxisPlacement(
        anchor: DesktopWindowAnchor.endEdge,
        value: 24,
      ),
      vertical: DesktopWindowAxisPlacement(
        anchor: DesktopWindowAnchor.endEdge,
        value: 24,
      ),
    );
    await const DesktopWindowPositionStore().savePlacement(
      'display-a',
      placement,
    );
    final configuration = FakeDesktopDisplayConfigurationService();
    final service = createService(
      displayConfiguration: configuration,
      displayChangeDebounce: Duration.zero,
    );
    await service.initialize(onCloseRequested: () async {});
    await service.showWidget(DesktopWidgetSize.small);
    calls.clear();

    display = _display(width: 2560, height: 1400);
    await configuration.notify();
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final positionCalls = calls.where((call) {
      if (call.method != 'setBounds') return false;
      final arguments = Map<String, Object?>.from(call.arguments as Map);
      return arguments.containsKey('x') && arguments.containsKey('y');
    }).toList();
    expect(positionCalls, isNotEmpty);
    final arguments = Map<String, Object?>.from(
      positionCalls.last.arguments as Map,
    );
    expect(arguments['x'], 2356);
    expect(arguments['y'], 1156);
    await service.exit();
  });

  test('远程虚拟显示器接入并断开后恢复本地显示器位置', () async {
    const placement = DesktopWindowPlacement(
      horizontal: DesktopWindowAxisPlacement(
        anchor: DesktopWindowAnchor.endEdge,
        value: 24,
      ),
      vertical: DesktopWindowAxisPlacement(
        anchor: DesktopWindowAnchor.endEdge,
        value: 24,
      ),
    );
    await const DesktopWindowPositionStore().savePlacement(
      'display-a',
      placement,
    );
    final configuration = FakeDesktopDisplayConfigurationService();
    final service = createService(
      displayConfiguration: configuration,
      displayChangeDebounce: Duration.zero,
    );
    await service.initialize(onCloseRequested: () async {});
    await service.showWidget(DesktopWidgetSize.small);

    display = _display(id: 'remote-display', width: 2560, height: 1400);
    await configuration.notify();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(windowBounds.left, 2356);
    expect(windowBounds.top, 1156);

    display = _display(width: 1920, height: 1040);
    await configuration.notify();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(windowBounds.left, 1716);
    expect(windowBounds.top, 796);
    await service.exit();
  });

  test('完整主窗口移动不会覆盖桌面摆件位置', () async {
    final service = createService();
    await service.showWidget(DesktopWidgetSize.small);
    await service.showFullApp(configure: false);
    calls.clear();

    service.onWindowMoved();
    await Future<void>.delayed(Duration.zero);

    expect(calls.where((call) => call.method == 'getBounds'), isEmpty);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('desktop_widget_placements_v2'), isNull);
  });
}

Display _display({
  String id = 'display-a',
  required double width,
  required double height,
}) => Display(
  id: id,
  name: r'\\.\DISPLAY1',
  size: Size(width, height),
  visiblePosition: Offset.zero,
  visibleSize: Size(width, height),
  scaleFactor: 1,
);

final class FakeDesktopDisplayConfigurationService
    implements DesktopDisplayConfigurationService {
  DesktopDisplayConfigurationHandler? _handler;

  @override
  Future<void> initialize(DesktopDisplayConfigurationHandler handler) async {
    _handler = handler;
  }

  @override
  Future<void> dispose() async {
    _handler = null;
  }

  Future<void> notify() async {
    await _handler?.call();
  }
}
