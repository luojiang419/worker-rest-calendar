import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';
import 'package:worker_rest_calendar/features/desktop_widget/application/desktop_window_service.dart';
import 'package:worker_rest_calendar/features/desktop_widget/data/desktop_window_position_store.dart';
import 'package:worker_rest_calendar/features/desktop_widget/domain/desktop_window_placement.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

bool get isDesktopWidgetPlatform => Platform.isWindows || Platform.isMacOS;

final desktopWidgetPlatformProvider = Provider<bool>(
  (ref) => isDesktopWidgetPlatform,
);

Future<void> bootstrapDesktopWindow() async {
  if (!isDesktopWidgetPlatform) return;
  await windowManager.ensureInitialized();
  final widgetSize = desktopWidgetWindowSize(DesktopWidgetSize.small);
  final position = await _loadInitialWidgetPosition(widgetSize);
  final isWindows = Platform.isWindows;
  final options = desktopInitialWindowOptions(
    isWindows: isWindows,
    hasStoredPosition: position != null,
  );
  await windowManager.waitUntilReadyToShow(options, () async {
    if (!isWindows && position != null) {
      await windowManager.setPosition(position);
    }
    await windowManager.show();
    await windowManager.focus();
  });
}

Future<Offset?> _loadInitialWidgetPosition(Size windowSize) async {
  try {
    final displays = await screenRetriever.getAllDisplays();
    final stored = await const DesktopWindowPositionStore().loadLastPlacement(
      migrateLegacy: (displayId, position) {
        final display = _displayById(displays, displayId);
        if (display == null) return null;
        return DesktopWindowPlacement.capture(
          position: position,
          windowSize: DesktopWindowSize(windowSize.width, windowSize.height),
          workArea: _workArea(display),
        );
      },
    );
    if (stored == null) return null;
    final display =
        _displayById(displays, stored.displayId) ??
        await screenRetriever.getPrimaryDisplay();
    final position = stored.placement.resolve(
      windowSize: DesktopWindowSize(windowSize.width, windowSize.height),
      workArea: _workArea(display),
    );
    return Offset(position.x, position.y);
  } on Object {
    return null;
  }
}

@visibleForTesting
WindowOptions desktopInitialWindowOptions({
  required bool isWindows,
  required bool hasStoredPosition,
}) => WindowOptions(
  size: isWindows
      ? desktopFullAppWindowSize
      : desktopWidgetWindowSize(DesktopWidgetSize.small),
  minimumSize: isWindows ? desktopFullAppMinimumSize : null,
  center: isWindows || !hasStoredPosition,
  backgroundColor: Colors.transparent,
  title: isWindows ? '工作日历' : null,
  titleBarStyle: isWindows ? TitleBarStyle.normal : TitleBarStyle.hidden,
);

Display? _displayById(List<Display> displays, String displayId) {
  for (final display in displays) {
    if (display.id == displayId) return display;
  }
  return null;
}

DesktopWindowWorkArea _workArea(Display display) {
  final origin = display.visiblePosition ?? Offset.zero;
  final size = display.visibleSize ?? display.size;
  return DesktopWindowWorkArea(
    left: origin.dx,
    top: origin.dy,
    width: size.width,
    height: size.height,
  );
}
