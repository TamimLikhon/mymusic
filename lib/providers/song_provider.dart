import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import '../data/database/app_database.dart';
import '../services/directory_settings_service.dart';
import '../services/song_import_service.dart';

enum ScanStatus { idle, scanning, completed, error }

class SongProvider extends ChangeNotifier {
  final AppDatabase _db;
  final _dirSettings = DirectorySettingsService();
  late final SongImportService _importService;

  List<Song> _songs = [];
  bool _isLoading = false;
  String? _error;
  ScanStatus _scanStatus = ScanStatus.idle;
  int _scannedCount = 0;
  List<String> _musicDirectories = [];

  List<Song> get songs => _songs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ScanStatus get scanStatus => _scanStatus;
  int get scannedCount => _scannedCount;
  List<String> get musicDirectories => _musicDirectories;

  SongProvider(this._db) {
    _importService = SongImportService(_db);
    _loadDirectories();
    loadSongs();
  }

  Future<void> _loadDirectories() async {
    _musicDirectories = await _dirSettings.loadDirectories();
    notifyListeners();
  }

  Future<void> addDirectory(String path) async {
    _musicDirectories = await _dirSettings.addDirectory(path);
    notifyListeners();
  }

  Future<void> removeDirectory(String path) async {
    _musicDirectories = await _dirSettings.removeDirectory(path);
    notifyListeners();
  }

  Future<void> loadSongs() async {
    _isLoading = true;
    notifyListeners();

    try {
      _songs = await _db.songDao.getAllSongs();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> scanAndImport() async {
    _scanStatus = ScanStatus.scanning;
    _scannedCount = 0;
    notifyListeners();

    try {
      final newSongs = await _importService.scanAndImportSongs(
        directories: _musicDirectories,
      );
      _scannedCount = newSongs.length;
      _songs = await _db.songDao.getAllSongs();
      _error = null;
      _scanStatus = ScanStatus.completed;
    } catch (e) {
      _error = e.toString();
      _scanStatus = ScanStatus.error;
    }

    notifyListeners();

    // Reset status after a delay
    Future.delayed(const Duration(seconds: 3), () {
      _scanStatus = ScanStatus.idle;
      notifyListeners();
    });
  }

  Future<void> deleteSong(String id) async {
    await _db.songDao.deleteSong(id);
    _songs.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  Future<void> clearAllData() async {
    await _db.songDao.deleteAllSongs();
    _songs = [];
    _scannedCount = 0;
    _scanStatus = ScanStatus.idle;
    notifyListeners();
  }

  Future<List<Song>> getRecentlyPlayed() =>
      _db.songDao.getRecentlyPlayed();

  Future<int> getLibrarySize() =>
      _importService.getLibrarySize();

  Future<bool> renameSong(Song song, String newTitle) async {
    try {
      final file = File(song.file_path);
      if (!await file.exists()) return false;

      final dir = p.dirname(song.file_path);
      final ext = p.extension(song.file_path);
      final newFilePath = p.join(dir, '$newTitle$ext');

      // Rename on file system
      await file.rename(newFilePath);

      // Update in database
      await _db.songDao.updateSongMetadata(song.id, newTitle, newFilePath);

      // Update in memory
      final index = _songs.indexWhere((s) => s.id == song.id);
      if (index != -1) {
        _songs[index] = _songs[index].copyWith(
          title: newTitle,
          file_path: newFilePath,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
