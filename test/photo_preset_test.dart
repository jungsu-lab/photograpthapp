import 'package:test/test.dart';
import 'package:framefit/domain/models/photo_preset.dart';

void main() {
  test('preset JSON round trip preserves validated numeric recipe data', () {
    const preset = PhotoPreset(
      id: 'test',
      name: 'Test',
      description: 'Round trip',
      category: PresetCategory.cameraEffect,
      swatch: 0xFF112233,
      defaultIntensity: .8,
      version: 2,
      recommendedSubjects: ['landscape'],
      recipe: PresetRecipe(exposureEv: .4, whites: .2, blacks: -.1),
    );

    final restored = PhotoPreset.fromJson(preset.toJson());

    expect(restored.id, preset.id);
    expect(restored.recipe, preset.recipe);
    expect(restored.defaultIntensity, .8);
    expect(restored.recommendedSubjects, ['landscape']);
  });

  test('preset intensity is clamped and interpolated from the original', () {
    const recipe = PresetRecipe(exposureEv: 1, contrast: .8, grain: .5);

    final none = recipe.scaled(0);
    final half = recipe.scaled(.5);
    final full = recipe.scaled(2);

    expect(none, const PresetRecipe());
    expect(half.exposureEv, .5);
    expect(half.contrast, .4);
    expect(half.grain, .25);
    expect(full.exposureEv, 1);
    expect(full.contrast, .8);
  });

  test('recipe JSON clamps malformed out-of-range values safely', () {
    final recipe = PresetRecipe.fromJson({
      'exposureEv': 99,
      'contrast': -9,
      'whites': 5,
      'grain': -1,
    });

    expect(recipe.exposureEv, 2);
    expect(recipe.contrast, -1);
    expect(recipe.whites, 1);
    expect(recipe.grain, 0);
  });

  test('manual values merge into a preset without escaping allowed bounds', () {
    const preset = PresetRecipe(exposureEv: 1.8, contrast: .8, grain: .8);
    const manual = PresetRecipe(exposureEv: 1, contrast: .8, grain: .8);

    final result = preset.merge(manual);

    expect(result.exposureEv, 2);
    expect(result.contrast, 1);
    expect(result.grain, 1);
  });
}
