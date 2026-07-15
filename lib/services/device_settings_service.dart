import 'package:app_settings/app_settings.dart';

/// Platform settings are kept behind this small boundary so camera flows can
/// be tested without invoking a real device settings activity.
abstract interface class DeviceSettingsService {
  Future<void> openApplicationSettings();
}

class PlatformDeviceSettingsService implements DeviceSettingsService {
  const PlatformDeviceSettingsService();

  @override
  Future<void> openApplicationSettings() => AppSettings.openAppSettings();
}
