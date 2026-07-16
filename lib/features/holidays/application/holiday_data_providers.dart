import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_rest_calendar/app/app_dependencies.dart';
import 'package:worker_rest_calendar/features/holidays/application/holiday_data_installer.dart';
import 'package:worker_rest_calendar/features/holidays/application/holiday_data_source.dart';
import 'package:worker_rest_calendar/features/holidays/data/asset_holiday_data_source.dart';

final holidayDataSourceProvider = Provider<HolidayDataSource>(
  (ref) => AssetHolidayDataSource(),
);

final holidayDataBootstrapProvider = FutureProvider<bool>((ref) async {
  final bundle = await ref.watch(holidayDataSourceProvider).load();
  return HolidayDataInstaller(
    ref.watch(scheduleRepositoryProvider),
  ).install(bundle);
});
