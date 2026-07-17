import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:framefit/services/community_photo_service.dart';

void main() {
  test('community upload removes metadata and limits its long edge', () async {
    final source = img.Image(width: 2400, height: 900);
    source.exif.imageIfd.orientation = 1;
    source.setPixelRgb(0, 0, 250, 40, 20);
    final bytes = Uint8List.fromList(img.encodeJpg(source, quality: 95));

    final prepared = await const CommunityPhotoService().prepareForUpload(
      bytes,
    );
    final decoded = img.decodeJpg(prepared)!;

    expect(decoded.width, CommunityPhotoService.maximumDimension);
    expect(decoded.height, lessThan(CommunityPhotoService.maximumDimension));
    expect(decoded.exif.imageIfd.orientation, isNull);
    expect(prepared.length, lessThan(bytes.length));
  });

  test('community upload rejects non-image bytes', () async {
    expect(
      () => const CommunityPhotoService().prepareForUpload([1, 2, 3]),
      throwsA(isA<CommunityPhotoException>()),
    );
  });
}
