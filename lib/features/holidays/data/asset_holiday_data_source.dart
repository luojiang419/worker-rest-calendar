import 'package:flutter/services.dart';
import 'package:worker_rest_calendar/features/holidays/application/holiday_data_source.dart';
import 'package:worker_rest_calendar/features/holidays/data/holiday_data_codec.dart';
import 'package:worker_rest_calendar/features/holidays/domain/holiday_data_bundle.dart';

final class AssetHolidayDataSource implements HolidayDataSource {
  AssetHolidayDataSource({
    AssetBundle? assetBundle,
    this.assetPaths = const [
      'assets/holidays/cn_2026.json',
      'assets/holidays/cn_2027.json',
    ],
    this.codec = const HolidayDataCodec(),
  }) : _assetBundle = assetBundle ?? rootBundle;

  final AssetBundle _assetBundle;
  final List<String> assetPaths;
  final HolidayDataCodec codec;

  @override
  Future<List<HolidayDataBundle>> load() async => Future.wait([
    for (final path in assetPaths)
      _assetBundle.loadString(path).then(codec.decode),
  ]);
}
