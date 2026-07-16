import 'dart:math' as math;

import 'package:sensors_plus/sensors_plus.dart';

/// A small, privacy-safe slice of device orientation for composition coaching.
/// No sensor samples are persisted or sent off-device.
class DevicePoseReading {
  const DevicePoseReading({
    required this.rollDegrees,
    required this.flatnessDegrees,
  });

  final double rollDegrees;

  /// 0 means upright; 90 means the device is approximately parallel to a table.
  final double flatnessDegrees;
}

abstract interface class DevicePoseService {
  Stream<DevicePoseReading> get readings;
}

class PlatformDevicePoseService implements DevicePoseService {
  const PlatformDevicePoseService();

  @override
  Stream<DevicePoseReading> get readings =>
      accelerometerEventStream().map((event) {
        final horizontalMagnitude = math.sqrt(
          event.x * event.x + event.y * event.y,
        );
        return DevicePoseReading(
          rollDegrees: math.atan2(event.x, event.y) * 180 / math.pi,
          flatnessDegrees:
              math.atan2(event.z.abs(), horizontalMagnitude) * 180 / math.pi,
        );
      });
}

class DevicePoseGuidance {
  const DevicePoseGuidance({required this.message, required this.isAligned});

  final String message;
  final bool isAligned;
}

/// Converts a raw device pose into an honest, narrow coaching instruction.
/// It intentionally evaluates only device level/flatness; it does not claim to
/// detect people, objects, or the scene.
DevicePoseGuidance guidanceForPose(
  DevicePoseReading reading, {
  required double targetRollDegrees,
  required double rollToleranceDegrees,
  double? targetFlatnessDegrees,
  double flatnessToleranceDegrees = 8,
}) {
  final rollDelta = _shortestAngle(reading.rollDegrees - targetRollDegrees);
  if (rollDelta.abs() > rollToleranceDegrees) {
    return DevicePoseGuidance(
      message: rollDelta > 0 ? '휴대폰 오른쪽을 조금 올려보세요.' : '휴대폰 왼쪽을 조금 올려보세요.',
      isAligned: false,
    );
  }
  if (targetFlatnessDegrees != null) {
    final flatnessDelta = reading.flatnessDegrees - targetFlatnessDegrees;
    if (flatnessDelta.abs() > flatnessToleranceDegrees) {
      return DevicePoseGuidance(
        message: flatnessDelta < 0
            ? '휴대폰을 테이블과 더 평행하게 기울여보세요.'
            : '휴대폰을 테이블에서 조금 세워보세요.',
        isAligned: false,
      );
    }
  }
  return const DevicePoseGuidance(message: '수평이 맞았어요.', isAligned: true);
}

double _shortestAngle(double angle) {
  final normalized = (angle + 180) % 360;
  return normalized < 0 ? normalized + 180 : normalized - 180;
}
