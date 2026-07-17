import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('Android requests only the camera permission it needs', () async {
    final manifest = await File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsString();

    expect(manifest, contains('android.permission.CAMERA'));
    expect(
      manifest,
      contains('android.permission.RECORD_AUDIO"\n        tools:node="remove"'),
    );
    expect(manifest, isNot(contains('android.permission.READ_MEDIA_IMAGES')));
    expect(manifest, contains('android.permission.READ_EXTERNAL_STORAGE'));
    expect(manifest, contains('android:maxSdkVersion="28"'));
  });

  test('iOS explains every user-triggered photo capability', () async {
    final plist = await File('ios/Runner/Info.plist').readAsString();

    expect(plist, contains('<key>NSCameraUsageDescription</key>'));
    expect(plist, contains('<key>NSPhotoLibraryUsageDescription</key>'));
    expect(plist, contains('<key>NSPhotoLibraryAddUsageDescription</key>'));
    expect(plist, contains('<key>NSMotionUsageDescription</key>'));
    expect(plist, contains('only when you choose'));
  });
}
