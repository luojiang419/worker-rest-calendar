enum DayKind {
  work,
  rest,
  adjustedWork,
  adjustedRest,
  leave;

  bool get isRest => this == rest || this == adjustedRest;
  bool get isActualWork => this == work || this == adjustedWork;
}

enum WeekType { big, small }
