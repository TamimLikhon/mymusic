import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';
import 'package:yt_flutter_musicapi/yt_flutter_musicapi.dart';
import '../data/models/stream_song.dart';
import '../services/unified_audio_service.dart';
import 'playlist_provider.dart';

enum RepeatMode { none, one, all }

class MusicStreamProvider extends ChangeNotifier {
  PlaylistProvider? playlistProvider;
  final _api = YtFlutterMusicapi();

  // Use the app-wide shared player — never create a second one.
  AudioPlayer get _player => UnifiedAudioService.instance.player;

  bool _isInitialized = false;
  bool _isSearching = false;
  bool _isBuffering = false;
  String? _error;
  final List<StreamSong> _results = [];

  // Queue Management
  final List<StreamSong> _queue = [];
  int _queueIndex = -1;
  bool _shuffle = false;
  RepeatMode _repeatMode = RepeatMode.none;
  List<int> _shuffledIndices = [];

  StreamSong? _currentSong;
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
  List<StreamSong> get queue => _queue;
  int get queueIndex => _queueIndex;
  bool get shuffle => _shuffle;
  RepeatMode get repeatMode => _repeatMode;
  StreamSong? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get hasSong => _currentSong != null;

  int _searchId = 0;

  /// [UnifiedAudioService.initialize] must be awaited before this constructor
  /// runs (see main.dart). The player is guaranteed to exist at this point.
  MusicStreamProvider() {
    _initPlayerListeners();
  }

  void _initPlayerListeners() {
    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;

      // Keep _isBuffering in sync with the actual player processing state.
      // This handles network stalls, initial buffering, and source switches.
      _isBuffering = state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering;

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
    // Attempt to refresh the URL before giving up completely.
    if (_currentSong != null && _queueIndex >= 0) {
      try {
        await _refreshAndPlay(_currentSong!, _queueIndex);
        return;
      } catch (e) {
        if (kDebugMode) {
          print('Error refreshing URL: $e');
        }
      }
    }

    _error = "Playback error occurred. URL may have expired.";
    _isBuffering = false;
    notifyListeners();
    await stop();
  }

