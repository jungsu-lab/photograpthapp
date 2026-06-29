class EditTemplate {
  const EditTemplate({
    this.idOverride,
    required this.name,
    required this.description,
    required this.category,
    required this.rating,
    required this.usageCount,
    required int beginnerScore,
    required this.tags,
    required this.recommendationReason,
    this.thumbnailTone,
    this.sampleVisual = const TemplateSampleVisual(
      label: 'template',
      baseColorHex: '#EFE3CA',
      accentColorHex: '#2B2B2B',
    ),
    this.aspectRatio = '4:5',
    this.targetSubjectType = 'person',
    this.compositionGuidance = '피사체를 화면 중앙보다 살짝 위에 두고 여백을 단정하게 정리해요.',
    this.captureTips = const ['밝은 곳에서 촬영하고 배경이 복잡하면 한 걸음 옆으로 이동해요.'],
    this.feedbackHints = const ['피사체 위치, 밝기, 배경 여백을 확인해 촬영 안내에 활용할 수 있어요.'],
    this.editRecipe = const EditRecipe(
      brightness: 'balanced',
      contrast: 'soft',
      saturation: 'natural',
      warmth: 'neutral',
      tone: 'natural',
      skin: 'clean',
      background: 'subtle blur',
      sharpness: 'medium',
      mood: 'calm',
    ),
  }) : beginnerFriendlyScore = beginnerScore;

  String get id =>
      idOverride ??
      name
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9가-힣]+'), '-')
          .replaceAll(RegExp(r'^-|-$'), '');

  String get title => name;

  final String? idOverride;
  final String name;
  final String description;
  final String category;
  final double rating;
  final int usageCount;
  final int beginnerFriendlyScore;
  final List<String> tags;
  final String recommendationReason;
  final String? thumbnailTone;
  final TemplateSampleVisual sampleVisual;
  final String aspectRatio;
  final String targetSubjectType;
  final String compositionGuidance;
  final List<String> captureTips;
  final List<String> feedbackHints;
  final EditRecipe editRecipe;

  int get beginnerScore => beginnerFriendlyScore;
}

class TemplateSampleVisual {
  const TemplateSampleVisual({
    required this.label,
    required this.baseColorHex,
    required this.accentColorHex,
    this.assetPath,
  });

  final String label;
  final String baseColorHex;
  final String accentColorHex;
  final String? assetPath;
}

class EditRecipe {
  const EditRecipe({
    required this.brightness,
    required this.contrast,
    required this.saturation,
    required this.warmth,
    required this.tone,
    required this.skin,
    required this.background,
    required this.sharpness,
    required this.mood,
  });

  final String brightness;
  final String contrast;
  final String saturation;
  final String warmth;
  final String tone;
  final String skin;
  final String background;
  final String sharpness;
  final String mood;
}
