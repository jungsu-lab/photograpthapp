import 'package:test/test.dart';

import 'package:framefit/services/photo_input_service.dart';

void main() {
  const jpeg = <int>[0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10];
  const png = <int>[0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];

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
}
