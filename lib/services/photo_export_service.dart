import 'dart:io';
import 'dart:typed_data';

import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'photo_processor.dart';

class ExportedPhoto {
  const ExportedPhoto({required this.path, required this.fileName});

  final String path;
  final String fileName;
}

class PhotoExportService {
  PhotoExportService({
    Future<Directory> Function()? temporaryDirectory,
    Future<void> Function(ExportedPhoto photo)? saveToGallery,
    Future<ShareResult> Function(ExportedPhoto photo)? sharePhoto,
  }) : _temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory,
       _saveToGallery = saveToGallery ?? _saveToDeviceGallery,
       _sharePhoto = sharePhoto ?? _shareWithSystemSheet;

  final Future<Directory> Function() _temporaryDirectory;
  final Future<void> Function(ExportedPhoto photo) _saveToGallery;
  final Future<ShareResult> Function(ExportedPhoto photo) _sharePhoto;

  Future<ExportedPhoto> createImage(
    Uint8List bytes, {
    required String sourceName,
    required PhotoOutputFormat format,
  }) async {
    final directory = await _temporaryDirectory();
    final stamp = DateTime.now().toUtc().toIso8601String().replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    final stem = sourceName
        .replaceFirst(RegExp(r'\.[^.]+$'), '')
        .replaceAll(RegExp(r'[^a-zA-Z0-9가-힣_-]'), '-');
    final extension = format == PhotoOutputFormat.png ? 'png' : 'jpg';
    final fileName =
        'FrameFit-${stem.isEmpty ? 'photo' : stem}-$stamp.$extension';
    final output = File('${directory.path}${Platform.pathSeparator}$fileName');
    await output.writeAsBytes(bytes, flush: true);
    return ExportedPhoto(path: output.path, fileName: fileName);
  }

  Future<void> saveToGallery(ExportedPhoto photo) => _saveToGallery(photo);

  Future<ShareResult> share(ExportedPhoto photo) => _sharePhoto(photo);

  static Future<void> _saveToDeviceGallery(ExportedPhoto photo) =>
      Gal.putImage(photo.path, album: 'FrameFit');

  static Future<ShareResult> _shareWithSystemSheet(ExportedPhoto photo) =>
      SharePlus.instance.share(
        ShareParams(
          files: [XFile(photo.path)],
          text: 'Edited with FrameFit',
          title: 'FrameFit photo',
        ),
      );

  /// The exported file only exists to hand bytes to Gallery or the share
  /// sheet. Failures during cleanup must not turn a completed save/share into
  /// an apparent failure.
  Future<void> deleteTemporary(ExportedPhoto photo) async {
    try {
      final file = File(photo.path);
      if (await file.exists()) await file.delete();
    } catch (_) {
      // Best-effort cleanup. The operating system may still own a shared file.
    }
  }
}
