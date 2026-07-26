import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestStoragePermission() async {
    // Android 13+: use READ_MEDIA_AUDIO
    final audioStatus = await Permission.audio.status;
    if (audioStatus.isGranted) return true;
    if (audioStatus.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    final result = await Permission.audio.request();
    if (result.isGranted) return true;
    if (result.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    // Android 12 and below fallback
    final storageStatus = await Permission.storage.request();
    if (storageStatus.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    return storageStatus.isGranted;
  }

  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    final result = await Permission.notification.request();
    if (result.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    return result.isGranted;
  }
}
