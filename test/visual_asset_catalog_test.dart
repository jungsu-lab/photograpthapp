import 'dart:io';

import 'package:framefit/data/composition/composition_catalog.dart';
import 'package:framefit/data/presets/preset_catalog.dart';
import 'package:image/image.dart' as img;
import 'package:test/test.dart';

void main() {
  test('composition examples are complete, unique, and decodable', () {
    final assets = compositionCatalog.map((template) => template.exampleAsset);

    expect(assets.length, 20);
    expect(assets.toSet().length, 20);
    for (final asset in assets) {
      expect(asset, startsWith('assets/images/composition/'));
      final bytes = File(asset).readAsBytesSync();
      final decoded = img.decodeImage(bytes);
      expect(decoded, isNotNull, reason: '$asset must decode');
      expect(decoded!.width, greaterThanOrEqualTo(360));
      expect(decoded.height, greaterThanOrEqualTo(450));
    }
  });

  test('every preset card points to a unique rendered thumbnail', () {
    final assets = presetCatalog.map((preset) => preset.thumbnailAsset);

    expect(assets.length, 23);
    expect(assets.toSet().length, 23);
    for (final asset in assets) {
      expect(asset, startsWith('assets/images/preset-previews/'));
      final decoded = img.decodeImage(File(asset).readAsBytesSync());
      expect(decoded, isNotNull, reason: '$asset must decode');
    }
  });
}
