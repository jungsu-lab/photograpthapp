import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('Android requests only the camera permission it needs', () async {
    final manifest = await File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsString();
    final normalizedManifest = manifest.replaceAll('\r\n', '\n');

    expect(normalizedManifest, contains('android.permission.CAMERA'));
    expect(
      normalizedManifest,
      contains('android.permission.RECORD_AUDIO"\n        tools:node="remove"'),
    );
    expect(
      normalizedManifest,
      isNot(contains('android.permission.READ_MEDIA_IMAGES')),
    );
    expect(
      normalizedManifest,
      contains('android.permission.READ_EXTERNAL_STORAGE'),
    );
    expect(normalizedManifest, contains('android:maxSdkVersion="28"'));
  });

  test('iOS explains every user-triggered photo capability', () async {
    final plist = await File('ios/Runner/Info.plist').readAsString();

    expect(plist, contains('<key>NSCameraUsageDescription</key>'));
    expect(plist, contains('<key>NSPhotoLibraryUsageDescription</key>'));
    expect(plist, contains('<key>NSPhotoLibraryAddUsageDescription</key>'));
    expect(plist, contains('<key>NSMotionUsageDescription</key>'));
    expect(plist, contains('only when you choose'));
  });

  test('iOS project keeps the Swift Package permission integration eligible',
      () async {
    final project = await File(
      'ios/Runner.xcodeproj/project.pbxproj',
    ).readAsString();

    // Flutter's current iOS template resolves plugins through Swift Package
    // Manager. permission_handler_apple requires iOS 12+, while FrameFit
    // deliberately supports iOS 13 and keeps the generated package attached.
    expect(project, contains('IPHONEOS_DEPLOYMENT_TARGET = 13.0;'));
    expect(project, contains('FlutterGeneratedPluginSwiftPackage'));
    expect(project, contains('packageProductDependencies'));
  });
}
