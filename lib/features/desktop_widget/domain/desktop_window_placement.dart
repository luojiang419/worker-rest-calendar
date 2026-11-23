const double defaultDesktopWindowEdgeThreshold = 96;

enum DesktopWindowAnchor { startEdge, proportional, endEdge }

final class DesktopWindowAxisPlacement {
  const DesktopWindowAxisPlacement({required this.anchor, required this.value});

  final DesktopWindowAnchor anchor;
  final double value;
}

final class DesktopWindowPosition {
  const DesktopWindowPosition(this.x, this.y);

  final double x;
  final double y;
}

final class DesktopWindowSize {
  const DesktopWindowSize(this.width, this.height);

  final double width;
  final double height;
}

final class DesktopWindowWorkArea {
  const DesktopWindowWorkArea({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final double left;
  final double top;
  final double width;
  final double height;
}

final class DesktopWindowPlacement {
  const DesktopWindowPlacement({
    required this.horizontal,
    required this.vertical,
  });

  factory DesktopWindowPlacement.capture({
    required DesktopWindowPosition position,
    required DesktopWindowSize windowSize,
    required DesktopWindowWorkArea workArea,
    double edgeThreshold = defaultDesktopWindowEdgeThreshold,
  }) {
    _validateGeometry(windowSize: windowSize, workArea: workArea);
    if (!edgeThreshold.isFinite || edgeThreshold < 0) {
      throw ArgumentError.value(edgeThreshold, 'edgeThreshold', '必须是有限的非负数');
    }
    if (!position.x.isFinite || !position.y.isFinite) {
      throw ArgumentError.value(position, 'position', '坐标必须是有限数值');
    }

    return DesktopWindowPlacement(
      horizontal: _captureAxis(
        position: position.x - workArea.left,
        travelExtent: _travelExtent(workArea.width, windowSize.width),
        edgeThreshold: edgeThreshold,
      ),
      vertical: _captureAxis(
        position: position.y - workArea.top,
        travelExtent: _travelExtent(workArea.height, windowSize.height),
        edgeThreshold: edgeThreshold,
      ),
    );
  }

  final DesktopWindowAxisPlacement horizontal;
  final DesktopWindowAxisPlacement vertical;

  DesktopWindowPosition resolve({
    required DesktopWindowSize windowSize,
    required DesktopWindowWorkArea workArea,
  }) {
    _validateGeometry(windowSize: windowSize, workArea: workArea);
    final horizontalTravel = _travelExtent(workArea.width, windowSize.width);
    final verticalTravel = _travelExtent(workArea.height, windowSize.height);
    return DesktopWindowPosition(
      workArea.left + _resolveAxis(horizontal, horizontalTravel),
      workArea.top + _resolveAxis(vertical, verticalTravel),
    );
  }

  static DesktopWindowAxisPlacement _captureAxis({
    required double position,
    required double travelExtent,
    required double edgeThreshold,
  }) {
    final clampedPosition = position.clamp(0, travelExtent).toDouble();
    final startGap = clampedPosition;
    final endGap = travelExtent - clampedPosition;
    if (startGap <= edgeThreshold && startGap <= endGap) {
      return DesktopWindowAxisPlacement(
        anchor: DesktopWindowAnchor.startEdge,
        value: startGap,
      );
    }
    if (endGap <= edgeThreshold) {
      return DesktopWindowAxisPlacement(
        anchor: DesktopWindowAnchor.endEdge,
        value: endGap,
      );
    }
    return DesktopWindowAxisPlacement(
      anchor: DesktopWindowAnchor.proportional,
      value: travelExtent == 0 ? 0 : clampedPosition / travelExtent,
    );
  }

  static double _resolveAxis(
    DesktopWindowAxisPlacement placement,
    double travelExtent,
  ) {
    if (!placement.value.isFinite) return 0;
    final position = switch (placement.anchor) {
      DesktopWindowAnchor.startEdge => placement.value,
      DesktopWindowAnchor.proportional =>
        travelExtent * placement.value.clamp(0, 1),
      DesktopWindowAnchor.endEdge => travelExtent - placement.value,
    };
    return position.clamp(0, travelExtent).toDouble();
  }

  static double _travelExtent(double workAreaExtent, double windowExtent) =>
      (workAreaExtent - windowExtent).clamp(0, double.infinity).toDouble();

  static void _validateGeometry({
    required DesktopWindowSize windowSize,
    required DesktopWindowWorkArea workArea,
  }) {
    final values = <double>[
      windowSize.width,
      windowSize.height,
      workArea.left,
      workArea.top,
      workArea.width,
      workArea.height,
    ];
    if (values.any((value) => !value.isFinite)) {
      throw ArgumentError('窗口尺寸与工作区必须使用有限数值');
    }
    if (windowSize.width <= 0 || windowSize.height <= 0) {
      throw ArgumentError.value(windowSize, 'windowSize', '窗口尺寸必须大于 0');
    }
    if (workArea.width < 0 || workArea.height < 0) {
      throw ArgumentError.value(workArea, 'workArea', '工作区尺寸不能为负数');
    }
  }
}
