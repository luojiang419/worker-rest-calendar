final class CountdownTarget {
  const CountdownTarget({required this.title, required this.date});

  final String title;
  final DateTime date;

  int daysFrom(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    return target.difference(today).inDays;
  }

  static CountdownTarget? tryParse({
    required String title,
    required String isoDate,
  }) {
    final parsed = DateTime.tryParse(isoDate);
    if (parsed == null) return null;
    return CountdownTarget(
      title: title.trim().isEmpty ? '重要日子' : title.trim(),
      date: DateTime(parsed.year, parsed.month, parsed.day),
    );
  }
}
