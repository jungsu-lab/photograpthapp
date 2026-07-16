import 'package:framefit/services/device_pose_service.dart';
import 'package:test/test.dart';

void main() {
  group('guidanceForPose', () {
    test('confirms a level camera when the target is met', () {
      final guidance = guidanceForPose(
        const DevicePoseReading(rollDegrees: 0, flatnessDegrees: 90),
        targetRollDegrees: 0,
        rollToleranceDegrees: 3,
        targetFlatnessDegrees: 90,
      );

      expect(guidance.isAligned, isTrue);
      expect(guidance.message, '수평이 맞았어요.');
    });

    test('asks for a directional correction before flatness coaching', () {
      final guidance = guidanceForPose(
        const DevicePoseReading(rollDegrees: 8, flatnessDegrees: 35),
        targetRollDegrees: 0,
        rollToleranceDegrees: 3,
        targetFlatnessDegrees: 90,
      );

      expect(guidance.isAligned, isFalse);
      expect(guidance.message, contains('오른쪽'));
    });

    test('asks for a flatter phone for a top-down composition', () {
      final guidance = guidanceForPose(
        const DevicePoseReading(rollDegrees: 0, flatnessDegrees: 42),
        targetRollDegrees: 0,
        rollToleranceDegrees: 3,
        targetFlatnessDegrees: 90,
      );

      expect(guidance.isAligned, isFalse);
      expect(guidance.message, contains('평행'));
    });
  });
}
