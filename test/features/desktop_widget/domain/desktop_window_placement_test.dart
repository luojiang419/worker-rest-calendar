import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/features/desktop_widget/domain/desktop_window_placement.dart';

void main() {
  const fullHdWorkArea = DesktopWindowWorkArea(
    left: 0,
    top: 0,
    width: 1920,
    height: 1040,
  );
  const twoKWorkArea = DesktopWindowWorkArea(
    left: 0,
    top: 0,
    width: 2560,
    height: 1400,
  );
  const smallWidget = DesktopWindowSize(180, 220);

  group('DesktopWindowPlacement', () {
    test('右下角在 1080p 与 2K 间切换时保持边缘距离', () {
      final placement = DesktopWindowPlacement.capture(
        position: const DesktopWindowPosition(1716, 796),
        windowSize: smallWidget,
        workArea: fullHdWorkArea,
      );

      expect(placement.horizontal.anchor, DesktopWindowAnchor.endEdge);
      expect(placement.horizontal.value, 24);
      expect(placement.vertical.anchor, DesktopWindowAnchor.endEdge);
      expect(placement.vertical.value, 24);

      final onTwoK = placement.resolve(
        windowSize: smallWidget,
        workArea: twoKWorkArea,
      );
      expect(onTwoK.x, 2356);
      expect(onTwoK.y, 1156);

      final backOnFullHd = placement.resolve(
        windowSize: smallWidget,
        workArea: fullHdWorkArea,
      );
      expect(backOnFullHd.x, 1716);
      expect(backOnFullHd.y, 796);
    });

    test('靠近左上角时保持左侧和顶部距离', () {
      final placement = DesktopWindowPlacement.capture(
        position: const DesktopWindowPosition(32, 48),
        windowSize: smallWidget,
        workArea: fullHdWorkArea,
      );

      expect(placement.horizontal.anchor, DesktopWindowAnchor.startEdge);
      expect(placement.horizontal.value, 32);
      expect(placement.vertical.anchor, DesktopWindowAnchor.startEdge);
      expect(placement.vertical.value, 48);

      final resolved = placement.resolve(
        windowSize: smallWidget,
        workArea: twoKWorkArea,
      );
      expect(resolved.x, 32);
      expect(resolved.y, 48);
    });

    test('中间区域随可移动范围按比例换算', () {
      final placement = DesktopWindowPlacement.capture(
        position: const DesktopWindowPosition(1218, 328),
        windowSize: smallWidget,
        workArea: fullHdWorkArea,
      );

      expect(placement.horizontal.anchor, DesktopWindowAnchor.proportional);
      expect(placement.horizontal.value, closeTo(0.7, 0.000001));
      expect(placement.vertical.anchor, DesktopWindowAnchor.proportional);
      expect(placement.vertical.value, closeTo(0.4, 0.000001));

      final resolved = placement.resolve(
        windowSize: smallWidget,
        workArea: twoKWorkArea,
      );
      expect(resolved.x, closeTo(1666, 0.000001));
      expect(resolved.y, closeTo(472, 0.000001));
    });

    test('使用带负坐标和任务栏偏移的显示器工作区', () {
      const workArea = DesktopWindowWorkArea(
        left: -1920,
        top: 40,
        width: 1920,
        height: 1040,
      );
      final placement = DesktopWindowPlacement.capture(
        position: const DesktopWindowPosition(-1868, 64),
        windowSize: smallWidget,
        workArea: workArea,
      );

      final resolved = placement.resolve(
        windowSize: smallWidget,
        workArea: workArea,
      );
      expect(resolved.x, -1868);
      expect(resolved.y, 64);
    });

    test('切换摆件尺寸时仍保持右下边距', () {
      final placement = DesktopWindowPlacement.capture(
        position: const DesktopWindowPosition(1716, 796),
        windowSize: smallWidget,
        workArea: fullHdWorkArea,
      );

      final resolved = placement.resolve(
        windowSize: const DesktopWindowSize(420, 360),
        workArea: fullHdWorkArea,
      );
      expect(resolved.x, 1476);
      expect(resolved.y, 656);
    });

    test('屏幕小于摆件时固定到工作区起点', () {
      final placement = DesktopWindowPlacement.capture(
        position: const DesktopWindowPosition(500, 500),
        windowSize: smallWidget,
        workArea: const DesktopWindowWorkArea(
          left: 10,
          top: 20,
          width: 120,
          height: 160,
        ),
      );

      final resolved = placement.resolve(
        windowSize: smallWidget,
        workArea: const DesktopWindowWorkArea(
          left: 10,
          top: 20,
          width: 120,
          height: 160,
        ),
      );
      expect(resolved.x, 10);
      expect(resolved.y, 20);
    });

    test('捕获越界坐标时先限制到完整可见范围', () {
      final placement = DesktopWindowPlacement.capture(
        position: const DesktopWindowPosition(4000, -200),
        windowSize: smallWidget,
        workArea: fullHdWorkArea,
      );

      expect(placement.horizontal.anchor, DesktopWindowAnchor.endEdge);
      expect(placement.horizontal.value, 0);
      expect(placement.vertical.anchor, DesktopWindowAnchor.startEdge);
      expect(placement.vertical.value, 0);
    });

    test('超过边缘阈值的位置采用比例定位', () {
      final placement = DesktopWindowPlacement.capture(
        position: const DesktopWindowPosition(97, 97),
        windowSize: smallWidget,
        workArea: fullHdWorkArea,
      );

      expect(placement.horizontal.anchor, DesktopWindowAnchor.proportional);
      expect(placement.vertical.anchor, DesktopWindowAnchor.proportional);
    });

    test('拒绝无效窗口尺寸和阈值', () {
      expect(
        () => DesktopWindowPlacement.capture(
          position: const DesktopWindowPosition(0, 0),
          windowSize: const DesktopWindowSize(0, 220),
          workArea: fullHdWorkArea,
        ),
        throwsArgumentError,
      );
      expect(
        () => DesktopWindowPlacement.capture(
          position: const DesktopWindowPosition(0, 0),
          windowSize: smallWidget,
          workArea: fullHdWorkArea,
          edgeThreshold: -1,
        ),
        throwsArgumentError,
      );
    });
  });
}
