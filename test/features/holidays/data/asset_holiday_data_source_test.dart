import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/features/holidays/data/asset_holiday_data_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('实际应用资源包含两个年度，避免跨年只读取旧包', () async {
    final bundles = await AssetHolidayDataSource().load();
    expect(bundles.map((bundle) => bundle.year), [2026, 2027]);
    expect(bundles.map((bundle) => bundle.overrides.length), [39, 34]);
  });
}
