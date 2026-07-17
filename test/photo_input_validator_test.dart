import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:test/test.dart';

import 'package:framefit/services/photo_input_service.dart';

void main() {
  final jpeg = Uint8List.fromList(img.encodeJpg(img.Image(width: 4, height: 3)));
  final png = Uint8List.fromList(img.encodePng(img.Image(width: 4, height: 3)));

  test('accepts matching JPEG and PNG signatures', () {
    expect(
      PhotoInputValidator.validate(fileName: 'photo.jpeg', bytes: jpeg),
      PhotoInputFormat.jpeg,
    );
    expect(
      PhotoInputValidator.validate(fileName: 'photo.PNG', bytes: png),
      PhotoInputFormat.png,
    );
  });

  test('rejects unsupported, empty, oversized, and mismatched input', () {
    expect(
      () => PhotoInputValidator.validate(
        fileName: 'not-a-photo.txt',
        bytes: jpeg,
      ),
      throwsA(isA<PhotoInputException>()),
    );
    expect(
      () =>
          PhotoInputValidator.validate(fileName: 'empty.jpg', bytes: const []),
      throwsA(isA<PhotoInputException>()),
    );
    expect(
      () => PhotoInputValidator.validate(
        fileName: 'large.jpg',
        bytes: List<int>.filled(PhotoInputValidator.maximumInputBytes + 1, 0),
      ),
      throwsA(isA<PhotoInputException>()),
    );
    expect(
      () => PhotoInputValidator.validate(fileName: 'photo.jpg', bytes: png),
      throwsA(isA<PhotoInputException>()),
    );
  });

  test('adds a safe extension when the picker does not provide one', () {
    expect(
      PhotoInputValidator.normalizedName('picked-image', PhotoInputFormat.png),
      'picked-image.png',
    );
  });

  test('accepts a system-transcoded HEIC JPEG and normalizes its name', () {
    expect(
      PhotoInputValidator.validate(fileName: 'travel.heic', bytes: jpeg),
      PhotoInputFormat.jpeg,
    );
    expect(
      PhotoInputValidator.normalizedName('travel.heic', PhotoInputFormat.jpeg),
      'travel.jpg',
    );
  });

  test('rejects images whose decoded dimensions would use too much memory', () {
    final oversized = Uint8List.fromList(
      img.encodePng(img.Image(width: PhotoInputValidator.maximumDimension + 1, height: 1)),
    );

    expect(
      () => PhotoInputValidator.validate(fileName: 'wide.png', bytes: oversized),
      throwsA(isA<PhotoInputException>()),
    );
  });
}
