import 'dart:io';

import 'package:image/image.dart' as img;

/// Converts generated composition source PNGs into compact JPEG card assets.
/// The cards are displayed at a small size, so 720px on the long edge keeps
/// their composition legible while avoiding a disproportionate APK increase.
Future<void> main() async {
  final input = Directory('assets/images/composition');
  if (!await input.exists()) {
    throw StateError('Composition asset directory is missing.');
  }

  for (final entity in input.listSync().whereType<File>()) {
    if (entity.path.toLowerCase().endsWith('.png') == false) continue;
    final decoded = img.decodeImage(await entity.readAsBytes());
    if (decoded == null) {
      throw StateError('Could not decode ${entity.path}');
    }
    final resized = decoded.width >= decoded.height
        ? img.copyResize(decoded, width: 720)
        : img.copyResize(decoded, height: 720);
    final output = File(
      entity.path.replaceFirst(RegExp(r'\.png$', caseSensitive: false), '.jpg'),
    );
    await output.writeAsBytes(img.encodeJpg(resized, quality: 86), flush: true);
    await entity.delete();
    stdout.writeln('${entity.path} -> ${output.path}');
  }

  await _compactSource(
    'tool_assets/imagegen/framefit-woman-reference.png',
    'tool_assets/imagegen/framefit-woman-reference.jpg',
  );
  await _compactSource(
    'tool_assets/preset-sources/social.png',
    'tool_assets/preset-sources/social.jpg',
  );
}

Future<void> _compactSource(String sourcePath, String outputPath) async {
  final source = File(sourcePath);
  if (!await source.exists()) return;
  final decoded = img.decodeImage(await source.readAsBytes());
  if (decoded == null) throw StateError('Could not decode $sourcePath');
  final resized = decoded.width >= decoded.height
      ? img.copyResize(decoded, width: 900)
      : img.copyResize(decoded, height: 900);
  final output = File(outputPath);
  await output.writeAsBytes(img.encodeJpg(resized, quality: 90), flush: true);
  await source.delete();
  stdout.writeln('$sourcePath -> $outputPath');
}
