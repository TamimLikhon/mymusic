import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestStoragePermission({bool allowOpenSettings = false}) async {
    try {
      // Android 13+: use READ_MEDIA_AUDIO
      final audioStatus = await Permission.audio.status;
      if (audioStatus.isGranted) return true;
      
      if (!audioStatus.isPermanentlyDenied) {
        final result = await Permission.audio.request();
        if (result.isGranted) return true;
      } else if (allowOpenSettings) {
        await openAppSettings();
        return false;
      }

      // Android 12 and below fallback
      final storageStatus = await Permission.storage.status;
      if (storageStatus.isGranted) return true;
      
      if (!storageStatus.isPermanentlyDenied) {
        final result = await Permission.storage.request();
        return result.isGranted;
      } else if (allowOpenSettings) {
        await openAppSettings();
        return false;
      }
      
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> requestNotificationPermission({bool allowOpenSettings = false}) async {
    try {
      final status = await Permission.notification.status;
      if (status.isGranted) return true;
      
      if (!status.isPermanentlyDenied) {
        final result = await Permission.notification.request();
        return result.isGranted;
      } else if (allowOpenSettings) {
        await openAppSettings();
        return false;
      }
      
      return false;
    } catch (_) {
      return false;
    }
  }
}
