import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import '../data/database/app_database.dart';

class TagProvider extends ChangeNotifier {
  final AppDatabase _db;

  List<Tag> _tags = [];
  Map<String, int> _songCounts = {};
  bool _isLoading = false;

  List<Tag> get tags => _tags;
  Map<String, int> get songCounts => _songCounts;
  bool get isLoading => _isLoading;

  TagProvider(this._db) {
    loadTags();
  }

  Future<void> loadTags() async {
    _isLoading = true;
    notifyListeners();

    _tags = await _db.tagDao.getAllTags();
    _songCounts = await _db.songTagDao.getTagSongCounts();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createTag(String name, int color) async {
    await _db.tagDao.insertTag(
      TagsCompanion.insert(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        color: Value(color),
        created_at: DateTime.now().millisecondsSinceEpoch,
        updated_at: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    await loadTags();
  }

  Future<void> updateTag(String id, String name, int color) async {
    await _db.tagDao.updateTag(
      id,
      TagsCompanion(
        name: Value(name),
        color: Value(color),
        updated_at: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
    await loadTags();
  }

  Future<void> deleteTag(String id) async {
    await _db.tagDao.deleteTag(id);
    await loadTags();
  }

  Future<void> assignSongToTag(String songId, String tagId) async {
    await _db.songTagDao.assignSongToTag(songId, tagId);
    _songCounts = await _db.songTagDao.getTagSongCounts();
    notifyListeners();
  }

  Future<void> removeSongFromTag(String songId) async {
    await _db.songTagDao.removeSongFromTag(songId);
    _songCounts = await _db.songTagDao.getTagSongCounts();
    notifyListeners();
  }

  Future<List<Song>> getSongsForTag(String tagId) =>
      _db.songTagDao.getSongsForTag(tagId);

  Future<Tag?> getTagForSong(String songId) =>
      _db.songTagDao.getTagForSong(songId);

  Future<int> getTagSongCount(String tagId) async {
    final songs = await _db.songTagDao.getSongsForTag(tagId);
    return songs.length;
  }

  Future<int> getTagTotalDuration(String tagId) async {
    final songs = await _db.songTagDao.getSongsForTag(tagId);
    int total = 0;
    for (final song in songs) {
      total += song.duration;
    }
    return total;
  }

  Future<void> clearAllData() async {
    await _db.songTagDao.deleteAllSongTags();
    await _db.tagDao.deleteAllTags();
    _tags = [];
    _songCounts = {};
    notifyListeners();
  }
}
