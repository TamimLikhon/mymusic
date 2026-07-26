import 'dart:io';

String getFileExtension(String path) {
  return path.split('.').last.toLowerCase();
}

String formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

bool isAudioFile(String path) {
  final ext = getFileExtension(path);
  return [
    'mp3', 'm4a', 'aac', 'wav', 'ogg', 'flac', 'opus', 'wma', 'amr',
  ].contains(ext);
}

Future<int> getFileSize(String path) async {
  try {
    final file = File(path);
    return await file.length();
  } catch (_) {
    return 0;
  }
}
