import 'package:permission_handler/permission_handler.dart';

/// Keeps runtime camera permission decisions separate from camera startup.
/// This prevents a slow camera backend from being mistaken for a user denial.
abstract interface class CameraPermissionService {
  Future<CameraPermissionStatus> requestCamera();
}

enum CameraPermissionStatus { granted, denied, permanentlyDenied, restricted }

class PlatformCameraPermissionService implements CameraPermissionService {
  const PlatformCameraPermissionService();

  @override
  Future<CameraPermissionStatus> requestCamera() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) status = await Permission.camera.request();
    if (status.isGranted || status.isLimited) {
      return CameraPermissionStatus.granted;
    }
    if (status.isPermanentlyDenied) {
      return CameraPermissionStatus.permanentlyDenied;
    }
    if (status.isRestricted) return CameraPermissionStatus.restricted;
    return CameraPermissionStatus.denied;
  }
}
