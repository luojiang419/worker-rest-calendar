import 'dart:io';

import 'package:flutter/services.dart';
import 'package:worker_rest_calendar/features/desktop_widget/application/system_status_service.dart';
import 'package:worker_rest_calendar/features/desktop_widget/domain/system_status_snapshot.dart';

final class MethodChannelSystemStatusService implements SystemStatusService {
  MethodChannelSystemStatusService({MethodChannel? channel, bool? isSupported})
    : _channel = channel ?? const MethodChannel(_channelName),
      _isSupported = isSupported ?? Platform.isWindows;

  static const _channelName = 'worker_rest_calendar/system_status';

  final MethodChannel _channel;
  final bool _isSupported;

  @override
  bool get isSupported => _isSupported;

  @override
  Future<SystemStatusSnapshot?> read() async {
    if (!isSupported) return null;
    try {
      final result = await _channel.invokeMapMethod<String, Object?>(
        'getSystemStatus',
      );
      if (result == null) return null;
      final cpu = result['cpuUsage'];
      final memory = result['memoryUsage'];
      if (cpu is! num || memory is! num) return null;
      final battery = result['batteryLevel'];
      final charging = result['isCharging'];
      return SystemStatusSnapshot(
        cpuUsage: cpu.toDouble().clamp(0, 100),
        memoryUsage: memory.toDouble().clamp(0, 100),
        batteryLevel: battery is num ? battery.round().clamp(0, 100) : null,
        isCharging: charging is bool ? charging : null,
      );
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}
