import 'dart:convert';

import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/holidays/domain/holiday_data_bundle.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/schedule/domain/stored_holiday_override.dart';

final class HolidayDataCodec {
  const HolidayDataCodec();

  HolidayDataBundle decode(String input) {
    final root = _map(jsonDecode(input), 'root');
    final schemaVersion = _string(root['schemaVersion'], 'schemaVersion');
    if (schemaVersion != HolidayDataBundle.currentSchemaVersion) {
      throw FormatException('不支持的节假日数据版本：$schemaVersion');
    }
    final region = _string(root['region'], 'region');
    final year = _integer(root['year'], 'year');
    final dataVersion = _string(root['dataVersion'], 'dataVersion');
    final publishedAt = DateTime.parse(
      _string(root['publishedAt'], 'publishedAt'),
    ).toUtc();
    final sourceJson = _map(root['source'], 'source');
    final source = HolidayDataSourceInfo(
      title: _string(sourceJson['title'], 'source.title'),
      documentNo: _string(sourceJson['documentNo'], 'source.documentNo'),
      url: _string(sourceJson['url'], 'source.url'),
    );
    final holidays = _list(root['holidays'], 'holidays');
    final seenDates = <CalendarDate>{};
    final overrides = <StoredHolidayOverride>[];

    for (var index = 0; index < holidays.length; index++) {
      final holiday = _map(holidays[index], 'holidays[$index]');
      final name = _string(holiday['name'], 'holidays[$index].name');
      _appendDates(
        values: _list(holiday['restDays'], 'holidays[$index].restDays'),
        kind: DayKind.adjustedRest,
        title: name,
        year: year,
        region: region,
        dataVersion: dataVersion,
        publishedAt: publishedAt,
        seenDates: seenDates,
        output: overrides,
      );
      _appendDates(
        values: _list(holiday['workDays'], 'holidays[$index].workDays'),
        kind: DayKind.adjustedWork,
        title: '$name调休上班',
        year: year,
        region: region,
        dataVersion: dataVersion,
        publishedAt: publishedAt,
        seenDates: seenDates,
        output: overrides,
      );
    }
    overrides.sort((left, right) => left.date.compareTo(right.date));
    return HolidayDataBundle(
      schemaVersion: schemaVersion,
      region: region,
      year: year,
      dataVersion: dataVersion,
      publishedAt: publishedAt,
      source: source,
      overrides: overrides,
    );
  }

  void _appendDates({
    required List<Object?> values,
    required DayKind kind,
    required String title,
    required int year,
    required String region,
    required String dataVersion,
    required DateTime publishedAt,
    required Set<CalendarDate> seenDates,
    required List<StoredHolidayOverride> output,
  }) {
    for (final value in values) {
      final date = CalendarDate.parse(_string(value, 'holiday.date'));
      if (date.year != year) {
        throw FormatException('节假日日期不属于数据年份：$date');
      }
      if (!seenDates.add(date)) {
        throw FormatException('节假日日期重复：$date');
      }
      output.add(
        StoredHolidayOverride(
          date: date,
          kind: kind,
          title: title,
          region: region,
          dataVersion: dataVersion,
          updatedAt: publishedAt,
        ),
      );
    }
  }

  Map<String, Object?> _map(Object? value, String field) {
    if (value is! Map<String, dynamic>) {
      throw FormatException('$field 必须是对象');
    }
    return value;
  }

  List<Object?> _list(Object? value, String field) {
    if (value is! List<dynamic>) {
      throw FormatException('$field 必须是数组');
    }
    return value;
  }

  String _string(Object? value, String field) {
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('$field 必须是非空字符串');
    }
    return value;
  }

  int _integer(Object? value, String field) {
    if (value is! int) throw FormatException('$field 必须是整数');
    return value;
  }
}
