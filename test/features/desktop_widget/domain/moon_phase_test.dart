import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/features/desktop_widget/domain/moon_phase.dart';

void main() {
  test('参考时刻为新月', () {
    final phase = MoonPhase.forDate(DateTime.utc(2000, 1, 6, 18, 14));

    expect(phase.name, MoonPhaseName.newMoon);
    expect(phase.illumination, closeTo(0, 0.001));
  });

  test('半个朔望月后接近满月', () {
    final phase = MoonPhase.forDate(
      DateTime.utc(2000, 1, 6, 18, 14).add(
        Duration(seconds: (MoonPhase.synodicMonthDays * 86400 / 2).round()),
      ),
    );

    expect(phase.name, MoonPhaseName.fullMoon);
    expect(phase.illumination, closeTo(1, 0.001));
  });

  test('锚点之前日期仍得到规范化周期', () {
    final phase = MoonPhase.forDate(DateTime.utc(1999, 12, 30));

    expect(phase.cycleFraction, inInclusiveRange(0, 1));
    expect(phase.illumination, inInclusiveRange(0, 1));
  });
}
