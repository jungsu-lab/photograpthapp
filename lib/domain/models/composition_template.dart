enum CompositionCategory { portrait, space, mood, foodProduct }

extension CompositionCategoryLabel on CompositionCategory {
  String get label => switch (this) {
    CompositionCategory.portrait => '인물·셀피',
    CompositionCategory.space => '공간·여행',
    CompositionCategory.mood => '감성·SNS',
    CompositionCategory.foodProduct => '음식·상품',
  };
}

enum CompositionOverlayType {
  thirds,
  centre,
  silhouette,
  anchors,
  leadingLines,
  frame,
  reflection,
  topDown,
}

enum CoachCapability { sensor, subjectPosition, visualGuide }

enum CameraFacingPreference { front, back, either }

enum LensPreference { ultraWide, wide, either }

enum FlashPreference { off, on, optional }

class NormalizedPoint {
  const NormalizedPoint(this.x, this.y)
    : assert(x >= 0 && x <= 1),
      assert(y >= 0 && y <= 1);

  final double x;
  final double y;

  Map<String, double> toJson() => {'x': x, 'y': y};

  factory NormalizedPoint.fromJson(Map<String, dynamic> json) =>
      NormalizedPoint(
        (json['x'] as num? ?? .5).toDouble().clamp(0, 1).toDouble(),
        (json['y'] as num? ?? .5).toDouble().clamp(0, 1).toDouble(),
      );
}

class NormalizedLine {
  const NormalizedLine(this.start, this.end);

  final NormalizedPoint start;
  final NormalizedPoint end;
}

class OverlaySpec {
  const OverlaySpec({
    required this.type,
    this.points = const [],
    this.lines = const [],
  });

  final CompositionOverlayType type;
  final List<NormalizedPoint> points;
  final List<NormalizedLine> lines;
}

class DevicePoseTarget {
  const DevicePoseTarget({
    this.targetRollDegrees = 0,
    this.rollToleranceDegrees = 3,
    this.targetPitchDegrees,
    this.pitchToleranceDegrees = 8,
  });

  final double targetRollDegrees;
  final double rollToleranceDegrees;
  final double? targetPitchDegrees;
  final double pitchToleranceDegrees;
}

class CompositionTemplate {
  const CompositionTemplate({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.category,
    required this.exampleAsset,
    required this.overlay,
    required this.coachingCopy,
    required this.captureChecklist,
    required this.linkedPresetIds,
    this.version = 1,
    this.cameraFacing = CameraFacingPreference.back,
    this.lensPreference = LensPreference.either,
    this.flashPreference = FlashPreference.optional,
    this.devicePoseTarget,
    this.capabilities = const {CoachCapability.visualGuide},
  });

  final String id;
  final String name;
  final String shortDescription;
  final CompositionCategory category;
  final String exampleAsset;
  final OverlaySpec overlay;
  final List<String> coachingCopy;
  final List<String> captureChecklist;
  final List<String> linkedPresetIds;
  final int version;
  final CameraFacingPreference cameraFacing;
  final LensPreference lensPreference;
  final FlashPreference flashPreference;
  final DevicePoseTarget? devicePoseTarget;
  final Set<CoachCapability> capabilities;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'shortDescription': shortDescription,
    'category': category.name,
    'exampleAsset': exampleAsset,
    'version': version,
    'cameraFacing': cameraFacing.name,
    'lensPreference': lensPreference.name,
    'flashPreference': flashPreference.name,
    'linkedPresetIds': linkedPresetIds,
  };
}

class ShotPack {
  const ShotPack({
    required this.id,
    required this.name,
    required this.templateId,
    required this.defaultPresetId,
    required this.description,
    this.defaultPresetIntensity = .7,
  }) : assert(defaultPresetIntensity >= 0 && defaultPresetIntensity <= 1);

  final String id;
  final String name;
  final String templateId;
  final String defaultPresetId;
  final String description;
  final double defaultPresetIntensity;
}
