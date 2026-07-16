import 'package:worker_rest_calendar/core/date/calendar_date.dart';
import 'package:worker_rest_calendar/features/schedule/domain/schedule_profile.dart';
import 'package:worker_rest_calendar/features/schedule/domain/stored_day_override.dart';
import 'package:worker_rest_calendar/features/schedule/domain/stored_holiday_override.dart';

abstract interface class ScheduleRepository {
  Stream<ScheduleProfile?> watchActiveProfile();

  Future<ScheduleProfile?> getActiveProfile();

  Future<List<ScheduleProfile>> getProfiles({bool includeDeleted = false});

  Future<ScheduleProfile?> getProfile(String id);

  Future<void> saveProfile(ScheduleProfile profile);

  Future<void> setActiveProfile(String id, {required DateTime updatedAt});

  Future<void> softDeleteProfile(String id, {required DateTime deletedAt});

  Future<List<StoredDayOverride>> getDayOverrides(
    String profileId, {
    bool includeDeleted = false,
  });

  Future<void> saveDayOverride(StoredDayOverride override);

  Future<void> softDeleteDayOverride({
    required String profileId,
    required CalendarDate date,
    required DateTime deletedAt,
  });

  Future<List<StoredHolidayOverride>> getHolidayOverrides(String region);

  Future<void> saveHolidayOverrides(List<StoredHolidayOverride> overrides);
}
