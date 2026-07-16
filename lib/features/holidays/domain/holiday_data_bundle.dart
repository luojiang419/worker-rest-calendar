import 'dart:collection';

import 'package:worker_rest_calendar/features/schedule/domain/stored_holiday_override.dart';

final class HolidayDataSourceInfo {
  const HolidayDataSourceInfo({
    required this.title,
    required this.documentNo,
    required this.url,
  });

  final String title;
  final String documentNo;
  final String url;
}

final class HolidayDataBundle {
  HolidayDataBundle({
    required this.schemaVersion,
    required this.region,
    required this.year,
    required this.dataVersion,
    required this.publishedAt,
    required this.source,
    required List<StoredHolidayOverride> overrides,
  }) : overrides = UnmodifiableListView(overrides);

  static const currentSchemaVersion = '1.0.0';

  final String schemaVersion;
  final String region;
  final int year;
  final String dataVersion;
  final DateTime publishedAt;
  final HolidayDataSourceInfo source;
  final List<StoredHolidayOverride> overrides;
}
