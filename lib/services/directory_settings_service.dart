import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DirectorySettingsService {
  static const _fileName = 'music_directories.json';

  Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  /// Parses a SAF content URI from file_picker into a real filesystem path.
  /// Returns the original uri as fallback so the scanner can try it (dir.exists() will filter invalid ones).
  String? parseSafUri(String uri) {
    // Already a filesystem path
    if (uri.startsWith('/')) return uri;

    // Not a content URI — maybe file_picker returned something unexpected.
    // Return it as-is and let dir.exists() validate it.
    if (!uri.startsWith('content://')) return uri;

    // Extract the path segment after /tree/ or /document/
    String pathPart;
    final docIdx = uri.indexOf('/document/');
    if (docIdx != -1) {
      pathPart = uri.substring(docIdx + '/document/'.length);
    } else {
      const treePrefix = 'com.android.externalstorage.documents/tree/';
      final treeIdx = uri.indexOf(treePrefix);
      if (treeIdx == -1) return uri; // Unknown content URI — let callers decide
      pathPart = uri.substring(treeIdx + treePrefix.length);
    }

    // pathPart is like "primary%3AMusic%2FTelegram" or "primary:Music/Telegram"
    final colonIdx = pathPart.indexOf('%3A');
    final colonRaw = colonIdx == -1 ? pathPart.indexOf(':') : -1;
    final sepIdx = colonIdx != -1 ? colonIdx : colonRaw;

    if (sepIdx == -1) {
      // No volume delimiter — assume primary
      return '/storage/emulated/0/${Uri.decodeComponent(pathPart)}';
    }

    final volume = pathPart.substring(0, sepIdx);
    final relativePath = pathPart.substring(sepIdx + (colonIdx != -1 ? 3 : 1));
    final decodedPath = Uri.decodeComponent(relativePath);

    if (volume == 'primary') {
      return '/storage/emulated/0/$decodedPath';
    }
    return '/storage/$volume/$decodedPath';
  }

  Future<List<String>> loadDirectories() async {
    try {
      final file = await _file;
      if (!await file.exists()) return [];

      final content = await file.readAsString();
      return List<String>.from(jsonDecode(content));
    } catch (_) {
      return [];
    }
  }

  Future<void> saveDirectories(List<String> paths) async {
    final file = await _file;
    await file.writeAsString(jsonEncode(paths));
  }

  Future<List<String>> addDirectory(String path, {bool skipSave = false}) async {
    final dirs = await loadDirectories();
    if (dirs.contains(path)) return dirs;
    dirs.add(path);
    if (!skipSave) await saveDirectories(dirs);
    return dirs;
  }

  Future<List<String>> removeDirectory(String path) async {
    final dirs = await loadDirectories();
    dirs.remove(path);
    await saveDirectories(dirs);
    return dirs;
  }
}
