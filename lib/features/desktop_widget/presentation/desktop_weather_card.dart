import 'dart:async';

import 'package:flutter/material.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/features/desktop_widget/application/weather_service.dart';
import 'package:worker_rest_calendar/features/desktop_widget/domain/weather_snapshot.dart';
import 'package:worker_rest_calendar/features/desktop_widget/presentation/desktop_widget_frame.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

class DesktopWeatherCard extends StatefulWidget {
  const DesktopWeatherCard({
    required this.city,
    required this.size,
    required this.service,
    this.refreshInterval = const Duration(minutes: 30),
    super.key,
  });

  final String city;
  final DesktopWidgetSize size;
  final WeatherService service;
  final Duration refreshInterval;

  @override
  State<DesktopWeatherCard> createState() => _DesktopWeatherCardState();
}

class _DesktopWeatherCardState extends State<DesktopWeatherCard> {
  WeatherSnapshot? _snapshot;
  Object? _error;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(widget.refreshInterval, (_) => _load(force: true));
  }

  @override
  void didUpdateWidget(covariant DesktopWeatherCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.city != widget.city || oldWidget.service != widget.service) {
      _snapshot = null;
      _load(force: true);
    }
  }

  Future<void> _load({bool force = false}) async {
    try {
      final value = await widget.service.fetch(
        widget.city,
        forceRefresh: force,
      );
      if (mounted) {
        setState(() {
          _snapshot = value;
          _error = null;
        });
      }
    } on Object catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final compact = widget.size == DesktopWidgetSize.small;
    final snapshot = _snapshot;
    return DesktopWidgetFrame(
      size: widget.size,
      cardKey: ValueKey('desktop-weather-card-${tokens.visualStyle.name}'),
      shadowSafeAreaKey: const ValueKey('desktop-weather-shadow-safe-area'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: tokens.colors.primary),
              SizedBox(width: tokens.spacing.xs),
              Expanded(
                child: Text(
                  snapshot?.city ?? widget.city,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                key: const ValueKey('desktop-weather-refresh'),
                tooltip: '刷新天气',
                onPressed: () => _load(force: true),
                icon: const Icon(Icons.refresh_rounded, size: 18),
              ),
            ],
          ),
          if (snapshot == null && _error == null)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (snapshot == null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_off_outlined,
                      color: tokens.colors.textSecondary,
                    ),
                    SizedBox(height: tokens.spacing.sm),
                    Text(
                      '天气暂不可用',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: compact
                  ? _CompactWeather(snapshot: snapshot)
                  : _WideWeather(snapshot: snapshot),
            ),
          Text(
            '数据：Open-Meteo',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: tokens.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactWeather extends StatelessWidget {
  const _CompactWeather({required this.snapshot});

  final WeatherSnapshot snapshot;

  @override
  Widget build(BuildContext context) => Center(
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _weatherIcon(snapshot.weatherCode),
            size: 36,
            color: _weatherColor(context, snapshot.weatherCode),
          ),
          Text(
            '${snapshot.temperature.round()}°',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(
            snapshot.description,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    ),
  );
}

class _WideWeather extends StatelessWidget {
  const _WideWeather({required this.snapshot});

  final WeatherSnapshot snapshot;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _weatherIcon(snapshot.weatherCode),
                  size: 52,
                  color: _weatherColor(context, snapshot.weatherCode),
                ),
                Text(
                  snapshot.description,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      Expanded(
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${snapshot.temperature.round()}°',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text('体感 ${snapshot.apparentTemperature.round()}°'),
                Text('湿度 ${snapshot.humidity}%'),
                Text('风速 ${snapshot.windSpeed.toStringAsFixed(1)} km/h'),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

IconData _weatherIcon(int code) => switch (code) {
  0 || 1 => Icons.wb_sunny_outlined,
  2 || 3 => Icons.cloud_outlined,
  45 || 48 => Icons.blur_on_rounded,
  >= 51 && <= 67 || >= 80 && <= 82 => Icons.water_drop_outlined,
  >= 71 && <= 77 || 85 || 86 => Icons.ac_unit_rounded,
  >= 95 => Icons.thunderstorm_outlined,
  _ => Icons.cloud_queue_outlined,
};

Color _weatherColor(BuildContext context, int code) {
  final tokens = context.tokens;
  if (code <= 1) return tokens.colors.adjustedWork;
  if (code >= 95) return tokens.colors.leave;
  if (code >= 51) return tokens.colors.primary;
  return tokens.colors.work;
}
