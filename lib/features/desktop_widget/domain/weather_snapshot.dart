final class WeatherSnapshot {
  const WeatherSnapshot({
    required this.city,
    required this.temperature,
    required this.apparentTemperature,
    required this.weatherCode,
    required this.windSpeed,
    required this.humidity,
    required this.fetchedAt,
  });

  final String city;
  final double temperature;
  final double apparentTemperature;
  final int weatherCode;
  final double windSpeed;
  final int humidity;
  final DateTime fetchedAt;

  String get description => weatherCodeDescription(weatherCode);
}

String weatherCodeDescription(int code) => switch (code) {
  0 => '晴朗',
  1 => '大部晴朗',
  2 => '局部多云',
  3 => '阴天',
  45 || 48 => '有雾',
  51 || 53 || 55 => '毛毛雨',
  56 || 57 => '冻毛毛雨',
  61 || 63 || 65 => '下雨',
  66 || 67 => '冻雨',
  71 || 73 || 75 || 77 => '下雪',
  80 || 81 || 82 => '阵雨',
  85 || 86 => '阵雪',
  95 || 96 || 99 => '雷雨',
  _ => '天气变化',
};
