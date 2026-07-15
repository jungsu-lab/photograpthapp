import 'dart:io';
import 'dart:typed_data';

import 'package:test/test.dart';

import 'package:framefit/services/photo_export_service.dart';
import 'package:framefit/services/photo_processor.dart';

void main() {
  test('creates a collision-safe temporary export and cleans it up', () async {
    final directory = await Directory.systemTemp.createTemp('framefit-export-');
    addTearDown(() => directory.delete(recursive: true));
    final service = PhotoExportService(
      temporaryDirectory: () async => directory,
    );

    final first = await service.createImage(
      Uint8List.fromList(<int>[1, 2, 3]),
      sourceName: 'my photo.png',
      format: PhotoOutputFormat.png,
    );
    final second = await service.createImage(
      Uint8List.fromList(<int>[4, 5, 6]),
      sourceName: 'my photo.png',
      format: PhotoOutputFormat.png,
    );

    expect(await File(first.path).readAsBytes(), orderedEquals(<int>[1, 2, 3]));
    expect(first.fileName, endsWith('.png'));
    expect(second.path, isNot(first.path));

    await service.deleteTemporary(first);
    await service.deleteTemporary(second);

    expect(await File(first.path).exists(), isFalse);
    expect(await File(second.path).exists(), isFalse);
  });
}
