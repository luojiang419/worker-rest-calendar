import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/holidays/data/holiday_data_codec.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';

void main() {
  test('官方 2026 数据包展开为 33 个休息日和 6 个调休上班日', () async {
    final input = await File('assets/holidays/cn_2026.json').readAsString();
    final bundle = const HolidayDataCodec().decode(input);

    expect(bundle.region, 'CN');
    expect(bundle.year, 2026);
    expect(bundle.dataVersion, 'CN-2026-2025-11-04');
    expect(bundle.source.documentNo, '国办发明电〔2025〕7号');
    expect(bundle.overrides, hasLength(39));
    expect(
      bundle.overrides.where((item) => item.kind == DayKind.adjustedRest),
      hasLength(33),
    );
    expect(
      bundle.overrides.where((item) => item.kind == DayKind.adjustedWork),
      hasLength(6),
    );

    final byDate = {for (final item in bundle.overrides) item.date: item};
    expect(byDate[CalendarDate(2026, 1, 1)]?.title, '元旦');
    expect(byDate[CalendarDate(2026, 1, 4)]?.title, '元旦调休上班');
    expect(byDate[CalendarDate(2026, 2, 15)]?.title, '春节');
    expect(byDate[CalendarDate(2026, 10, 7)]?.title, '国庆节');
    expect(byDate[CalendarDate(2026, 10, 10)]?.kind, DayKind.adjustedWork);
  });

  test('拒绝重复日期和跨年日期', () {
    const duplicate = '''
{
  "schemaVersion":"1.0.0",
  "region":"CN",
  "year":2026,
  "dataVersion":"test",
  "publishedAt":"2025-11-04T00:00:00Z",
  "source":{"title":"公告","documentNo":"文号","url":"https://example.invalid"},
  "holidays":[
    {"name":"甲","restDays":["2026-01-01"],"workDays":[]},
    {"name":"乙","restDays":[],"workDays":["2026-01-01"]}
  ]
}
''';
    const crossYear = '''
{
  "schemaVersion":"1.0.0",
  "region":"CN",
  "year":2026,
  "dataVersion":"test",
  "publishedAt":"2025-11-04T00:00:00Z",
  "source":{"title":"公告","documentNo":"文号","url":"https://example.invalid"},
  "holidays":[
    {"name":"元旦","restDays":["2027-01-01"],"workDays":[]}
  ]
}
''';

    expect(
      () => const HolidayDataCodec().decode(duplicate),
      throwsFormatException,
    );
    expect(
      () => const HolidayDataCodec().decode(crossYear),
      throwsFormatException,
    );
  });
}
