import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_rest_calendar/app/app_dependencies.dart';
import 'package:worker_rest_calendar/features/holidays/application/holiday_data_installer.dart';
import 'package:worker_rest_calendar/features/holidays/application/holiday_data_source.dart';
import 'package:worker_rest_calendar/features/holidays/data/asset_holiday_data_source.dart';

final holidayDataSourceProvider = Provider<HolidayDataSource>(
  (ref) => AssetHolidayDataSource(),
);

final holidayDataBootstrapProvider = FutureProvider<bool>((ref) async {
  final bundles = await ref.watch(holidayDataSourceProvider).load();
  final installer = HolidayDataInstaller(ref.watch(scheduleRepositoryProvider));
  var changed = false;
  for (final bundle in bundles) {
    changed = await installer.install(bundle) || changed;
  }
  return changed;
});
