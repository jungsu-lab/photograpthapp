import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:image/image.dart' as img;

import 'package:framefit/domain/models/photo_preset.dart';
import 'package:framefit/services/photo_processor.dart';

void main() {
  final processor = const PhotoProcessor();

  Uint8List sourceImage() {
    final image = img.Image(width: 4, height: 3);
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        image.setPixelRgba(x, y, 60 + x * 30, 70 + y * 25, 90, 255);
      }
    }
    return Uint8List.fromList(img.encodeJpg(image, quality: 100));
  }

  test(
    'processor applies an exposure recipe to a real decoded image',
    () async {
      final input = sourceImage();
      final original = img.decodeJpg(input)!;
      final result = await processor.render(
        PhotoProcessRequest(
          sourceBytes: input,
          recipe: const PresetRecipe(exposureEv: .7),
          maxDimension: 4,
        ),
      );
      final edited = img.decodeJpg(result)!;

      expect(edited.width, original.width);
      expect(edited.height, original.height);
      expect(edited.getPixel(1, 1).r, greaterThan(original.getPixel(1, 1).r));
    },
  );

  test('grain stays deterministic for identical inputs and settings', () async {
    final request = PhotoProcessRequest(
      sourceBytes: sourceImage(),
      recipe: const PresetRecipe(grain: .6),
      maxDimension: 4,
    );

    final first = await processor.render(request);
    final second = await processor.render(request);

    expect(first, orderedEquals(second));
  });

  test(
    'an untouched full-resolution JPEG strips ancillary metadata bytes',
    () async {
      final original = sourceImage();
      final note = Uint8List.fromList([
        0xFF,
        0xFE,
        0x00,
        0x0E,
        ...'private-note'.codeUnits,
      ]);
      final input = Uint8List.fromList([
        ...original.sublist(0, 2),
        ...note,
        ...original.sublist(2),
      ]);
      final result = await processor.render(
        PhotoProcessRequest(
          sourceBytes: input,
          recipe: const PresetRecipe(),
          maxDimension: null,
        ),
      );

      expect(result, orderedEquals(original));
      expect(img.decodeJpg(result), isNotNull);
    },
  );

  test('PNG export keeps transparency and applies a centred crop', () async {
    final transparent = img.Image(width: 8, height: 4, numChannels: 4);
    transparent.clear(img.ColorRgba8(10, 20, 30, 0));
    transparent.setPixelRgba(4, 2, 220, 40, 60, 180);

    final result = await processor.render(
      PhotoProcessRequest(
        sourceBytes: Uint8List.fromList(img.encodePng(transparent)),
        recipe: const PresetRecipe(),
        maxDimension: null,
        outputFormat: PhotoOutputFormat.png,
        cropAspectRatio: 1,
      ),
    );
    final decoded = img.decodePng(result)!;

    expect(decoded.width, 4);
    expect(decoded.height, 4);
    expect(decoded.getPixel(2, 2).a.round(), 180);
  });

  test(
    'a JPEG with EXIF rotation is baked into the processed pixels',
    () async {
      final portrait = img.Image(width: 2, height: 3);
      portrait.setPixelRgba(0, 0, 255, 0, 0, 255);
      portrait.setPixelRgba(1, 2, 0, 0, 255, 255);
      portrait.exif.imageIfd.orientation = 6;
      final input = Uint8List.fromList(img.encodeJpg(portrait, quality: 100));

      final result = await processor.render(
        PhotoProcessRequest(
          sourceBytes: input,
          recipe: const PresetRecipe(exposureEv: .01),
          maxDimension: null,
        ),
      );
      final decoded = img.decodeJpg(result)!;

      expect(decoded.width, 3);
      expect(decoded.height, 2);
      expect(decoded.exif.imageIfd.orientation, isNull);
    },
  );

  test('processor reports unsupported input clearly', () async {
    await expectLater(
      processor.render(
        PhotoProcessRequest(
          sourceBytes: Uint8List.fromList([1, 2, 3]),
          recipe: const PresetRecipe(),
          maxDimension: 4,
        ),
      ),
      throwsA(isA<PhotoProcessingException>()),
    );
  });
}
