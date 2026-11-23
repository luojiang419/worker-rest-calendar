import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';
import 'package:worker_rest_calendar/features/desktop_widget/application/desktop_display_configuration_service.dart';
import 'package:worker_rest_calendar/features/desktop_widget/application/desktop_window_service.dart';
import 'package:worker_rest_calendar/features/desktop_widget/data/desktop_window_position_store.dart';
import 'package:worker_rest_calendar/features/desktop_widget/data/method_channel_desktop_display_configuration_service.dart';
import 'package:worker_rest_calendar/features/desktop_widget/domain/desktop_window_placement.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

final class WindowManagerDesktopWindowService extends WindowListener
    implements DesktopWindowService {
  WindowManagerDesktopWindowService({
    this.positionStore = const DesktopWindowPositionStore(),
    DesktopDisplayConfigurationService? displayConfigurationService,
    Future<List<Display>> Function()? getAllDisplays,
    Future<Display> Function()? getPrimaryDisplay,
    this.displayChangeDebounce = const Duration(milliseconds: 350),
    bool? isWindows,
    bool? isMacOS,
  }) : _isWindows = isWindows ?? Platform.isWindows,
       _isMacOS = isMacOS ?? Platform.isMacOS,
       _displayConfiguration =
           displayConfigurationService ??
           MethodChannelDesktopDisplayConfigurationService(
             isSupported: isWindows ?? Platform.isWindows,
           ),
       _getAllDisplays = getAllDisplays ?? screenRetriever.getAllDisplays,
       _getPrimaryDisplay =
           getPrimaryDisplay ?? screenRetriever.getPrimaryDisplay;

  final DesktopWindowPositionStore positionStore;
  final DesktopDisplayConfigurationService _displayConfiguration;
  final Future<List<Display>> Function() _getAllDisplays;
  final Future<Display> Function() _getPrimaryDisplay;
  final Duration displayChangeDebounce;
  final bool _isWindows;
  final bool _isMacOS;
  bool _locked = false;
  bool _exiting = false;
  bool _isWidgetMode = false;
  bool _applyingPosition = false;
  String? _activeDisplayId;
  DesktopWindowPlacement? _activePlacement;
  Size? _currentWidgetSize;
  Timer? _displayChangeTimer;
  Future<void> Function()? _onCloseRequested;

  @override
  bool get isSupported => _isWindows || _isMacOS;

  @override
  Future<void> initialize({
    required Future<void> Function() onCloseRequested,
  }) async {
    if (!isSupported) return;
    _onCloseRequested = onCloseRequested;
    windowManager.addListener(this);
    await _displayConfiguration.initialize(_onDisplayConfigurationChanged);
    await windowManager.setPreventClose(true);
    launchAtStartup.setup(
      appName: '工作日历',
      appPath: Platform.resolvedExecutable,
    );
  }

  @override
  Future<void> showWidget(DesktopWidgetSize size) async {
    if (!isSupported) return;
    final windowSize = desktopWidgetWindowSize(size);
    _isWidgetMode = true;
    _currentWidgetSize = windowSize;
    if (_isWindows) {
      await windowManager.setAsFrameless();
      // Changing the native frame resets DWM's transparent client-area
      // composition. Reapply it so Flutter's transparent pixels reveal the
      // desktop instead of the rectangular Windows host surface.
      await windowManager.setBackgroundColor(Colors.transparent);
    } else {
      await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    }
    await windowManager.setResizable(false);
    await windowManager.setMinimumSize(Size.zero);
    await windowManager.setMaximumSize(const Size(10000, 10000));
    await windowManager.setSize(windowSize, animate: true);
    await windowManager.setMinimumSize(windowSize);
    await windowManager.setMaximumSize(windowSize);
    await windowManager.setSkipTaskbar(_isWindows);
    await _restoreWidgetPosition(windowSize);
    final wasMinimized = await windowManager.isMinimized();
    await windowManager.show();
    if (wasMinimized) await windowManager.restore();
    await windowManager.focus();
  }

  @override
  Future<void> showFullApp({bool configure = true}) async {
    if (!isSupported) return;
    _isWidgetMode = false;
    _displayChangeTimer?.cancel();
    if (_isWindows) await windowManager.setAlwaysOnBottom(false);
    await windowManager.setAlwaysOnTop(false);
    if (configure) {
      await windowManager.setMinimumSize(Size.zero);
      await windowManager.setMaximumSize(const Size(10000, 10000));
      await windowManager.setMinimumSize(desktopFullAppMinimumSize);
      await windowManager.setResizable(true);
      if (_isWindows) {
        await windowManager.setTitleBarStyle(TitleBarStyle.normal);
      }
    }
    await windowManager.setSkipTaskbar(false);
    if (configure) {
      await windowManager.setSize(desktopFullAppWindowSize, animate: true);
      await windowManager.center(animate: true);
    }
    final wasMinimized = await windowManager.isMinimized();
    await windowManager.show();
    if (wasMinimized) await windowManager.restore();
    await windowManager.focus();
  }

  @override
  Future<void> setAlwaysOnTop(bool value) async {
    if (isSupported) await windowManager.setAlwaysOnTop(value);
  }

  @override
  Future<void> setDesktopLayer(bool value) async {
    if (_isWindows) await windowManager.setAlwaysOnBottom(value);
  }

  @override
  Future<void> setOpacity(double value) async {
    if (isSupported) await windowManager.setOpacity(value.clamp(0.7, 1));
  }

  @override
  Future<void> setLocked(bool value) async {
    _locked = value;
  }

  @override
  Future<void> startDragging() async {
    if (isSupported && !_locked) await windowManager.startDragging();
  }

  @override
  Future<void> setLaunchAtStartup(bool value) async {
    if (!isSupported) return;
    if (value) {
      await launchAtStartup.enable();
    } else {
      await launchAtStartup.disable();
    }
  }

  @override
  Future<void> exit() async {
    if (!isSupported || _exiting) return;
    _exiting = true;
    _displayChangeTimer?.cancel();
    windowManager.removeListener(this);
    try {
      // Make the exit feel immediate even when native tray or engine cleanup
      // needs a little longer to finish in the background.
      await windowManager.hide();
    } finally {
      try {
        await _displayConfiguration.dispose();
      } finally {
        await windowManager.setPreventClose(false);
      }
    }
    await windowManager.destroy();
  }

  @override
  void onWindowClose() {
    if (_exiting) return;
    final callback = _onCloseRequested;
    if (callback != null) unawaited(callback());
  }

  @override
  void onWindowMoved() {
    if (_isWidgetMode && !_applyingPosition) unawaited(_savePosition());
  }

  @override
  void onWindowFocus() {
    if (_locked && _isWindows) {
      unawaited(windowManager.setAlwaysOnBottom(true));
    }
  }

  Future<void> _savePosition() async {
    if (!_isWidgetMode || _applyingPosition || _exiting) return;
    final position = await windowManager.getPosition();
    final windowSize = await windowManager.getSize();
    final displays = await _safeGetAllDisplays();
    final display = _displayContainingWindow(displays, position, windowSize);
    if (display == null) return;
    final placement = DesktopWindowPlacement.capture(
      position: DesktopWindowPosition(position.dx, position.dy),
      windowSize: _placementSize(windowSize),
      workArea: _workArea(display),
    );
    await positionStore.savePlacement(display.id, placement);
    _activeDisplayId = display.id;
    _activePlacement = placement;
  }

  Future<void> _restoreWidgetPosition(Size windowSize) async {
    final displays = await _safeGetAllDisplays();
    if (displays.isEmpty) return;
    final stored = await positionStore.loadLastPlacement(
      migrateLegacy: (displayId, position) => _migrateLegacyPosition(
        displays: displays,
        displayId: displayId,
        position: position,
        windowSize: windowSize,
      ),
    );
    if (stored == null) return;
    final currentPosition = await windowManager.getPosition();
    final targetDisplay =
        _displayById(displays, stored.displayId) ??
        _displayContainingWindow(displays, currentPosition, windowSize) ??
        await _primaryDisplayFrom(displays);
    if (targetDisplay == null) return;
    await _applyPlacement(
      display: targetDisplay,
      placement: stored.placement,
      windowSize: windowSize,
    );
  }

  Future<void> _onDisplayConfigurationChanged() async {
    if (!_isWidgetMode || _exiting) return;
    _displayChangeTimer?.cancel();
    _displayChangeTimer = Timer(displayChangeDebounce, () {
      _displayChangeTimer = null;
      unawaited(_restoreAfterDisplayConfigurationChanged());
    });
  }

  Future<void> _restoreAfterDisplayConfigurationChanged() async {
    if (!_isWidgetMode || _exiting) return;
    final windowSize = _currentWidgetSize;
    if (windowSize == null) return;
    final displays = await _safeGetAllDisplays();
    if (displays.isEmpty) return;
    final currentPosition = await windowManager.getPosition();
    final targetDisplay =
        _displayById(displays, _activeDisplayId) ??
        _displayContainingWindow(displays, currentPosition, windowSize) ??
        await _primaryDisplayFrom(displays);
    if (targetDisplay == null) return;

    DesktopWindowPlacement? migrateLegacy(
      String displayId,
      DesktopWindowPosition position,
    ) => _migrateLegacyPosition(
      displays: displays,
      displayId: displayId,
      position: position,
      windowSize: windowSize,
    );
    var placement = await positionStore.loadPlacement(
      targetDisplay.id,
      migrateLegacy: migrateLegacy,
    );
    placement ??= _activePlacement;
    if (placement == null) {
      final stored = await positionStore.loadLastPlacement(
        migrateLegacy: migrateLegacy,
      );
      placement = stored?.placement;
    }
    if (placement == null) return;
    await _applyPlacement(
      display: targetDisplay,
      placement: placement,
      windowSize: windowSize,
    );
  }

  DesktopWindowPlacement? _migrateLegacyPosition({
    required List<Display> displays,
    required String displayId,
    required DesktopWindowPosition position,
    required Size windowSize,
  }) {
    final display = _displayById(displays, displayId);
    if (display == null) return null;
    return DesktopWindowPlacement.capture(
      position: position,
      windowSize: _placementSize(windowSize),
      workArea: _workArea(display),
    );
  }

  Future<void> _applyPlacement({
    required Display display,
    required DesktopWindowPlacement placement,
    required Size windowSize,
  }) async {
    final position = placement.resolve(
      windowSize: _placementSize(windowSize),
      workArea: _workArea(display),
    );
    _applyingPosition = true;
    try {
      await windowManager.setPosition(Offset(position.x, position.y));
    } finally {
      _applyingPosition = false;
    }
    _activeDisplayId = display.id;
    _activePlacement = placement;
  }

  Future<List<Display>> _safeGetAllDisplays() async {
    try {
      return await _getAllDisplays();
    } on Object {
      return const [];
    }
  }

  Future<Display?> _primaryDisplayFrom(List<Display> displays) async {
    try {
      final primary = await _getPrimaryDisplay();
      return _displayById(displays, primary.id) ?? primary;
    } on Object {
      return displays.isEmpty ? null : displays.first;
    }
  }

  Display? _displayById(List<Display> displays, String? displayId) {
    if (displayId == null) return null;
    for (final display in displays) {
      if (display.id == displayId) return display;
    }
    return null;
  }

  Display? _displayContainingWindow(
    List<Display> displays,
    Offset position,
    Size windowSize,
  ) {
    final center =
        position + Offset(windowSize.width / 2, windowSize.height / 2);
    for (final display in displays) {
      if (_contains(display, center)) return display;
    }
    return null;
  }

  bool _contains(Display display, Offset point) {
    final origin = display.visiblePosition ?? Offset.zero;
    final size = display.visibleSize ?? display.size;
    return (origin & size).contains(point);
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

  DesktopWindowSize _placementSize(Size size) =>
      DesktopWindowSize(size.width, size.height);
}
