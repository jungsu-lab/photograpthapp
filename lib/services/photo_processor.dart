import 'dart:math' as math;
import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../domain/models/photo_preset.dart';

class PhotoProcessRequest {
  const PhotoProcessRequest({
    required this.sourceBytes,
    required this.recipe,
    required this.maxDimension,
    this.quality = 92,
    this.outputFormat = PhotoOutputFormat.jpeg,
    this.cropAspectRatio,
  });

  final Uint8List sourceBytes;
  final PresetRecipe recipe;
  final int? maxDimension;
  final int quality;
  final PhotoOutputFormat outputFormat;
  final double? cropAspectRatio;
}

enum PhotoOutputFormat { jpeg, png }

/// CPU-only processor shared by preview and export so their colour result stays
/// consistent. The preview simply uses a smaller decoded image.
class PhotoProcessor {
  const PhotoProcessor();

  Future<Uint8List> render(PhotoProcessRequest request) =>
      Isolate.run(() => _renderPhoto(request));
}

Uint8List _renderPhoto(PhotoProcessRequest request) {
  img.Image? source;
  try {
    source = img.decodeImage(request.sourceBytes);
  } catch (_) {
    throw const PhotoProcessingException(
      '지원하지 않는 사진 형식이에요. JPEG 또는 PNG 파일을 선택해 주세요.',
    );
  }
  if (source == null) {
    throw const PhotoProcessingException(
      '지원하지 않는 사진 형식이에요. JPEG 또는 PNG 파일을 선택해 주세요.',
    );
  }

  // An untouched, normally oriented JPEG can keep its original compressed
  // pixels. Strip APP/COM metadata first so exporting never carries EXIF GPS,
  // XMP, IPTC, or comments into the new file. Rotated images must be decoded
  // and baked below so their displayed orientation is correct.
  final sourceOrientation = source.exif.imageIfd.orientation;
  if (request.recipe.isIdentity &&
      request.cropAspectRatio == null &&
      request.maxDimension == null &&
      request.outputFormat == PhotoOutputFormat.jpeg &&
      _matchesRequestedFormat(request.sourceBytes, request.outputFormat) &&
      (sourceOrientation == null || sourceOrientation == 1)) {
    return _stripJpegMetadata(request.sourceBytes);
  }

  source = img.bakeOrientation(source);
  if (request.cropAspectRatio case final aspect? when aspect > 0) {
    source = _centerCrop(source, aspect);
  }
  final maxDimension = request.maxDimension;
  if (maxDimension != null &&
      math.max(source.width, source.height) > maxDimension) {
    source = source.width >= source.height
        ? img.copyResize(source, width: maxDimension)
        : img.copyResize(source, height: maxDimension);
  }

  final original = source.clone();
  final recipe = request.recipe;
  final width = source.width;
  final height = source.height;
  final exposure = math.pow(2, recipe.exposureEv).toDouble();

  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final pixel = original.getPixel(x, y);
      var r = pixel.r / 255.0;
      var g = pixel.g / 255.0;
      var b = pixel.b / 255.0;

      r *= exposure;
      g *= exposure;
      b *= exposure;

      // Temperature shifts red/blue; tint shifts green against magenta.
      r += recipe.temperature * .12;
      b -= recipe.temperature * .12;
      g -= recipe.tint * .08;
      r += recipe.tint * .04;
      b += recipe.tint * .04;

      final luminance = _luminance(r, g, b);
      final shadowWeight = math.pow(1 - _clamp(luminance), 2).toDouble();
      final highlightWeight = math.pow(_clamp(luminance), 2).toDouble();
      final tonalLift =
          recipe.shadows * shadowWeight - recipe.highlights * highlightWeight;
      r += tonalLift;
      g += tonalLift;
      b += tonalLift;

      // White and black points affect only the outer tonal range, after
      // highlight/shadow recovery and before contrast.
      final whiteWeight = math.pow(_clamp(luminance), 4).toDouble();
      final blackWeight = math.pow(1 - _clamp(luminance), 4).toDouble();
      final pointLift =
          recipe.whites * whiteWeight - recipe.blacks * blackWeight;
      r += pointLift;
      g += pointLift;
      b += pointLift;

      r = ((r - .5) * (1 + recipe.contrast * .62)) + .5;
      g = ((g - .5) * (1 + recipe.contrast * .62)) + .5;
      b = ((b - .5) * (1 + recipe.contrast * .62)) + .5;

      final luma = _luminance(r, g, b);
      final saturation =
          recipe.saturation + recipe.vibrance * (1 - _saturation(r, g, b));
      r = luma + (r - luma) * (1 + saturation);
      g = luma + (g - luma) * (1 + saturation);
      b = luma + (b - luma) * (1 + saturation);

      // Lift dark values for a film-like fade.
      r = r + recipe.fade * (.08 - r * .08);
      g = g + recipe.fade * (.08 - g * .08);
      b = b + recipe.fade * (.08 - b * .08);

      final dx = (x / math.max(1, width - 1)) * 2 - 1;
      final dy = (y / math.max(1, height - 1)) * 2 - 1;
      final radial = math.sqrt(dx * dx + dy * dy) / math.sqrt(2);
      final vignette = 1 - (recipe.vignette * radial * radial * .42);
      r *= vignette;
      g *= vignette;
      b *= vignette;

      if (recipe.grain > 0) {
        final noise = _grain(x, y) * recipe.grain * .055;
        r += noise;
        g += noise;
        b += noise;
      }

      if (recipe.sharpness > 0 &&
          x > 0 &&
          x < width - 1 &&
          y > 0 &&
          y < height - 1) {
        final center = _luminance(pixel.r / 255, pixel.g / 255, pixel.b / 255);
        final neighbourAverage = _neighbourLuminance(original, x, y);
        final sharpen = (center - neighbourAverage) * recipe.sharpness * .65;
        r += sharpen;
        g += sharpen;
        b += sharpen;
      }

      source.setPixelRgba(
        x,
        y,
        (_clamp(r) * 255).round(),
        (_clamp(g) * 255).round(),
        (_clamp(b) * 255).round(),
        pixel.a.round(),
      );
    }
  }

  return Uint8List.fromList(
    request.outputFormat == PhotoOutputFormat.png
        ? img.encodePng(source)
        : img.encodeJpg(source, quality: request.quality),
  );
}

