import 'dart:math' as math;

enum PresetCategory {
  correction,
  japanTravel,
  animeMood,
  cameraEffect,
  monochrome,
}

extension PresetCategoryLabel on PresetCategory {
  String get label => switch (this) {
    PresetCategory.correction => '기본 보정',
    PresetCategory.japanTravel => '일본 여행',
    PresetCategory.animeMood => '애니 무드',
    PresetCategory.cameraEffect => '촬영 효과',
    PresetCategory.monochrome => '흑백',
  };
}

/// Every adjustment is stored as a reproducible number rather than display copy.
class PresetRecipe {
  const PresetRecipe({
    this.exposureEv = 0,
    this.contrast = 0,
    this.highlights = 0,
    this.shadows = 0,
    this.whites = 0,
    this.blacks = 0,
    this.saturation = 0,
    this.vibrance = 0,
    this.temperature = 0,
    this.tint = 0,
    this.fade = 0,
    this.vignette = 0,
    this.grain = 0,
    this.sharpness = 0,
  });

  final double exposureEv;
  final double contrast;
  final double highlights;
  final double shadows;
  final double whites;
  final double blacks;
  final double saturation;
  final double vibrance;
  final double temperature;
  final double tint;
  final double fade;
  final double vignette;
  final double grain;
  final double sharpness;

  PresetRecipe scaled(double intensity) {
    final factor = intensity.clamp(0.0, 1.0).toDouble();
    return PresetRecipe(
      exposureEv: exposureEv * factor,
      contrast: contrast * factor,
      highlights: highlights * factor,
      shadows: shadows * factor,
      whites: whites * factor,
      blacks: blacks * factor,
      saturation: saturation * factor,
      vibrance: vibrance * factor,
      temperature: temperature * factor,
      tint: tint * factor,
      fade: fade * factor,
      vignette: vignette * factor,
      grain: grain * factor,
      sharpness: sharpness * factor,
    );
  }

  PresetRecipe merge(PresetRecipe other) => PresetRecipe(
    exposureEv: _clampExposure(exposureEv + other.exposureEv),
    contrast: _clampUnit(contrast + other.contrast),
    highlights: _clampUnit(highlights + other.highlights),
    shadows: _clampUnit(shadows + other.shadows),
    whites: _clampUnit(whites + other.whites),
    blacks: _clampUnit(blacks + other.blacks),
    saturation: _clampUnit(saturation + other.saturation),
    vibrance: _clampUnit(vibrance + other.vibrance),
    temperature: _clampUnit(temperature + other.temperature),
    tint: _clampUnit(tint + other.tint),
    fade: _clampPositive(fade + other.fade),
    vignette: _clampPositive(vignette + other.vignette),
    grain: _clampPositive(grain + other.grain),
    sharpness: _clampPositive(sharpness + other.sharpness),
  );

  PresetRecipe copyWith({
    double? exposureEv,
    double? contrast,
    double? highlights,
    double? shadows,
    double? whites,
    double? blacks,
    double? saturation,
    double? vibrance,
    double? temperature,
    double? tint,
    double? fade,
    double? vignette,
    double? grain,
    double? sharpness,
  }) => PresetRecipe(
    exposureEv: exposureEv ?? this.exposureEv,
    contrast: contrast ?? this.contrast,
    highlights: highlights ?? this.highlights,
    shadows: shadows ?? this.shadows,
    whites: whites ?? this.whites,
    blacks: blacks ?? this.blacks,
    saturation: saturation ?? this.saturation,
    vibrance: vibrance ?? this.vibrance,
    temperature: temperature ?? this.temperature,
    tint: tint ?? this.tint,
    fade: fade ?? this.fade,
    vignette: vignette ?? this.vignette,
    grain: grain ?? this.grain,
    sharpness: sharpness ?? this.sharpness,
  );

  Map<String, double> toJson() => {
    'exposureEv': exposureEv,
    'contrast': contrast,
    'highlights': highlights,
    'shadows': shadows,
    'whites': whites,
    'blacks': blacks,
    'saturation': saturation,
    'vibrance': vibrance,
    'temperature': temperature,
    'tint': tint,
    'fade': fade,
    'vignette': vignette,
    'grain': grain,
    'sharpness': sharpness,
  };

  factory PresetRecipe.fromJson(Map<String, dynamic> json) => PresetRecipe(
    exposureEv: _number(json['exposureEv']).clamp(-2, 2).toDouble(),
    contrast: _number(json['contrast']).clamp(-1, 1).toDouble(),
    highlights: _number(json['highlights']).clamp(-1, 1).toDouble(),
    shadows: _number(json['shadows']).clamp(-1, 1).toDouble(),
    whites: _number(json['whites']).clamp(-1, 1).toDouble(),
    blacks: _number(json['blacks']).clamp(-1, 1).toDouble(),
    saturation: _number(json['saturation']).clamp(-1, 1).toDouble(),
    vibrance: _number(json['vibrance']).clamp(-1, 1).toDouble(),
    temperature: _number(json['temperature']).clamp(-1, 1).toDouble(),
    tint: _number(json['tint']).clamp(-1, 1).toDouble(),
    fade: _number(json['fade']).clamp(0, 1).toDouble(),
    vignette: _number(json['vignette']).clamp(0, 1).toDouble(),
    grain: _number(json['grain']).clamp(0, 1).toDouble(),
    sharpness: _number(json['sharpness']).clamp(0, 1).toDouble(),
  );

