import 'package:test/test.dart';
import 'package:framefit/data/composition/composition_catalog.dart';
import 'package:framefit/data/presets/preset_catalog.dart';
import 'package:framefit/domain/models/composition_template.dart';

void main() {
  test(
    'composition catalog has unique valid templates and preset references',
    () {
      final ids = compositionCatalog.map((template) => template.id).toSet();
      final presetIds = presetCatalog.map((preset) => preset.id).toSet();

      expect(compositionCatalog, hasLength(20));
      expect(ids, hasLength(compositionCatalog.length));

      for (final template in compositionCatalog) {
        expect(template.name, isNotEmpty);
        expect(template.coachingCopy, isNotEmpty);
        expect(template.captureChecklist, isNotEmpty);
        expect(template.linkedPresetIds, isNotEmpty);
        for (final presetId in template.linkedPresetIds) {
          expect(presetIds, contains(presetId));
        }
      }
    },
  );

  test('normalized overlay points round trip inside their allowed range', () {
    const point = NormalizedPoint(.25, .75);
    final restored = NormalizedPoint.fromJson(point.toJson());

    expect(restored.x, .25);
    expect(restored.y, .75);
  });

  test('shot packs point to an existing template and preset', () {
    final templateIds = compositionCatalog.map((item) => item.id).toSet();
    final presetIds = presetCatalog.map((item) => item.id).toSet();

    for (final pack in shotPacks) {
      expect(templateIds, contains(pack.templateId));
      expect(presetIds, contains(pack.defaultPresetId));
      expect(pack.defaultPresetIntensity, inInclusiveRange(0, 1));
    }
  });
}
