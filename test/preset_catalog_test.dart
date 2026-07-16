import 'package:framefit/data/presets/preset_catalog.dart';
import 'package:framefit/domain/models/photo_preset.dart';
import 'package:test/test.dart';

void main() {
  test('preset library offers distinct, valid beginner and mood choices', () {
    final ids = presetCatalog.map((preset) => preset.id).toSet();
    final recipes = presetCatalog.map((preset) => preset.recipe).toSet();

    expect(presetCatalog.length, greaterThanOrEqualTo(15));
    expect(ids, hasLength(presetCatalog.length));
    expect(recipes, hasLength(presetCatalog.length));
    expect(
      presetCatalog.where(
        (preset) => preset.category == PresetCategory.correction,
      ),
      isNotEmpty,
    );
    expect(
      presetCatalog.where(
        (preset) => preset.category == PresetCategory.japanTravel,
      ),
      isNotEmpty,
    );
    expect(
      presetCatalog.where(
        (preset) => preset.category == PresetCategory.animeMood,
      ),
      hasLength(3),
    );

    for (final preset in presetCatalog) {
      expect(preset.name, isNotEmpty);
      expect(preset.description, isNotEmpty);
      expect(preset.defaultIntensity, inInclusiveRange(0, 1));
    }
  });
}
