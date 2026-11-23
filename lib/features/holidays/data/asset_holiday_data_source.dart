import 'package:flutter/services.dart';
import 'package:worker_rest_calendar/features/holidays/application/holiday_data_source.dart';
import 'package:worker_rest_calendar/features/holidays/data/holiday_data_codec.dart';
import 'package:worker_rest_calendar/features/holidays/domain/holiday_data_bundle.dart';

final class AssetHolidayDataSource implements HolidayDataSource {
  AssetHolidayDataSource({
    AssetBundle? assetBundle,
    this.assetPath = 'assets/holidays/cn_2026.json',
    this.codec = const HolidayDataCodec(),
  }) : _assetBundle = assetBundle ?? rootBundle;

  final AssetBundle _assetBundle;
  final String assetPath;
  final HolidayDataCodec codec;

  @override
  Future<HolidayDataBundle> load() async =>
      codec.decode(await _assetBundle.loadString(assetPath));
}
