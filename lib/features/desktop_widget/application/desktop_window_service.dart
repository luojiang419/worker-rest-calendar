import 'package:flutter/widgets.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

abstract interface class DesktopWindowService {
  bool get isSupported;

  Future<void> initialize({required Future<void> Function() onCloseRequested});

  Future<void> showWidget(DesktopWidgetSize size);

  Future<void> showFullApp({bool configure = true});

  Future<void> setAlwaysOnTop(bool value);

  Future<void> setDesktopLayer(bool value);

  Future<void> setOpacity(double value);

  Future<void> setLocked(bool value);

  Future<void> startDragging();

  Future<void> setLaunchAtStartup(bool value);

  Future<void> exit();
}

const desktopFullAppWindowSize = Size(1100, 720);
const desktopFullAppMinimumSize = Size(900, 600);

Size desktopWidgetWindowSize(DesktopWidgetSize size) => switch (size) {
  DesktopWidgetSize.small => const Size(180, 220),
  DesktopWidgetSize.medium => const Size(360, 220),
  DesktopWidgetSize.large => const Size(420, 360),
};
