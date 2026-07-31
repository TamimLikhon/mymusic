import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ArtExtractor {
  static Future<String> getCacheDir() async {
    final tempDir = await getTemporaryDirectory();
    final artDir = Directory(p.join(tempDir.path, 'album_art'));
    if (!await artDir.exists()) {
      await artDir.create(recursive: true);
    }
    return artDir.path;
  }

  static Future<String> getCachePath(String songId) async {
    final dir = await getCacheDir();
    return p.join(dir, '$songId.jpg');
  }

  static Future<void> extractAndCacheArt(String filePath, String songId) async {
    final cachePath = await getCachePath(songId);
    final file = File(cachePath);
    if (await file.exists()) return;

    try {
      await compute(_extractArtTask, {
        'filePath': filePath,
        'cachePath': cachePath,
      });
    } catch (e) {
      // Ignore extraction errors
    }
  }

  static void _extractArtTask(Map<String, String> args) {
    try {
      final metadata = readMetadata(File(args['filePath']!), getImage: true);
      final pictures = metadata.pictures;
      if (pictures.isNotEmpty) {
        File(args['cachePath']!).writeAsBytesSync(pictures.first.bytes);
      }
    } catch (_) {}
  }
}
