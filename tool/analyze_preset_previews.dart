import 'dart:io';
import 'dart:math' as math;

import 'package:framefit/data/presets/preset_catalog.dart';
import 'package:framefit/domain/models/photo_preset.dart';
import 'package:image/image.dart' as img;

void main() {
  final portraitSource = _decode(
    'assets/images/composition/foreground-depth.jpg',
  );
  final sourceStats = _stats(portraitSource);
  stdout.writeln(
    'source luma=${sourceStats.meanLuma.toStringAsFixed(3)} '
    'highlight=${(sourceStats.highlightRatio * 100).toStringAsFixed(2)}% '
    'shadow=${(sourceStats.shadowRatio * 100).toStringAsFixed(2)}% '
    'saturation=${sourceStats.meanSaturation.toStringAsFixed(3)}',
  );

  final sources = <PresetCategory, img.Image>{
    PresetCategory.correction: portraitSource,
    PresetCategory.portraitTone: portraitSource,
    PresetCategory.japanTravel: _decode(
      'tool_assets/preset-sources/travel.webp',
    ),
    PresetCategory.animeMood: _decode('tool_assets/preset-sources/travel.webp'),
    PresetCategory.filmTone: _decode('tool_assets/preset-sources/social.jpg'),
    PresetCategory.cameraEffect: _decode(
      'tool_assets/preset-sources/social.jpg',
    ),
    PresetCategory.monochrome: portraitSource,
  };
  final sourceOverrides = <String, img.Image>{
    'backlight-recovery': _decode(
      'assets/images/composition/backlit-silhouette.jpg',
    ),
    'convenience-flash': _decode(
      'assets/images/composition/flash-portrait.jpg',
    ),
  };
  for (final preset in presetCatalog) {
    final file = File(preset.thumbnailAsset);
    final preview = _decode(file.path);
    final source = sourceOverrides[preset.id] ?? sources[preset.category]!;
    final baseline = img.copyResize(
      source,
      width: preview.width,
      height: preview.height,
    );
    var absoluteDifference = 0.0;
    for (var y = 0; y < preview.height; y++) {
      for (var x = 0; x < preview.width; x++) {
        final actual = preview.getPixel(x, y);
        final original = baseline.getPixel(x, y);
        absoluteDifference += (actual.r - original.r).abs();
        absoluteDifference += (actual.g - original.g).abs();
        absoluteDifference += (actual.b - original.b).abs();
      }
    }
    final channelCount = preview.width * preview.height * 3;
    stdout.writeln(
      '${preset.id.padRight(28)} mean-pixel-delta='
      '${(absoluteDifference / channelCount).toStringAsFixed(2)}',
    );
  }
}

img.Image _decode(String path) {
  final decoded = img.decodeImage(File(path).readAsBytesSync());
  if (decoded == null) throw StateError('Could not decode $path');
  return decoded;
}

({
  double meanLuma,
  double meanSaturation,
  double highlightRatio,
  double shadowRatio,
})
_stats(img.Image image) {
  var lumaTotal = 0.0;
  var saturationTotal = 0.0;
  var highlights = 0;
  var shadows = 0;
  for (final pixel in image) {
    final r = pixel.r / 255;
    final g = pixel.g / 255;
    final b = pixel.b / 255;
    final luma = r * .2126 + g * .7152 + b * .0722;
    final high = math.max(r, math.max(g, b));
    final low = math.min(r, math.min(g, b));
    lumaTotal += luma;
    saturationTotal += high == 0 ? 0 : (high - low) / high;
    if (luma > .95) highlights++;
    if (luma < .05) shadows++;
  }
  final count = image.width * image.height;
  return (
    meanLuma: lumaTotal / count,
    meanSaturation: saturationTotal / count,
    highlightRatio: highlights / count,
    shadowRatio: shadows / count,
  );
}
