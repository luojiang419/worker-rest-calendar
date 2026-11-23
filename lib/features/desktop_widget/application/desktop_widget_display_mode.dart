import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DesktopWidgetDisplayMode { fullApp, widget }

final desktopWidgetDisplayModeProvider =
    NotifierProvider<
      DesktopWidgetDisplayModeController,
      DesktopWidgetDisplayMode
    >(DesktopWidgetDisplayModeController.new);

final class DesktopWidgetDisplayModeController
    extends Notifier<DesktopWidgetDisplayMode> {
  @override
  DesktopWidgetDisplayMode build() => DesktopWidgetDisplayMode.fullApp;

  void showFullApp() {
    state = DesktopWidgetDisplayMode.fullApp;
  }

  void showWidget() {
    state = DesktopWidgetDisplayMode.widget;
  }
}
