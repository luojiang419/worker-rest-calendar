import 'dart:convert';
import 'dart:io';

import 'package:worker_rest_calendar/features/desktop_widget/application/weather_service.dart';
import 'package:worker_rest_calendar/features/desktop_widget/domain/weather_snapshot.dart';

abstract interface class WeatherTransport {
  Future<Map<String, Object?>> getJson(Uri uri);
}

final class IoWeatherTransport implements WeatherTransport {
  IoWeatherTransport({HttpClient? client}) : _client = client ?? HttpClient();

  final HttpClient _client;

  @override
  Future<Map<String, Object?>> getJson(Uri uri) async {
    final request = await _client
        .getUrl(uri)
        .timeout(const Duration(seconds: 8));
    request.headers.set(HttpHeaders.userAgentHeader, 'worker-rest-calendar');
    final response = await request.close().timeout(const Duration(seconds: 8));
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException('天气服务返回 ${response.statusCode}', uri: uri);
    }
    final body = await utf8.decoder.bind(response).join();
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('天气服务响应不是对象');
    }
    return decoded;
  }
}

final class OpenMeteoWeatherService implements WeatherService {
  OpenMeteoWeatherService({
    WeatherTransport? transport,
    DateTime Function()? now,
    this.cacheDuration = const Duration(minutes: 30),
  }) : _transport = transport ?? IoWeatherTransport(),
       _now = now ?? DateTime.now;

  final WeatherTransport _transport;
  final DateTime Function() _now;
  final Duration cacheDuration;
  final Map<String, WeatherSnapshot> _cache = {};

  @override
  Future<WeatherSnapshot> fetch(
    String city, {
    bool forceRefresh = false,
  }) async {
    final normalizedCity = city.trim().isEmpty ? '北京' : city.trim();
    final cached = _cache[normalizedCity];
    if (!forceRefresh &&
        cached != null &&
        _now().difference(cached.fetchedAt) < cacheDuration) {
      return cached;
    }

    try {
      final location = await _resolveLocation(normalizedCity);
      final current = await _fetchCurrent(
        latitude: location.latitude,
        longitude: location.longitude,
      );
      final snapshot = WeatherSnapshot(
        city: location.name,
        temperature: _number(current, 'temperature_2m'),
        apparentTemperature: _number(current, 'apparent_temperature'),
        weatherCode: _number(current, 'weather_code').round(),
        windSpeed: _number(current, 'wind_speed_10m'),
        humidity: _number(current, 'relative_humidity_2m').round(),
        fetchedAt: _now(),
      );
      _cache[normalizedCity] = snapshot;
      return snapshot;
    } on Object {
      if (cached != null) return cached;
      rethrow;
    }
  }

  Future<_WeatherLocation> _resolveLocation(String city) async {
    final response = await _transport.getJson(
      Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
        'name': city,
        'count': '1',
        'language': 'zh',
        'format': 'json',
      }),
    );
    final results = response['results'];
    if (results is! List<Object?> || results.isEmpty) {
      throw StateError('找不到城市“$city”');
    }
    final first = results.first;
    if (first is! Map<String, Object?>) throw const FormatException('城市响应无效');
    final name = first['name'];
    return _WeatherLocation(
      name: name is String && name.isNotEmpty ? name : city,
      latitude: _number(first, 'latitude'),
      longitude: _number(first, 'longitude'),
    );
  }

  Future<Map<String, Object?>> _fetchCurrent({
    required double latitude,
    required double longitude,
  }) async {
    final response = await _transport.getJson(
      Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': '$latitude',
        'longitude': '$longitude',
        'current':
            'temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m',
        'timezone': 'auto',
      }),
    );
    final current = response['current'];
    if (current is! Map<String, Object?>) {
      throw const FormatException('天气响应缺少 current');
    }
    return current;
  }

  double _number(Map<String, Object?> source, String key) {
    final value = source[key];
    if (value is num) return value.toDouble();
    throw FormatException('字段 $key 不是数字');
  }
}

final class _WeatherLocation {
  const _WeatherLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final double latitude;
  final double longitude;
}
