import 'dart:io';

import 'package:flutter/services.dart';
import 'package:worker_rest_calendar/features/desktop_widget/application/desktop_activation_service.dart';

final class MethodChannelDesktopActivationService
    implements DesktopActivationService {
  MethodChannelDesktopActivationService({
    MethodChannel channel = const MethodChannel(
      'worker_rest_calendar/desktop_activation',
    ),
    bool? isSupported,
  }) : _channel = channel,
       _isSupported = isSupported ?? Platform.isWindows;

  final MethodChannel _channel;
  final bool _isSupported;
  final List<DesktopActivationIntent> _queued = [];
  DesktopActivationHandler? _handler;

  @override
  Future<List<DesktopActivationIntent>> initialize() async {
    if (!_isSupported) return const [];
    _channel.setMethodCallHandler(_handleMethodCall);
    final rawActivations =
        await _channel.invokeListMethod<Object?>('consumePendingActivations') ??
        const [];
    final initial = rawActivations
        .map(_intentFromValue)
        .whereType<DesktopActivationIntent>()
        .toList(growable: true);
    initial.addAll(_takeQueued());
    return initial;
  }

  @override
  Future<void> startListening(DesktopActivationHandler handler) async {
    _handler = handler;
    for (final intent in _takeQueued()) {
      await handler(intent);
    }
  }

  @override
  Future<void> dispose() async {
    _handler = null;
    _queued.clear();
    if (_isSupported) {
      _channel.setMethodCallHandler(null);
    }
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method != 'onActivation') return;
    final intent = _intentFromValue(call.arguments);
    if (intent == null) return;
    final handler = _handler;
    if (handler == null) {
      _queued.add(intent);
      return;
    }
    await handler(intent);
  }

  DesktopActivationIntent? _intentFromValue(Object? value) {
    if (value is! List) return null;
    final arguments = value.whereType<String>().toList(growable: false);
    return DesktopActivationIntent(arguments: arguments);
  }

  List<DesktopActivationIntent> _takeQueued() {
    final queued = List<DesktopActivationIntent>.of(_queued);
    _queued.clear();
    return queued;
  }
}
