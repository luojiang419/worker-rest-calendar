import 'package:worker_rest_calendar/features/desktop_widget/domain/weather_snapshot.dart';

abstract interface class WeatherService {
  Future<WeatherSnapshot> fetch(String city, {bool forceRefresh = false});
}
