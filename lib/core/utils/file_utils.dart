import 'dart:io';
import 'package:path/path.dart' as p;
import '../constants/app_constants.dart';

String getFileExtension(String path) {
  final ext = p.extension(path);
  return ext.startsWith('.') ? ext.substring(1).toLowerCase() : ext.toLowerCase();
}

String formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

bool isAudioFile(String path) {
  final ext = getFileExtension(path);
  return AppConstants.supportedExtensions.contains(ext);
}

Future<int> getFileSize(String path) async {
  try {
    final file = File(path);
    return await file.length();
  } catch (_) {
    return 0;
  }
}
