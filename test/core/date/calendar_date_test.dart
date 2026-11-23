import 'package:test/test.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/core/date/calendar_math.dart';

void main() {
  group('CalendarDate', () {
    test('解析和格式化严格使用 YYYY-MM-DD', () {
      final date = CalendarDate.parse('2026-07-12');

      expect(date, CalendarDate(2026, 7, 12));
      expect(date.toString(), '2026-07-12');
      expect(() => CalendarDate.parse('2026-7-12'), throwsFormatException);
      expect(() => CalendarDate(2026, 2, 29), throwsArgumentError);
    });

    test('跨年和闰年按公历天推进', () {
      expect(CalendarDate(2023, 12, 31).addDays(1), CalendarDate(2024, 1, 1));
      expect(CalendarDate(2024, 2, 28).addDays(1), CalendarDate(2024, 2, 29));
      expect(CalendarDate(2024, 2, 29).addDays(1), CalendarDate(2024, 3, 1));
    });

    test('只提取年月日，不受 DateTime 时刻和 UTC 标记影响', () {
      final localLike = DateTime(2026, 3, 8, 23, 59);
      final utc = DateTime.utc(2026, 3, 8, 1);

      expect(CalendarDate.fromDateTime(localLike), CalendarDate(2026, 3, 8));
      expect(CalendarDate.fromDateTime(utc), CalendarDate(2026, 3, 8));
    });

    test('周一归一化和日期差支持负向日期', () {
      final sunday = CalendarDate(2026, 7, 12);

      expect(sunday.monday, CalendarDate(2026, 7, 6));
      expect(CalendarDate(2026, 7, 5).daysSince(sunday), -7);
    });
  });

  group('calendar math', () {
    test('floorDiv 使用数学向下取整而不是向零截断', () {
      expect(floorDiv(8, 7), 1);
      expect(floorDiv(-1, 7), -1);
      expect(floorDiv(-8, 7), -2);
      expect(() => floorDiv(1, 0), throwsArgumentError);
    });

    test('positiveModulo 始终落在 0 到 modulus-1', () {
      expect(positiveModulo(8, 7), 1);
      expect(positiveModulo(-1, 7), 6);
      expect(positiveModulo(-8, 7), 6);
      expect(() => positiveModulo(1, 0), throwsArgumentError);
    });
  });
}
