import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worker_rest_calendar/app/app_dependencies.dart';
import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/schedule/application/day_presentation.dart';
import 'package:worker_rest_calendar/features/schedule/application/schedule_pattern_builder.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_override.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_engine.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_profile.dart';
import 'package:worker_rest_calendar/features/schedule/domain/stored_day_override.dart';
import 'package:worker_rest_calendar/features/schedule/domain/stored_holiday_override.dart';

final activeScheduleControllerProvider =
    AsyncNotifierProvider<ActiveScheduleController, ActiveScheduleState>(
      ActiveScheduleController.new,
      retry: (retryCount, error) => null,
    );

final scheduleRefreshEventProvider =
    NotifierProvider<ScheduleRefreshEventController, ScheduleRefreshEvent?>(
      ScheduleRefreshEventController.new,
    );

enum ScheduleMutationType { saveOverride, deleteOverride }

final class ScheduleRefreshEvent {
  const ScheduleRefreshEvent({
    required this.sequence,
    required this.date,
    required this.type,
    required this.occurredAt,
  });

  final int sequence;
  final CalendarDate date;
  final ScheduleMutationType type;
  final DateTime occurredAt;
}

final class ScheduleRefreshEventController
    extends Notifier<ScheduleRefreshEvent?> {
  var _sequence = 0;

  @override
  ScheduleRefreshEvent? build() => null;

  void publish({
    required CalendarDate date,
    required ScheduleMutationType type,
    required DateTime occurredAt,
  }) {
    _sequence++;
    state = ScheduleRefreshEvent(
      sequence: _sequence,
      date: date,
      type: type,
      occurredAt: occurredAt,
    );
  }
}

final class ActiveScheduleState {
  ActiveScheduleState({
    required this.profile,
    required this.engine,
    required List<StoredDayOverride> manualOverrides,
    required List<StoredHolidayOverride> holidayOverrides,
  }) : manualOverrides = UnmodifiableListView(manualOverrides),
       holidayOverrides = UnmodifiableListView(holidayOverrides);

  final ScheduleProfile profile;
  final ScheduleEngine engine;
  final List<StoredDayOverride> manualOverrides;
  final List<StoredHolidayOverride> holidayOverrides;

  DayPresentation day(CalendarDate date) =>
      DayPresentation.fromResolvedDay(engine.resolve(date));

  List<DayPresentation> days(CalendarDate start, int count) => List.generate(
    count,
    (index) => day(start.addDays(index)),
    growable: false,
  );

  StoredDayOverride? manualOverrideFor(CalendarDate date) {
    for (final override in manualOverrides) {
      if (override.date == date) {
        return override;
      }
    }
    return null;
  }
}

final class ActiveScheduleController
    extends AsyncNotifier<ActiveScheduleState> {
  @override
  Future<ActiveScheduleState> build() => _load();

  Future<void> saveManualOverride({
    required CalendarDate date,
    required DayKind kind,
    required int overtimeMinutes,
    String? note,
  }) async {
    if (overtimeMinutes < 0) {
      throw ArgumentError.value(overtimeMinutes, 'overtimeMinutes', '不能小于 0');
    }
    final current = state.requireValue;
    final existing = current.manualOverrideFor(date);
    final now = ref.read(utcNowProvider)();
    final normalizedNote = note?.trim();
    await ref
        .read(scheduleRepositoryProvider)
        .saveDayOverride(
          StoredDayOverride(
            id: existing?.id ?? ref.read(dayOverrideIdProvider)(),
            date: date,
            profileId: current.profile.id,
            kind: kind,
            overtimeMinutes: overtimeMinutes,
            note: normalizedNote == null || normalizedNote.isEmpty
                ? null
                : normalizedNote,
            source: StoredOverrideSource.manual,
            createdAt: existing?.createdAt ?? now,
            updatedAt: now,
          ),
        );
    state = AsyncData(await _load());
    _publishRefresh(date, ScheduleMutationType.saveOverride, now);
  }

  Future<bool> deleteManualOverride(CalendarDate date) async {
    final current = state.requireValue;
    if (current.manualOverrideFor(date) == null) {
      return false;
    }
    final now = ref.read(utcNowProvider)();
    await ref
        .read(scheduleRepositoryProvider)
        .softDeleteDayOverride(
          profileId: current.profile.id,
          date: date,
          deletedAt: now,
        );
    state = AsyncData(await _load());
    _publishRefresh(date, ScheduleMutationType.deleteOverride, now);
    return true;
  }

  Future<ActiveScheduleState> _load() async {
    final repository = ref.watch(scheduleRepositoryProvider);
    final profile = await repository.getActiveProfile();
    if (profile == null) {
      throw StateError('还没有可用的 active profile');
    }

    final manualOverrides = await repository.getDayOverrides(profile.id);
    final holidayOverrides = profile.holidayOverridesEnabled
        ? await repository.getHolidayOverrides('CN')
        : const <StoredHolidayOverride>[];
    final manualMap = {
      for (final override in manualOverrides)
        override.date: DayOverride(
          kind: override.kind,
          overtimeMinutes: override.overtimeMinutes,
          note: override.note,
        ),
    };
    final holidayMap = {
      for (final override in holidayOverrides)
        override.date: DayOverride(kind: override.kind, note: override.title),
    };

    return ActiveScheduleState(
      profile: profile,
      engine: ScheduleEngine(
        pattern: buildPatternFromProfile(profile),
        holidayOverrides: holidayMap,
        manualOverrides: manualMap,
      ),
      manualOverrides: manualOverrides,
      holidayOverrides: holidayOverrides,
    );
  }

  void _publishRefresh(
    CalendarDate date,
    ScheduleMutationType type,
    DateTime occurredAt,
  ) {
    ref
        .read(scheduleRefreshEventProvider.notifier)
        .publish(date: date, type: type, occurredAt: occurredAt);
  }
}
