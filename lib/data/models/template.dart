class EditTemplate {
  const EditTemplate({
    required this.name,
    required this.description,
    required this.category,
    required this.rating,
    required this.usageCount,
    required int beginnerScore,
    required this.tags,
    required this.recommendationReason,
    this.thumbnailTone,
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

  String get id => name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9가-힣]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');

  final String name;
  final String description;
  final String category;
  final double rating;
  final int usageCount;
  final int beginnerFriendlyScore;
  final List<String> tags;
  final String recommendationReason;
  final String? thumbnailTone;
  final EditRecipe editRecipe;

  int get beginnerScore => beginnerFriendlyScore;
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
