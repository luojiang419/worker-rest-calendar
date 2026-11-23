import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/features/desktop_widget/data/open_meteo_weather_service.dart';

void main() {
  test('解析城市与当前天气并在有效期内复用缓存', () async {
    final transport = _FakeWeatherTransport();
    final service = OpenMeteoWeatherService(
      transport: transport,
      now: () => DateTime(2026, 7, 16, 12),
    );

    final first = await service.fetch('北京');
    final second = await service.fetch('北京');

    expect(first.city, '北京市');
    expect(first.temperature, 31.5);
    expect(first.humidity, 62);
    expect(second, same(first));
    expect(transport.requests, hasLength(2));
  });

  test('刷新失败时回退到已有缓存', () async {
    final transport = _FakeWeatherTransport();
    final service = OpenMeteoWeatherService(transport: transport);
    final cached = await service.fetch('北京');
    transport.fail = true;

    final fallback = await service.fetch('北京', forceRefresh: true);

    expect(fallback, same(cached));
  });
}

final class _FakeWeatherTransport implements WeatherTransport {
  final requests = <Uri>[];
  bool fail = false;

  @override
  Future<Map<String, Object?>> getJson(Uri uri) async {
    requests.add(uri);
    if (fail) throw StateError('offline');
    if (uri.host.startsWith('geocoding')) {
      return {
        'results': [
          {'name': '北京市', 'latitude': 39.9, 'longitude': 116.4},
        ],
      };
    }
    return {
      'current': {
        'temperature_2m': 31.5,
        'relative_humidity_2m': 62,
        'apparent_temperature': 34.1,
        'weather_code': 2,
        'wind_speed_10m': 8.4,
      },
    };
  }
}
