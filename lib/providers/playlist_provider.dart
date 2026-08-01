import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../data/models/stream_song.dart';
import '../data/models/stream_playlist.dart';

class PlaylistProvider extends ChangeNotifier {
  static const _historyKey = 'stream_history';
  static const _playlistsKey = 'stream_playlists';
  static const _maxHistory = 30;

  List<StreamSong> _history = [];
  List<StreamPlaylist> _playlists = [];

  List<StreamSong> get history => _history;
  List<StreamPlaylist> get playlists => _playlists;

  PlaylistProvider() {
    _load();
  }

  // ── History ────────────────────────────────────────────────────────────────

  Future<void> addToHistory(StreamSong song) async {
    // Remove duplicate if it already exists, then insert at front
    _history.removeWhere((s) => s.videoId == song.videoId);
    _history.insert(0, song);
    if (_history.length > _maxHistory) {
      _history = _history.sublist(0, _maxHistory);
    }
    notifyListeners();
    await _saveHistory();
  }

  // ── Playlists ──────────────────────────────────────────────────────────────

  /// Returns the created playlist (or null if name is blank).
  Future<StreamPlaylist?> createPlaylist(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;

    final playlist = StreamPlaylist(
      id: const Uuid().v4(),
      name: trimmed,
    );
    _playlists.insert(0, playlist);
    notifyListeners();
    await _savePlaylists();
    return playlist;
  }

  /// Add [song] to playlist with [playlistId].
  /// Returns true if song was newly added, false if already present.
  Future<bool> addSongToPlaylist(String playlistId, StreamSong song) async {
    final playlist = _playlists.firstWhere(
      (p) => p.id == playlistId,
      orElse: () => throw StateError('Playlist not found: $playlistId'),
    );
    final added = playlist.addSong(song);
    if (added) {
      notifyListeners();
      await _savePlaylists();
    }
    return added;
  }

  /// Remove [song] from playlist with [playlistId].
  Future<void> removeSongFromPlaylist(String playlistId, String videoId) async {
    final playlist = _playlists.firstWhere((p) => p.id == playlistId);
    playlist.removeSong(videoId);
    notifyListeners();
    await _savePlaylists();
  }

  Future<void> deletePlaylist(String playlistId) async {
    _playlists.removeWhere((p) => p.id == playlistId);
    notifyListeners();
    await _savePlaylists();
  }

  bool songIsInPlaylist(String playlistId, String videoId) {
    final playlist = _playlists.where((p) => p.id == playlistId).firstOrNull;
    return playlist?.containsSong(videoId) ?? false;
  }

  // ── Persistence ────────────────────────────────────────────────────────────

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final historyRaw = prefs.getString(_historyKey);
      if (historyRaw != null) {
        final list = jsonDecode(historyRaw) as List<dynamic>;
        _history = list
            .map((e) => StreamSong.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      final playlistsRaw = prefs.getString(_playlistsKey);
      if (playlistsRaw != null) {
        _playlists = StreamPlaylist.decodeList(playlistsRaw);
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('PlaylistProvider._load error: $e');
    }
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _historyKey,
        jsonEncode(_history.map((s) => s.toJson()).toList()),
      );
    } catch (e) {
      if (kDebugMode) print('PlaylistProvider._saveHistory error: $e');
    }
  }

  Future<void> _savePlaylists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _playlistsKey,
        StreamPlaylist.encodeList(_playlists),
      );
    } catch (e) {
      if (kDebugMode) print('PlaylistProvider._savePlaylists error: $e');
    }
  }
}
