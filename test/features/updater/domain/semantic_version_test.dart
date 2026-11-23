import 'package:flutter_test/flutter_test.dart';
import 'package:worker_rest_calendar/features/updater/domain/semantic_version.dart';

void main() {
  group('SemanticVersion', () {
    test('解析带 v 和不带 v 的三段正式版本', () {
      expect(SemanticVersion.parse('v0.1.11'), const SemanticVersion(0, 1, 11));
      expect(SemanticVersion.parse('1.2.3'), const SemanticVersion(1, 2, 3));
    });

    test('按 major minor patch 比较', () {
      expect(
        SemanticVersion.parse(
              '0.1.12',
            ).compareTo(SemanticVersion.parse('0.1.11')) >
            0,
        isTrue,
      );
      expect(
        SemanticVersion.parse(
              '1.0.0',
            ).compareTo(SemanticVersion.parse('0.99.99')) >
            0,
        isTrue,
      );
      expect(
        SemanticVersion.parse(
          '0.1.10',
        ).compareTo(SemanticVersion.parse('0.1.10')),
        0,
      );
    });

    test('拒绝预发布、四段和不规范前导零', () {
      for (final value in ['v1.2.3-beta', '1.2.3.4', '01.2.3', 'latest']) {
        expect(() => SemanticVersion.parse(value), throwsFormatException);
      }
    });
  });
}
