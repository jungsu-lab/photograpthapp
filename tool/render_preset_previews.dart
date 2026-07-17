import 'dart:io';
import 'dart:typed_data';

import 'package:framefit/data/presets/preset_catalog.dart';
import 'package:framefit/domain/models/photo_preset.dart';
import 'package:framefit/services/photo_processor.dart';

/// Rebuilds every library thumbnail with the production pixel processor.
///
/// The source fixtures are app-owned, fictional images under tool_assets and
/// are intentionally excluded from the mobile bundle. This script keeps the
/// preset cards truthful: each file contains the selected recipe at its
/// catalogued default intensity, not a widget colour overlay.
Future<void> main() async {
  final root = Directory.current;
  final outputDirectory = Directory(
    '${root.path}${Platform.pathSeparator}assets${Platform.pathSeparator}images'
    '${Platform.pathSeparator}preset-previews',
  );
  await outputDirectory.create(recursive: true);

  final sources = <PresetCategory, String>{
    PresetCategory.correction: 'assets/images/composition/foreground-depth.jpg',
    PresetCategory.portraitTone:
        'assets/images/composition/foreground-depth.jpg',
    PresetCategory.japanTravel: 'tool_assets/preset-sources/travel.webp',
    PresetCategory.animeMood: 'tool_assets/preset-sources/travel.webp',
    PresetCategory.filmTone: 'tool_assets/preset-sources/social.jpg',
    PresetCategory.cameraEffect: 'tool_assets/preset-sources/social.jpg',
    PresetCategory.monochrome: 'assets/images/composition/foreground-depth.jpg',
  };
  const sourceOverrides = <String, String>{
    'backlight-recovery': 'assets/images/composition/backlit-silhouette.jpg',
    'convenience-flash': 'assets/images/composition/flash-portrait.jpg',
  };
  const processor = PhotoProcessor();

  for (final preset in presetCatalog) {
    final sourcePath = sourceOverrides[preset.id] ?? sources[preset.category]!;
    final source = File('${root.path}${Platform.pathSeparator}$sourcePath');
    if (!await source.exists()) {
      throw StateError('Missing preset preview source: $sourcePath');
    }
    final output = File(
      '${root.path}${Platform.pathSeparator}${preset.thumbnailAsset}',
    );
    await output.parent.create(recursive: true);
    final bytes = Uint8List.fromList(await source.readAsBytes());
    final rendered = await processor.render(
      PhotoProcessRequest(
        sourceBytes: bytes,
        recipe: preset.recipe.scaled(preset.defaultIntensity),
        maxDimension: 640,
        quality: 88,
      ),
    );
    await output.writeAsBytes(rendered, flush: true);
    stdout.writeln('Rendered ${preset.id} -> ${preset.thumbnailAsset}');
  }
}
