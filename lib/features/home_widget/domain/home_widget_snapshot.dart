import 'dart:convert';

import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/schedule/application/active_schedule_controller.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/settings/domain/app_preferences.dart';

final class HomeWidgetSnapshot {
  HomeWidgetSnapshot({
    required this.generatedAt,
    required this.theme,
    required List<HomeWidgetDaySnapshot> days,
    required List<HomeWidgetMonthSnapshot> months,
  }) : days = List.unmodifiable(days),
       months = List.unmodifiable(months);

  factory HomeWidgetSnapshot.build({
    required ActiveScheduleState schedule,
    required CalendarDate today,
    required DateTime generatedAt,
    required AppThemePreference theme,
    int horizonDays = 62,
    int horizonMonths = 3,
  }) {
    if (horizonDays < 1 || horizonMonths < 1) {
      throw ArgumentError('小组件快照范围必须大于 0');
    }
    final days = List.generate(horizonDays, (index) {
      final date = today.addDays(index);
      final resolved = schedule.day(date);
      final daysToRest = schedule.engine.daysToNextRest(date);
      return HomeWidgetDaySnapshot(
        date: date,
        kind: resolved.effectiveKind,
        weekType: resolved.weekType,
        daysToNextRest: daysToRest,
        nextRestDate: date.addDays(daysToRest),
        week: schedule
            .days(date.monday, DateTime.daysPerWeek)
            .map((day) => day.effectiveKind)
            .toList(growable: false),
      );
    }, growable: false);
    final months = List.generate(horizonMonths, (index) {
      final normalizedMonth = DateTime.utc(today.year, today.month + index, 1);
      final month = CalendarDate(
        normalizedMonth.year,
        normalizedMonth.month,
        1,
      );
      final gridStart = month.monday;
      return HomeWidgetMonthSnapshot(
        month: month,
        days: schedule
            .days(gridStart, 42)
            .map(
              (day) => HomeWidgetCalendarDay(
                date: day.date,
                kind: day.effectiveKind,
              ),
            )
            .toList(growable: false),
      );
    }, growable: false);
    return HomeWidgetSnapshot(
      generatedAt: generatedAt.toUtc(),
      theme: theme,
      days: days,
      months: months,
    );
  }

  factory HomeWidgetSnapshot.fromJsonString(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('小组件快照必须是 JSON 对象');
    }
    final version = decoded['version'];
    if (version != currentVersion) {
      throw FormatException('不支持的小组件快照版本：$version');
    }
    final days = decoded['days'];
    final months = decoded['months'];
    if (days is! List<Object?> || months is! List<Object?>) {
      throw const FormatException('小组件快照缺少日期数据');
    }
    return HomeWidgetSnapshot(
      generatedAt: DateTime.parse(decoded['generatedAt']! as String),
      theme: AppThemePreference.values.byName(decoded['theme']! as String),
      days: days
          .map(
            (item) => HomeWidgetDaySnapshot.fromJson(
              (item! as Map<Object?, Object?>).cast<String, Object?>(),
            ),
          )
          .toList(growable: false),
      months: months
          .map(
            (item) => HomeWidgetMonthSnapshot.fromJson(
              (item! as Map<Object?, Object?>).cast<String, Object?>(),
            ),
          )
          .toList(growable: false),
    );
  }

  static const currentVersion = 1;

  final DateTime generatedAt;
  final AppThemePreference theme;
  final List<HomeWidgetDaySnapshot> days;
  final List<HomeWidgetMonthSnapshot> months;

  String toJsonString() => jsonEncode({
    'version': currentVersion,
    'generatedAt': generatedAt.toUtc().toIso8601String(),
    'theme': theme.name,
    'days': days.map((day) => day.toJson()).toList(growable: false),
    'months': months.map((month) => month.toJson()).toList(growable: false),
  });
}

final class HomeWidgetDaySnapshot {
  HomeWidgetDaySnapshot({
    required this.date,
    required this.kind,
    required this.weekType,
    required this.daysToNextRest,
    required this.nextRestDate,
    required List<DayKind> week,
  }) : week = List.unmodifiable(week);

  factory HomeWidgetDaySnapshot.fromJson(Map<String, Object?> json) =>
      HomeWidgetDaySnapshot(
        date: CalendarDate.parse(json['date']! as String),
        kind: DayKind.values.byName(json['kind']! as String),
        weekType: json['weekType'] == null
            ? null
            : WeekType.values.byName(json['weekType']! as String),
        daysToNextRest: json['daysToNextRest']! as int,
        nextRestDate: CalendarDate.parse(json['nextRestDate']! as String),
        week: (json['week']! as List<Object?>)
            .map((value) => DayKind.values.byName(value! as String))
            .toList(growable: false),
      );

  final CalendarDate date;
  final DayKind kind;
  final WeekType? weekType;
  final int daysToNextRest;
  final CalendarDate nextRestDate;
  final List<DayKind> week;

  Map<String, Object?> toJson() => {
    'date': date.toString(),
    'kind': kind.name,
    'weekType': weekType?.name,
    'daysToNextRest': daysToNextRest,
    'nextRestDate': nextRestDate.toString(),
    'week': week.map((kind) => kind.name).toList(growable: false),
  };
}

final class HomeWidgetMonthSnapshot {
  HomeWidgetMonthSnapshot({
    required this.month,
    required List<HomeWidgetCalendarDay> days,
  }) : days = List.unmodifiable(days);

  factory HomeWidgetMonthSnapshot.fromJson(Map<String, Object?> json) =>
      HomeWidgetMonthSnapshot(
        month: CalendarDate.parse(json['month']! as String),
        days: (json['days']! as List<Object?>)
            .map(
              (item) => HomeWidgetCalendarDay.fromJson(
                (item! as Map<Object?, Object?>).cast<String, Object?>(),
              ),
            )
            .toList(growable: false),
      );

  final CalendarDate month;
  final List<HomeWidgetCalendarDay> days;

  Map<String, Object?> toJson() => {
    'month': month.toString(),
    'days': days.map((day) => day.toJson()).toList(growable: false),
  };
}

final class HomeWidgetCalendarDay {
  const HomeWidgetCalendarDay({required this.date, required this.kind});

  factory HomeWidgetCalendarDay.fromJson(Map<String, Object?> json) =>
      HomeWidgetCalendarDay(
        date: CalendarDate.parse(json['date']! as String),
        kind: DayKind.values.byName(json['kind']! as String),
      );

  final CalendarDate date;
  final DayKind kind;

  Map<String, Object?> toJson() => {'date': date.toString(), 'kind': kind.name};
}
