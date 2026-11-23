import 'package:worker_rest_calendar/features/holidays/domain/holiday_data_bundle.dart';

abstract interface class HolidayDataSource {
  Future<HolidayDataBundle> load();
}
