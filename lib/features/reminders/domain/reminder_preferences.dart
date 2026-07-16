final class ReminderPreferences {
  const ReminderPreferences({
    this.dailyNextDayEnabled = false,
    this.dailyNextDayTime = '20:00',
    this.adjustedWorkEnabled = true,
    this.adjustedWorkLeadDays = 1,
    this.weeklyPreviewEnabled = false,
    this.weeklyPreviewWeekday = DateTime.sunday,
    this.weeklyPreviewTime = '20:00',
    this.countdownEnabled = false,
    this.timeZoneId = 'local',
  });

  final bool dailyNextDayEnabled;
  final String dailyNextDayTime;
  final bool adjustedWorkEnabled;
  final int adjustedWorkLeadDays;
  final bool weeklyPreviewEnabled;
  final int weeklyPreviewWeekday;
  final String weeklyPreviewTime;
  final bool countdownEnabled;
  final String timeZoneId;

  bool get hasAnyReminderEnabled =>
      dailyNextDayEnabled ||
      adjustedWorkEnabled ||
      weeklyPreviewEnabled ||
      countdownEnabled;

  ReminderPreferences copyWith({
    bool? dailyNextDayEnabled,
    String? dailyNextDayTime,
    bool? adjustedWorkEnabled,
    int? adjustedWorkLeadDays,
    bool? weeklyPreviewEnabled,
    int? weeklyPreviewWeekday,
    String? weeklyPreviewTime,
    bool? countdownEnabled,
    String? timeZoneId,
  }) => ReminderPreferences(
    dailyNextDayEnabled: dailyNextDayEnabled ?? this.dailyNextDayEnabled,
    dailyNextDayTime: dailyNextDayTime ?? this.dailyNextDayTime,
    adjustedWorkEnabled: adjustedWorkEnabled ?? this.adjustedWorkEnabled,
    adjustedWorkLeadDays: adjustedWorkLeadDays ?? this.adjustedWorkLeadDays,
    weeklyPreviewEnabled: weeklyPreviewEnabled ?? this.weeklyPreviewEnabled,
    weeklyPreviewWeekday: weeklyPreviewWeekday ?? this.weeklyPreviewWeekday,
    weeklyPreviewTime: weeklyPreviewTime ?? this.weeklyPreviewTime,
    countdownEnabled: countdownEnabled ?? this.countdownEnabled,
    timeZoneId: timeZoneId ?? this.timeZoneId,
  );
}
