import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../data/database/app_database.dart';

class CustomArtService {
  final AppDatabase _db;

  CustomArtService(this._db);

  /// Opens image picker, copies the picked image to private app storage,
  /// updates the song record in DB, and returns the stored path (or null).
  Future<String?> pickAndSetArt(String songId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return null;
    final srcPath = result.files.single.path;
    if (srcPath == null) return null;

    final destPath = await _copyArtToStorage(songId, srcPath);
    await _db.songDao.updateCustomArt(songId, destPath);
    return destPath;
  }

  /// Removes the custom art for a song, deletes the stored file, and
  /// clears the DB record.
  Future<void> clearArt(String songId, String? existingPath) async {
    if (existingPath != null) {
      final file = File(existingPath);
      if (await file.exists()) await file.delete();
    }
    await _db.songDao.updateCustomArt(songId, null);
  }

  Future<String> _copyArtToStorage(String songId, String srcPath) async {
    final dir = await getApplicationDocumentsDirectory();
    final artDir = Directory(p.join(dir.path, 'custom_art'));
    if (!await artDir.exists()) await artDir.create(recursive: true);

    final ext = p.extension(srcPath);
    final dest = File(p.join(artDir.path, '$songId$ext'));
    await File(srcPath).copy(dest.path);
    return dest.path;
  }
}