bool _matchesRequestedFormat(Uint8List bytes, PhotoOutputFormat format) {
  if (format == PhotoOutputFormat.png) {
    return bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47;
  }
  return bytes.length >= 3 &&
      bytes[0] == 0xFF &&
      bytes[1] == 0xD8 &&
      bytes[2] == 0xFF;
}

/// Removes JPEG metadata segments while retaining the exact compressed image
/// data. APP1 may contain EXIF/XMP (including location), APP13 IPTC, and COM
/// may contain personal notes. JFIF/JFXX, ICC, and Adobe colour segments are
/// retained because they describe image rendering rather than user data.
Uint8List _stripJpegMetadata(Uint8List bytes) {
  if (!_matchesRequestedFormat(bytes, PhotoOutputFormat.jpeg)) {
    return Uint8List.fromList(bytes);
  }

  final output = BytesBuilder(copy: false)..add(bytes.sublist(0, 2));
  var index = 2;
  while (index < bytes.length) {
    final markerStart = index;
    if (bytes[index] != 0xFF) return Uint8List.fromList(bytes);
    while (index < bytes.length && bytes[index] == 0xFF) {
      index++;
    }
    if (index >= bytes.length) return Uint8List.fromList(bytes);
    final marker = bytes[index++];

    // Start of scan owns the remaining entropy-coded bytes. End-of-image and
    // restart markers do not carry a length field either.
    if (marker == 0xDA || marker == 0xD9) {
      output.add(bytes.sublist(markerStart));
      return output.takeBytes();
    }
    if (marker == 0x01 || (marker >= 0xD0 && marker <= 0xD7)) {
      output.add(bytes.sublist(markerStart, index));
      continue;
    }
    if (index + 2 > bytes.length) return Uint8List.fromList(bytes);
    final length = (bytes[index] << 8) | bytes[index + 1];
    final end = index + length;
    if (length < 2 || end > bytes.length) return Uint8List.fromList(bytes);

    if (_keepJpegSegment(marker, bytes, index + 2, end)) {
      output.add(bytes.sublist(markerStart, end));
    }
    index = end;
  }
  return Uint8List.fromList(bytes);
}