  bool get isIdentity => this == const PresetRecipe();

  static double _clampExposure(double value) =>
      value.clamp(-2.0, 2.0).toDouble();
  static double _clampUnit(double value) => value.clamp(-1.0, 1.0).toDouble();
  static double _clampPositive(double value) =>
      value.clamp(0.0, 1.0).toDouble();

  @override
  bool operator ==(Object other) =>
      other is PresetRecipe &&
      exposureEv == other.exposureEv &&
      contrast == other.contrast &&
      highlights == other.highlights &&
      shadows == other.shadows &&
      whites == other.whites &&
      blacks == other.blacks &&
      saturation == other.saturation &&
      vibrance == other.vibrance &&
      temperature == other.temperature &&
      tint == other.tint &&
      fade == other.fade &&
      vignette == other.vignette &&
      grain == other.grain &&
      sharpness == other.sharpness;

  @override
  int get hashCode => Object.hashAll([
    exposureEv,
    contrast,
    highlights,
    shadows,
    whites,
    blacks,
    saturation,
    vibrance,
    temperature,
    tint,
    fade,
    vignette,
    grain,
    sharpness,
  ]);
}

class PhotoPreset {
  const PhotoPreset({
    required this.id,
    required this.thumbnailAsset,
    required this.name,
    required this.description,
    required this.category,
    required this.recipe,
    required this.swatch,
    this.defaultIntensity = 1,
    this.version = 1,
    this.recommendedSubjects = const [],
  });

  final String id;

  /// A pre-rendered sample made with [PhotoProcessor] and this preset's
  /// default intensity. The library never simulates a filter with a colour
  /// overlay, so this remains an honest preview of the real edit result.
  final String thumbnailAsset;
  final String name;
  final String description;
  final PresetCategory category;
  final PresetRecipe recipe;
  final int swatch;
  final double defaultIntensity;
  final int version;
  final List<String> recommendedSubjects;

  Map<String, dynamic> toJson() => {
    'id': id,
    'thumbnailAsset': thumbnailAsset,
    'name': name,
    'description': description,
    'category': category.name,
    'recipe': recipe.toJson(),
    'swatch': swatch,
    'defaultIntensity': defaultIntensity,
    'version': version,
    'recommendedSubjects': recommendedSubjects,
  };

  factory PhotoPreset.fromJson(Map<String, dynamic> json) {
    final categoryName = json['category'] as String?;
    final category = PresetCategory.values.firstWhere(
      (value) => value.name == categoryName,
      orElse: () => PresetCategory.cameraEffect,
    );
    final recipeJson = json['recipe'];
    if (recipeJson is! Map) {
      throw const FormatException('Preset recipe is required.');
    }
    return PhotoPreset(
      id: json['id'] as String? ?? '',
      thumbnailAsset: json['thumbnailAsset'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: category,
      recipe: PresetRecipe.fromJson(Map<String, dynamic>.from(recipeJson)),
      swatch: (json['swatch'] as num?)?.toInt() ?? 0xFF777777,
      defaultIntensity: json['defaultIntensity'] == null
          ? 1
          : _number(json['defaultIntensity']).clamp(0, 1).toDouble(),
      version: (json['version'] as num?)?.toInt() ?? 1,
      recommendedSubjects: (json['recommendedSubjects'] as List? ?? const [])
          .whereType<String>()
          .toList(growable: false),
    );
  }
}

class EditSettings {
  const EditSettings({
    this.preset,
    this.intensity = 1,
    this.manual = const PresetRecipe(),
    this.cropAspectRatio,
  });

  final PhotoPreset? preset;
  final double intensity;
  final PresetRecipe manual;

  /// Null keeps the full image. A value crops around the centre to width/height.
  final double? cropAspectRatio;

  PresetRecipe get effectiveRecipe =>
      (preset?.recipe ?? const PresetRecipe()).scaled(intensity).merge(manual);

  EditSettings copyWith({
    PhotoPreset? preset,
    bool clearPreset = false,
    double? intensity,
    PresetRecipe? manual,
    double? cropAspectRatio,
    bool clearCrop = false,
  }) => EditSettings(
    preset: clearPreset ? null : (preset ?? this.preset),
    intensity: intensity ?? this.intensity,
    manual: manual ?? this.manual,
    cropAspectRatio: clearCrop
        ? null
        : (cropAspectRatio ?? this.cropAspectRatio),
  );
}

double clamp01(double value) => math.max(0, math.min(1, value));

double _number(Object? value) => value is num ? value.toDouble() : 0;
