import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

class CommunityPhotoService {
  const CommunityPhotoService();

  static const maximumDimension = 2048;
  static const jpegQuality = 86;

  Future<Uint8List> prepareForUpload(List<int> sourceBytes) =>
      Isolate.run(() => _prepare(Uint8List.fromList(sourceBytes)));
}

Uint8List _prepare(Uint8List bytes) {
  img.Image? image;
  try {
    image = img.decodeImage(bytes);
  } catch (_) {
    throw const CommunityPhotoException('게시할 사진을 읽을 수 없어요.');
  }
  if (image == null) {
    throw const CommunityPhotoException('게시할 사진을 읽을 수 없어요.');
  }
  image = img.bakeOrientation(image);
  if (image.width > CommunityPhotoService.maximumDimension ||
      image.height > CommunityPhotoService.maximumDimension) {
    image = image.width >= image.height
        ? img.copyResize(image, width: CommunityPhotoService.maximumDimension)
        : img.copyResize(image, height: CommunityPhotoService.maximumDimension);
  }
  // Re-encoding only pixels deliberately drops EXIF, GPS, XMP, IPTC, and the
  // original file name before a community upload leaves the device.
  return Uint8List.fromList(
    img.encodeJpg(image, quality: CommunityPhotoService.jpegQuality),
  );
}

class CommunityPhotoException implements Exception {
  const CommunityPhotoException(this.message);

  final String message;

  @override
  String toString() => message;
}
