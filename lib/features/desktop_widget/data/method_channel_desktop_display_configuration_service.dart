import 'dart:io';

import 'package:flutter/services.dart';
import 'package:worker_rest_calendar/features/desktop_widget/application/desktop_display_configuration_service.dart';

final class MethodChannelDesktopDisplayConfigurationService
    implements DesktopDisplayConfigurationService {
  MethodChannelDesktopDisplayConfigurationService({
    MethodChannel channel = const MethodChannel(
      'worker_rest_calendar/desktop_display_configuration',
    ),
    bool? isSupported,
  }) : _channel = channel,
       _isSupported = isSupported ?? Platform.isWindows;

  final MethodChannel _channel;
  final bool _isSupported;
  DesktopDisplayConfigurationHandler? _handler;

  @override
  Future<void> initialize(DesktopDisplayConfigurationHandler handler) async {
    if (!_isSupported) return;
    _handler = handler;
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  @override
  Future<void> dispose() async {
    _handler = null;
    if (_isSupported) _channel.setMethodCallHandler(null);
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method != 'onDisplayConfigurationChanged') return;
    await _handler?.call();
  }
}
