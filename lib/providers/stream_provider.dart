import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:yt_flutter_musicapi/yt_flutter_musicapi.dart';
import '../data/models/stream_song.dart';
import 'playlist_provider.dart';

class MusicStreamProvider extends ChangeNotifier {
  PlaylistProvider? playlistProvider;
  final _api = YtFlutterMusicapi();
  final AudioPlayer _player = AudioPlayer();

  bool _isInitialized = false;
  bool _isSearching = false;
  bool _isBuffering = false;
  String? _error;
  final List<StreamSong> _results = [];
  StreamSong? _currentSong;
  int _currentIndex = -1;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  // ValueNotifier for position — avoids notifyListeners() on every tick
  final ValueNotifier<Duration> positionNotifier = ValueNotifier(Duration.zero);

  // Getters
  bool get isSearching => _isSearching;
  bool get isBuffering => _isBuffering;
  String? get error => _error;
  List<StreamSong> get results => _results;
  StreamSong? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get hasSong => _currentSong != null;

  int _searchId = 0;

  MusicStreamProvider() {
    _initPlayerListeners();
  }

  void _initPlayerListeners() {
    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      if (state.processingState == ProcessingState.completed) {
        next();
      }
      notifyListeners();
    });

    // ✅ Use ValueNotifier — does NOT trigger full widget rebuilds
    _player.positionStream.listen((pos) {
      _position = pos;
      positionNotifier.value = pos;
    });

    _player.durationStream.listen((dur) {
      if (dur != null) {
        _duration = dur;
        notifyListeners();
      }
    });

    _player.playbackEventStream.listen(
      (event) {},
      onError: (Object e, StackTrace st) {
        if (e is PlayerException) {
          if (kDebugMode) {
            print('Error code: ${e.code}');
            print('Error message: ${e.message}');
          }
          _handlePlayerError();
        } else {
          if (kDebugMode) {
            print('An error occurred: $e');
          }
        }
      },
    );
  }

  Future<void> _handlePlayerError() async {
    _error = "Playback error occurred. URL may have expired.";
    _isBuffering = false;
    notifyListeners();
    await stop();
  }

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    try {
      await _api.initialize(proxy: null, country: 'US');
      _isInitialized = true;
    } catch (e) {
      _error = 'Failed to initialize YouTube API: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _results.clear();
      _isSearching = false;
      notifyListeners();
      return;
    }

    _searchId++;
    final currentSearchId = _searchId;

    _isSearching = true;
    _error = null;
    _results.clear();
    notifyListeners();

    try {
      await _ensureInitialized();

      await for (final song in _api.streamSearchResults(
        query: query,
        limit: 15,
        audioQuality: AudioQuality.high,
        thumbQuality: ThumbnailQuality.high,
      )) {
        if (_searchId != currentSearchId) return; // Stale search
        _results.add(StreamSong.fromSearchResult(song));
        notifyListeners();
      }
    } catch (e) {
      if (_searchId == currentSearchId) {
        _error = 'Search failed: $e';
        if (kDebugMode) {
          print('Search failed: $e');
        }
      }
    } finally {
      if (_searchId == currentSearchId) {
        _isSearching = false;
        notifyListeners();
      }
    }
  }

  Future<void> playSong(StreamSong song, int index) async {
    _currentIndex = index;
    _currentSong = song;
    _isBuffering = true;
    _error = null;
    notifyListeners();

    if (song.audioUrl == null) {
      _error = "No audio URL available for this song.";
      _isBuffering = false;
      notifyListeners();
      return;
    }

    try {
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(song.audioUrl!),
          tag: MediaItem(
            id: song.videoId,
            title: song.title,
            artist: song.artists,
            artUri: song.thumbUrl != null ? Uri.parse(song.thumbUrl!) : null,
          ),
        ),
      );
      await _player.play();
      // Record in history
      playlistProvider?.addToHistory(song);
    } catch (e) {
      if (kDebugMode) {
        print('Error playing song: $e');
      }
      _error = 'Error playing song: $e';
    } finally {
      _isBuffering = false;
      notifyListeners();
    }
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> seek(Duration pos) async {
    await _player.seek(pos);
  }

  Future<void> next() async {
    if (_results.isEmpty) return;
    int nextIndex = _currentIndex + 1;
    if (nextIndex >= _results.length) {
      nextIndex = 0; // loop back to first song
    }
    await playSong(_results[nextIndex], nextIndex);
  }

  Future<void> previous() async {
    if (_results.isEmpty) return;
    int prevIndex = _currentIndex - 1;
    if (prevIndex < 0) {
      prevIndex = _results.length - 1; // loop to end
    }
    await playSong(_results[prevIndex], prevIndex);
  }

  Future<void> stop() async {
    await _player.stop();
    _currentSong = null;
    _currentIndex = -1;
    _position = Duration.zero;
    positionNotifier.value = Duration.zero;
    notifyListeners();
  }

  @override
  void dispose() {
    positionNotifier.dispose();
    _player.dispose();
    super.dispose();
  }
}
