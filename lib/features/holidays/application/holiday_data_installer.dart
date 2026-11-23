import 'package:worker_rest_calendar/features/holidays/domain/holiday_data_bundle.dart';
import 'package:worker_rest_calendar/features/schedule/application/schedule_repository.dart';
import 'package:worker_rest_calendar/features/schedule/domain/stored_holiday_override.dart';

final class HolidayDataInstaller {
  const HolidayDataInstaller(this._repository);

  final ScheduleRepository _repository;

  Future<bool> install(HolidayDataBundle bundle) async {
    final installed = (await _repository.getHolidayOverrides(
      bundle.region,
    )).where((item) => item.date.year == bundle.year).toList(growable: false);
    if (_matches(installed, bundle)) return false;
    await _repository.saveHolidayOverrides(bundle.overrides);
    return true;
  }

  bool _matches(
    List<StoredHolidayOverride> installed,
    HolidayDataBundle bundle,
  ) {
    if (installed.length != bundle.overrides.length) return false;
    final byDate = {for (final item in installed) item.date: item};
    for (final expected in bundle.overrides) {
      final actual = byDate[expected.date];
      if (actual == null ||
          actual.kind != expected.kind ||
          actual.title != expected.title ||
          actual.dataVersion != bundle.dataVersion) {
        return false;
      }
    }
    return true;
  }
}
