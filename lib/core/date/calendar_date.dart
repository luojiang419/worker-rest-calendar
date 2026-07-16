/// 不携带时间和时区的公历日期值。
final class CalendarDate implements Comparable<CalendarDate> {
  CalendarDate(this.year, this.month, this.day) {
    final normalized = DateTime.utc(year, month, day);
    if (normalized.year != year ||
        normalized.month != month ||
        normalized.day != day) {
      throw ArgumentError.value('$year-$month-$day', 'date', '不是有效的公历日期');
    }
  }

  factory CalendarDate.fromDateTime(DateTime value) =>
      CalendarDate(value.year, value.month, value.day);

  factory CalendarDate.parse(String value) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
    if (match == null) {
      throw FormatException('日期必须使用 YYYY-MM-DD 格式', value);
    }

    return CalendarDate(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }

  final int year;
  final int month;
  final int day;

  int get weekday => _asUtc.weekday;

  CalendarDate get monday => addDays(DateTime.monday - weekday);

  DateTime get _asUtc => DateTime.utc(year, month, day);

  CalendarDate addDays(int days) {
    final result = _asUtc.add(Duration(days: days));
    return CalendarDate(result.year, result.month, result.day);
  }

  int daysSince(CalendarDate other) => _asUtc.difference(other._asUtc).inDays;

  @override
  int compareTo(CalendarDate other) => daysSince(other);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarDate &&
          year == other.year &&
          month == other.month &&
          day == other.day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() {
    String pad(int value, int width) => value.toString().padLeft(width, '0');
    return '${pad(year, 4)}-${pad(month, 2)}-${pad(day, 2)}';
  }
}
