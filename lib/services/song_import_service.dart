import 'dart:io';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import '../data/database/app_database.dart';
import '../core/utils/file_utils.dart';

class SongImportService {
  final AppDatabase _db;
  final _uuid = const Uuid();

  SongImportService(this._db);

  Future<List<String>> scanAndImportSongs({
    List<String> directories = const [],
  }) async {
    final newSongPaths = <String>[];

    for (final path in directories) {
      final dir = Directory(path);
      if (!await dir.exists()) continue;
      try {
        await for (final entity in dir.list(recursive: true)) {
          if (entity is File && isAudioFile(entity.path)) {
            final existing = await _songExists(entity.path);
            if (!existing) {
              final imported = await _importSong(entity.path);
              if (imported) newSongPaths.add(entity.path);
            }
          }
        }
      } catch (e) {
        // Skip directories that can't be accessed
        continue;
      }
    }
    return newSongPaths;
  }

  Future<bool> _songExists(String path) async {
    final existing = await (_db.select(_db.songs)
          ..where((s) => s.file_path.equals(path)))
        .get();
    return existing.isNotEmpty;
  }

  Future<bool> _importSong(String path) async {
    try {
      final file = File(path);

      // Check if file is accessible and has size
      final fileSize = await file.length();
      if (fileSize < 1024) return false; // Skip tiny files

      final metadata = readMetadata(file, getImage: false);

      await _db.into(_db.songs).insert(
            SongsCompanion.insert(
              id: _uuid.v4(),
              title: metadata.title ?? _getFileNameFromPath(path),
              artist: Value(metadata.artist ?? 'Unknown'),
              album: Value(metadata.album ?? 'Unknown'),
              duration: metadata.duration?.inMilliseconds ?? 0,
              file_path: path,
              file_size: Value(fileSize),
              added_at: DateTime.now().millisecondsSinceEpoch,
            ),
          );
      return true;
    } catch (e) {
      return false;
    }
  }

  String _getFileNameFromPath(String path) {
    final parts = path.split('/');
    final fileName = parts.last;
    // Remove extension
    final lastDot = fileName.lastIndexOf('.');
    return lastDot > 0 ? fileName.substring(0, lastDot) : fileName;
  }

  Future<int> getLibrarySize() async {
    final songs = await _db.songDao.getAllSongs();
    int totalSize = 0;
    for (final song in songs) {
      totalSize += song.file_size;
    }
    return totalSize;
  }
}
