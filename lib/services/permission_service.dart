import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestLocationPermissions() async {
    // 1. Request foreground location
    var status = await Permission.location.request();
    if (!status.isGranted) {
      return false;
    }

    // 2. Request background location (Android 10+ and iOS always)
    if (Platform.isAndroid || Platform.isIOS) {
      var bgStatus = await Permission.locationAlways.request();
      if (!bgStatus.isGranted) {
        return false;
      }
    }

    // 3. Request notification permission (Android 13+)
    if (Platform.isAndroid) {
      var notifStatus = await Permission.notification.request();
      if (!notifStatus.isGranted) {
        return false;
      }
    }

    return true;
  }

  static Future<bool> get hasLocationPermission async {
    final fg = await Permission.location.status;
    final bg = await Permission.locationAlways.status;
    return fg.isGranted && bg.isGranted;
  }

  static Future<bool> get hasNotificationPermission async {
    if (!Platform.isAndroid) return true;
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  static Future<void> openSettings() async {
    await openAppSettings();
  }
}
