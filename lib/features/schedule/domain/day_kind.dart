enum DayKind {
  work,
  rest,
  adjustedWork,
  adjustedRest,
  leave;

  bool get isRest => this == rest || this == adjustedRest;

  bool get isActualWork => this == work || this == adjustedWork;

  bool get isBaseKind => this == work || this == rest;
}

enum WeekType {
  big,
  small;

  WeekType get opposite => this == big ? small : big;
}
