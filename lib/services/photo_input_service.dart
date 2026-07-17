import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../domain/models/selected_photo.dart';

class PhotoInputService {
  PhotoInputService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<SelectedPhoto?> pickFromGallery() =>
      _pick(ImageSource.gallery, PhotoSource.gallery);

  Future<SelectedPhoto?> takePhoto() =>
      _pick(ImageSource.camera, PhotoSource.camera);

  /// Android can reclaim the activity while a system picker is open. Restoring
  /// the lost selection keeps the user from silently losing the photo they
  /// already chose. Non-Android implementations simply report no recovery.
  Future<SelectedPhoto?> retrieveLostPhoto() async {
    LostDataResponse response;
    try {
      response = await _picker.retrieveLostData();
    } on UnimplementedError {
      return null;
    }
    if (response.isEmpty) return null;
    if (response.exception != null) {
      throw PhotoInputException('이전에 선택한 사진을 복원하지 못했어요. 다시 선택해 주세요.');
    }
    final file = response.file;
    if (file == null) return null;
    return _selectedPhotoFromFile(file, PhotoSource.gallery);
  }

  Future<SelectedPhoto?> _pick(
    ImageSource source,
    PhotoSource photoSource,
  ) async {
    final file = await _picker.pickImage(
      source: source,
      // Android 9+ only exposes HEIC through image_picker when a size
      // operation is requested. This upper bound matches FrameFit's safe
      // decode limit, so supported JPEG/PNG inputs below it keep their size.
      maxWidth: PhotoInputValidator.maximumDimension.toDouble(),
      maxHeight: PhotoInputValidator.maximumDimension.toDouble(),
      imageQuality: 100,
      requestFullMetadata: false,
    );
    if (file == null) return null;
    return _selectedPhotoFromFile(file, photoSource);
  }

  Future<SelectedPhoto> _selectedPhotoFromFile(
    XFile file,
    PhotoSource photoSource,
  ) async {
    final bytes = await file.readAsBytes();
    final format = PhotoInputValidator.validate(
      fileName: file.name,
      bytes: bytes,
    );
    return SelectedPhoto(
      name: PhotoInputValidator.normalizedName(file.name, format),
      bytes: bytes,
      source: photoSource,
    );
  }
}

enum PhotoInputFormat { jpeg, png }

/// Validates both the selected file name and its actual signature. The byte
/// signature is authoritative, while the extension check avoids exporting a
/// transparent PNG as an unexpected JPEG later in the edit flow.
class PhotoInputValidator {
  static const maximumInputBytes = 40 * 1024 * 1024;
  static const maximumDimension = 10000;
  static const maximumPixels = 40 * 1000 * 1000;

  static PhotoInputFormat validate({
    required String fileName,
    required List<int> bytes,
  }) {
    if (bytes.isEmpty) {
      throw const PhotoInputException('선택한 사진을 읽을 수 없어요. 다른 사진을 선택해 주세요.');
    }
    if (bytes.length > maximumInputBytes) {
      throw const PhotoInputException(
        '사진 파일이 너무 커서 열 수 없어요. 40MB 이하의 JPEG 또는 PNG를 선택해 주세요.',
      );
    }
    final format = _formatFromBytes(bytes);
    if (format == null) {
      throw const PhotoInputException(
        '지원하지 않는 사진 형식이에요. JPEG 또는 PNG 파일을 선택해 주세요.',
      );
    }
    final extension = _extensionOf(fileName);
    if (extension != null && !_extensionMatches(format, extension)) {
      throw const PhotoInputException(
        '파일 이름과 실제 사진 형식이 일치하지 않아요. JPEG 또는 PNG 원본을 다시 선택해 주세요.',
      );
    }
    _validateDimensions(bytes, format);
    return format;
  }

  /// Reads only image headers before handing the file to the pixel renderer.
  /// This keeps a small, highly-compressed image from expanding into an
  /// unreasonable bitmap allocation later in the editing flow.
  static void _validateDimensions(List<int> bytes, PhotoInputFormat format) {
    final data = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
    final decoder = switch (format) {
      PhotoInputFormat.jpeg => img.JpegDecoder(),
      PhotoInputFormat.png => img.PngDecoder(),
    };
    final info = decoder.startDecode(data);
    if (info == null || info.width < 1 || info.height < 1) {
      throw const PhotoInputException(
        '사진 크기를 읽을 수 없어요. 다른 JPEG 또는 PNG를 선택해 주세요.',
      );
    }
    final pixels = info.width * info.height;
    if (info.width > maximumDimension ||
        info.height > maximumDimension ||
        pixels > maximumPixels) {
      throw const PhotoInputException(
        '사진 해상도가 너무 커서 열 수 없어요. 긴 변 10000px·4000만 화소 이하의 JPEG 또는 PNG를 선택해 주세요.',
      );
    }
  }

  static String normalizedName(String fileName, PhotoInputFormat format) {
    if (fileName.trim().isEmpty) {
      return 'framefit-photo.${_extensionFor(format)}';
    }
    final extension = _extensionOf(fileName);
    if (extension == null) return '$fileName.${_extensionFor(format)}';
    if (_isCanonicalExtension(format, extension)) return fileName;
    return fileName.replaceFirst(RegExp(r'\.[^.]+$'), '.${_extensionFor(format)}');
  }

  static PhotoInputFormat? _formatFromBytes(List<int> bytes) {
    final isJpeg =
        bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF;
    if (isJpeg) {
      return PhotoInputFormat.jpeg;
    }
    final isPng =
        bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A;
    return isPng ? PhotoInputFormat.png : null;
  }

  static String? _extensionOf(String fileName) {
    final match = RegExp(r'\.([^.]+)$').firstMatch(fileName.trim());
    return match?.group(1)?.toLowerCase();
  }

  static bool _extensionMatches(PhotoInputFormat format, String extension) =>
      switch (format) {
        // Android's system picker can transcode HEIC to JPEG while retaining
        // the source filename. The decoded bytes remain authoritative and the
        // name is normalised to .jpg before the edit session begins.
        PhotoInputFormat.jpeg =>
          extension == 'jpg' ||
              extension == 'jpeg' ||
              extension == 'heic' ||
              extension == 'heif',
        PhotoInputFormat.png => extension == 'png',
      };

  static bool _isCanonicalExtension(
    PhotoInputFormat format,
    String extension,
  ) => switch (format) {
    PhotoInputFormat.jpeg => extension == 'jpg' || extension == 'jpeg',
    PhotoInputFormat.png => extension == 'png',
  };

  static String _extensionFor(PhotoInputFormat format) =>
      format == PhotoInputFormat.png ? 'png' : 'jpg';
}

class PhotoInputException implements Exception {
  const PhotoInputException(this.message);
  final String message;

  @override
  String toString() => message;
}
