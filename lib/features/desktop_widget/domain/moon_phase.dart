import 'dart:math' as math;

enum MoonPhaseName {
  newMoon('新月'),
  waxingCrescent('蛾眉月'),
  firstQuarter('上弦月'),
  waxingGibbous('盈凸月'),
  fullMoon('满月'),
  waningGibbous('亏凸月'),
  lastQuarter('下弦月'),
  waningCrescent('残月');

  const MoonPhaseName(this.label);

  final String label;
}

final class MoonPhase {
  const MoonPhase({
    required this.cycleFraction,
    required this.illumination,
    required this.ageInDays,
    required this.name,
  });

  factory MoonPhase.forDate(DateTime date) {
    final instant = date.toUtc();
    final days = instant.difference(_referenceNewMoon).inSeconds / 86400;
    final fraction = ((days / synodicMonthDays) % 1 + 1) % 1;
    final illumination = (1 - math.cos(2 * math.pi * fraction)) / 2;
    return MoonPhase(
      cycleFraction: fraction,
      illumination: illumination,
      ageInDays: fraction * synodicMonthDays,
      name: _nameFor(fraction),
    );
  }

  static const synodicMonthDays = 29.53058867;
  static final _referenceNewMoon = DateTime.utc(2000, 1, 6, 18, 14);

  final double cycleFraction;
  final double illumination;
  final double ageInDays;
  final MoonPhaseName name;

  bool get waxing => cycleFraction < 0.5;

  double get daysUntilNextFullMoon {
    final delta = 0.5 - cycleFraction;
    return (delta >= 0 ? delta : delta + 1) * synodicMonthDays;
  }

  static MoonPhaseName _nameFor(double fraction) {
    final segment = ((fraction * 8) + 0.5).floor() % 8;
    return MoonPhaseName.values[segment];
  }
}