  Future<void> _refreshAndPlay(StreamSong song, int index) async {
    _isBuffering = true;
    notifyListeners();

    await _ensureInitialized();
    try {
      final freshResults =
          await _api.streamSearchResults(query: song.videoId, limit: 1).toList();
      if (freshResults.isNotEmpty) {
        final freshSong = StreamSong.fromSearchResult(freshResults.first);
        if (freshSong.audioUrl != null) {
          if (index >= 0 && index < _queue.length) {
            _queue[index] = freshSong;
            if (_currentSong?.videoId == song.videoId) {
              _currentSong = freshSong;
            }
          }
          await playSong(freshSong, index, replaceQueue: false);
          return;
        }
      }
      throw Exception("Could not refresh audio URL.");
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

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

  Future<void> playSong(StreamSong song, int index,
      {bool replaceQueue = true}) async {
    if (replaceQueue) {
      _queue.clear();
      _queue.addAll(_results);
      _queueIndex = index;
      _generateShuffledIndices();
    } else {
      _queueIndex = index;
    }

    _currentSong = song;
    _isBuffering = true;
    _error = null;
    notifyListeners();

    if (song.audioUrl == null) {
      try {
        await _refreshAndPlay(song, _queueIndex);
        return;
      } catch (e) {
        _error = "No audio URL available for this song.";
        _isBuffering = false;
        notifyListeners();
        return;
      }
    }

    try {
      // Stop any currently active local or stream session on the shared player
      // before loading the new audio source.
      await _player.stop();

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
      if (e is PlayerException) {
        _handlePlayerError();
      } else {
        _error = 'Error playing song: $e';
        _isBuffering = false;
        notifyListeners();
      }
    }
  }

  // Queue Controls
  void addToQueue(StreamSong song) {
    _queue.add(song);
    if (_queue.length == 1 && _currentSong == null) {
      playSong(song, 0, replaceQueue: false);
    } else if (_shuffle) {
      _shuffledIndices.add(_queue.length - 1);
    }
    notifyListeners();
  }

  void removeFromQueue(int index) {
    if (index < 0 || index >= _queue.length) return;

    _queue.removeAt(index);
    if (_shuffle) {
      _shuffledIndices.remove(index);
      for (int i = 0; i < _shuffledIndices.length; i++) {
        if (_shuffledIndices[i] > index) {
          _shuffledIndices[i]--;
        }
      }
    }

    if (index == _queueIndex) {
      if (_queue.isEmpty) {
        stop();
      } else {
        next(forceNext: true);
      }
    } else if (index < _queueIndex) {
      _queueIndex--;
    }
    notifyListeners();
  }

  void clearQueue() {
    _queue.clear();
    _shuffledIndices.clear();
    stop();
  }

  void reorderQueue(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final song = _queue.removeAt(oldIndex);
    _queue.insert(newIndex, song);

    // Adjust current index
    if (_queueIndex == oldIndex) {
      _queueIndex = newIndex;
    } else if (oldIndex < _queueIndex && newIndex >= _queueIndex) {
      _queueIndex--;
    } else if (oldIndex > _queueIndex && newIndex <= _queueIndex) {
      _queueIndex++;
    }

    // Rebuild shuffled indices if shuffle is active
    if (_shuffle) {
      _generateShuffledIndices();
    }
    notifyListeners();
  }

  void toggleShuffle() {
    _shuffle = !_shuffle;
    if (_shuffle) {
      _generateShuffledIndices();
    }
    notifyListeners();
  }

  void toggleRepeatMode() {
    switch (_repeatMode) {
      case RepeatMode.none:
        _repeatMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.none;
        break;
    }
    notifyListeners();
  }

  void _generateShuffledIndices() {
    if (_queue.isEmpty) {
      _shuffledIndices = [];
      return;
    }
    _shuffledIndices = List.generate(_queue.length, (i) => i)..shuffle();
    // Ensure the current song is first in the shuffled list
    if (_queueIndex >= 0 && _queueIndex < _queue.length) {
      _shuffledIndices.remove(_queueIndex);
      _shuffledIndices.insert(0, _queueIndex);
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

  Future<void> next({bool forceNext = false}) async {
    if (_queue.isEmpty) return;

    if (_repeatMode == RepeatMode.one && !forceNext) {
      await _player.seek(Duration.zero);
      await _player.play();
      return;
    }

    int nextIndex = -1;
    if (_shuffle) {
      int currentShuffleIndex = _shuffledIndices.indexOf(_queueIndex);
      if (currentShuffleIndex != -1 &&
          currentShuffleIndex + 1 < _shuffledIndices.length) {
        nextIndex = _shuffledIndices[currentShuffleIndex + 1];
      } else {
        if (_repeatMode == RepeatMode.all || forceNext) {
          _generateShuffledIndices();
          nextIndex = _shuffledIndices.first;
        } else {
          await stop();
          return;
        }
      }
    } else {
      if (_queueIndex + 1 < _queue.length) {
        nextIndex = _queueIndex + 1;
      } else {
        if (_repeatMode == RepeatMode.all || forceNext) {
          nextIndex = 0;
        } else {
          await stop();
          return;
        }
      }
    }

    if (nextIndex >= 0 && nextIndex < _queue.length) {
      await playSong(_queue[nextIndex], nextIndex, replaceQueue: false);
    }
  }

  Future<void> previous() async {
    if (_queue.isEmpty) return;

    if (_position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }

    int prevIndex = -1;
    if (_shuffle) {
      int currentShuffleIndex = _shuffledIndices.indexOf(_queueIndex);
      if (currentShuffleIndex > 0) {
        prevIndex = _shuffledIndices[currentShuffleIndex - 1];
      } else {
        prevIndex = _shuffledIndices.last;
      }
    } else {
      if (_queueIndex > 0) {
        prevIndex = _queueIndex - 1;
      } else {
        prevIndex = _queue.length - 1;
      }
    }

    if (prevIndex >= 0 && prevIndex < _queue.length) {
      await playSong(_queue[prevIndex], prevIndex, replaceQueue: false);
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _currentSong = null;
    _queueIndex = -1;
    _position = Duration.zero;
    positionNotifier.value = Duration.zero;
    notifyListeners();
  }

  @override
  void dispose() {
    positionNotifier.dispose();
    // The player is owned by UnifiedAudioService — do not dispose it here.
    super.dispose();
  }
}
