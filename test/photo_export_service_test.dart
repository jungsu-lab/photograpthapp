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

  test(
    'propagates a gallery failure and leaves cleanup to the caller',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'framefit-export-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final service = PhotoExportService(
        temporaryDirectory: () async => directory,
        saveToGallery: (_) async => throw StateError('gallery unavailable'),
      );
      final photo = await service.createImage(
        Uint8List.fromList(<int>[1, 2, 3]),
        sourceName: 'safe.jpg',
        format: PhotoOutputFormat.jpeg,
      );

      await expectLater(
        service.saveToGallery(photo),
        throwsA(isA<StateError>()),
      );
      expect(await File(photo.path).exists(), isTrue);

      await service.deleteTemporary(photo);
      expect(await File(photo.path).exists(), isFalse);
    },
  );

  test('propagates a share failure and leaves cleanup to the caller', () async {
    final directory = await Directory.systemTemp.createTemp('framefit-export-');
    addTearDown(() => directory.delete(recursive: true));
    final service = PhotoExportService(
      temporaryDirectory: () async => directory,
      sharePhoto: (_) async => throw StateError('share unavailable'),
    );
    final photo = await service.createImage(
      Uint8List.fromList(<int>[4, 5, 6]),
      sourceName: 'safe.jpg',
      format: PhotoOutputFormat.jpeg,
    );

    await expectLater(service.share(photo), throwsA(isA<StateError>()));
    expect(await File(photo.path).exists(), isTrue);

    await service.deleteTemporary(photo);
    expect(await File(photo.path).exists(), isFalse);
  });
}