bool _keepJpegSegment(int marker, Uint8List bytes, int dataStart, int end) {
  // APP0 is only retained for the standard JFIF/JFXX headers.
  if (marker == 0xE0) {
    return _segmentStartsWith(bytes, dataStart, end, const [
          0x4A,
          0x46,
          0x49,
          0x46,
          0x00,
        ]) ||
        _segmentStartsWith(bytes, dataStart, end, const [
          0x4A,
          0x46,
          0x58,
          0x58,
          0x00,
        ]);
  }
  // ICC and Adobe colour-transform descriptors are safe and preserve colour.
  if (marker == 0xE2) {
    return _segmentStartsWith(bytes, dataStart, end, const [
      0x49,
      0x43,
      0x43,
      0x5F,
      0x50,
      0x52,
      0x4F,
      0x46,
      0x49,
      0x4C,
      0x45,
      0x00,
    ]);
  }
  if (marker == 0xEE) {
    return _segmentStartsWith(bytes, dataStart, end, const [
      0x41,
      0x64,
      0x6F,
      0x62,
      0x65,
    ]);
  }
  // Remove all other APPn and COM blocks. Non-APP coding segments are needed
  // to decode the JPEG and must remain untouched.
  return !(marker == 0xFE || (marker >= 0xE0 && marker <= 0xEF));
}

bool _segmentStartsWith(Uint8List bytes, int start, int end, List<int> prefix) {
  if (end - start < prefix.length) return false;
  for (var i = 0; i < prefix.length; i++) {
    if (bytes[start + i] != prefix[i]) return false;
  }
  return true;
}

img.Image _centerCrop(img.Image source, double aspectRatio) {
  final sourceRatio = source.width / source.height;
  if ((sourceRatio - aspectRatio).abs() < .001) return source;
  final cropWidth = sourceRatio > aspectRatio
      ? (source.height * aspectRatio).round()
      : source.width;
  final cropHeight = sourceRatio > aspectRatio
      ? source.height
      : (source.width / aspectRatio).round();
  return img.copyCrop(
    source,
    x: (source.width - cropWidth) ~/ 2,
    y: (source.height - cropHeight) ~/ 2,
    width: cropWidth.clamp(1, source.width),
    height: cropHeight.clamp(1, source.height),
  );
}

double _luminance(double r, double g, double b) =>
    r * .2126 + g * .7152 + b * .0722;

double _saturation(double r, double g, double b) {
  final high = math.max(r, math.max(g, b));
  final low = math.min(r, math.min(g, b));
  return high <= 0 ? 0 : (high - low) / high;
}

double _neighbourLuminance(img.Image image, int x, int y) {
  var sum = 0.0;
  for (final offset in const [(-1, 0), (1, 0), (0, -1), (0, 1)]) {
    final pixel = image.getPixel(x + offset.$1, y + offset.$2);
    sum += _luminance(pixel.r / 255, pixel.g / 255, pixel.b / 255);
  }
  return sum / 4;
}

double _grain(int x, int y) {
  final hash = (x * 73856093) ^ (y * 19349663);
  return ((hash & 1023) / 1023.0) - .5;
}

double _clamp(double value) => value.clamp(0.0, 1.0).toDouble();

class PhotoProcessingException implements Exception {
  const PhotoProcessingException(this.message);
  final String message;

  @override
  String toString() => message;
}
