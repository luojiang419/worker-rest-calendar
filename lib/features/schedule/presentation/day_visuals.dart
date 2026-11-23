import 'package:flutter/material.dart';
import 'package:worker_rest_calendar/core/theme/app_tokens.dart';
import 'package:worker_rest_calendar/features/schedule/domain/day_kind.dart';

Color dayKindColor(AppTokens tokens, DayKind kind) => switch (kind) {
  DayKind.work => tokens.colors.work,
  DayKind.rest => tokens.colors.rest,
  DayKind.adjustedWork => tokens.colors.adjustedWork,
  DayKind.adjustedRest => tokens.colors.adjustedRest,
  DayKind.leave => tokens.colors.leave,
};

IconData dayKindIcon(DayKind kind) => switch (kind) {
  DayKind.work => Icons.work_outline_rounded,
  DayKind.rest => Icons.weekend_outlined,
  DayKind.adjustedWork => Icons.event_busy_outlined,
  DayKind.adjustedRest => Icons.event_available_outlined,
  DayKind.leave => Icons.beach_access_outlined,
};
