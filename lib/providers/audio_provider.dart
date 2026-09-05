import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../data/database/app_database.dart';
import '../data/models/queue_state.dart';
import '../services/unified_audio_service.dart';
import '../services/analytics_service.dart';
import '../core/utils/art_extractor.dart';

class AudioProvider extends ChangeNotifier {
  // Use the shared player directly — no intermediate service needed.
  AudioPlayer get _player => UnifiedAudioService.instance.player;
  final AppDatabase _db;

  QueueState _queueState = QueueState();
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  final bool _isLoading = false;
  // True only while this provider owns the shared player (i.e. local music is
  // the active source). False when stream has taken over.
  bool _isActive = false;
  
  String? _lastLoggedSongId;

  QueueState get queueState => _queueState;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isLoading => _isLoading;
  Song? get currentSong => _queueState.currentSong;
  AudioPlayer get player => _player;

  final ValueNotifier<Duration> positionNotifier = ValueNotifier(Duration.zero);

  AudioProvider(this._db) {
    _initStreams();
  }

  void _initStreams() {
    _player.positionStream.listen((pos) {
      if (!_isActive) return;
      _position = pos;
      positionNotifier.value = pos;
    });

    _player.durationStream.listen((dur) {
      if (!_isActive) return;
      _duration = dur ?? Duration.zero;
      notifyListeners();
    });

    _player.playerStateStream.listen((state) {
      if (!_isActive) return;
      _isPlaying = state.playing;
      notifyListeners();
    });

    _player.playbackEventStream.listen(
      (event) {},
      onError: (Object e, StackTrace st) {
        if (e is PlayerException) {
          _player.seekToNext();
        }
      },
    );

    _player.sequenceStateStream.listen((sequenceState) {
      final effectiveSequence = sequenceState.effectiveSequence;
      if (effectiveSequence.isEmpty) return;

      final baseQueue = _queueState.unshuffledQueue ?? _queueState.queue;

      // Update queue to match effective sequence (handles shuffle natively)
      List<Song> newQueue = [];
      for (var source in effectiveSequence) {
        if (source.tag is MediaItem) {
          final tag = source.tag as MediaItem;
          final song = baseQueue.where((s) => s.id == tag.id).firstOrNull;
          if (song != null) newQueue.add(song);
        }
      }

      if (newQueue.isEmpty) return;

      // Find current index in the effective sequence
      final currentSource = sequenceState.currentSource;
      int newIndex = 0;
      if (currentSource != null) {
        newIndex = effectiveSequence.indexOf(currentSource);
        if (newIndex == -1) newIndex = 0;
      }

      _queueState = _queueState.copyWith(
        queue: newQueue,
        currentIndex: newIndex,
        isShuffled: _player.shuffleModeEnabled,
        repeatMode: _mapLoopMode(_player.loopMode),
      );

      final song = _queueState.currentSong;
      if (song != null) {
        _db.songDao.updateLastPlayed(song.id);
        if (song.custom_art_path == null) {
          ArtExtractor.extractAndCacheArt(song.file_path, song.id);
        }
        if (_lastLoggedSongId != song.id) {
          _lastLoggedSongId = song.id;
          // Track which song was played and by whom.
          AnalyticsService.instance.logSongPlayed(
            title: song.title,
            artist: song.artist ?? 'Unknown',
          );
        }
      }

      notifyListeners();
    });
  }

  RepeatMode _mapLoopMode(LoopMode mode) {
    switch (mode) {
      case LoopMode.off:
        return RepeatMode.none;
      case LoopMode.one:
        return RepeatMode.one;
      case LoopMode.all:
        return RepeatMode.all;
    }
  }

  LoopMode _mapRepeatMode(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.none:
        return LoopMode.off;
      case RepeatMode.one:
        return LoopMode.one;
      case RepeatMode.all:
        return LoopMode.all;
    }
  }

  // ── Queue loading ──────────────────────────────────────────────────────────

  Future<void> _loadQueue(
    List<Song> songs,
    String cacheDirPath, {
    int initialIndex = 0,
  }) async {
    // Stop any active session (local or stream) before loading a new source.
    await _player.stop();

    // Claim ownership of the shared player for local music.
    _isActive = true;

    // ignore: deprecated_member_use
    final playlist = ConcatenatingAudioSource(
      children: songs
          .map(
            (song) => AudioSource.uri(
              Uri.parse('file://${song.file_path}'),
              tag: MediaItem(
                id: song.id,
                title: song.title,
                artist: song.artist,
                album: song.album,
                artUri: song.custom_art_path != null
                    ? Uri.file(song.custom_art_path!)
                    : Uri.file('$cacheDirPath/${song.id}.jpg'),
              ),
            ),
          )
          .toList(),
    );

    await _player.setAudioSource(
      playlist,
      initialIndex: initialIndex,
      initialPosition: Duration.zero,
    );
  }

  // ── Public playback API ────────────────────────────────────────────────────

  Future<void> playAllSongs(List<Song> songs, {int startIndex = 0}) async {
    if (songs.isEmpty) return;

    _queueState = QueueState(
      source: QueueSource.allSongs,
      queue: songs,
      unshuffledQueue: songs,
      currentIndex: startIndex,
    );

    final cacheDir = await ArtExtractor.getCacheDir();
    final initialSong = songs[startIndex];
    if (initialSong.custom_art_path == null) {
      await ArtExtractor.extractAndCacheArt(
        initialSong.file_path,
        initialSong.id,
      );
    }
    await _loadQueue(songs, cacheDir, initialIndex: startIndex);
    await _player.play();
  }

  Future<void> playFromTag(
    String tagId,
    List<Song> songs, {
    int startIndex = 0,
  }) async {
    if (songs.isEmpty) return;

    _queueState = QueueState(
      source: QueueSource.tag,
      tagId: tagId,
      queue: songs,
      unshuffledQueue: songs,
      currentIndex: startIndex,
    );

    final cacheDir = await ArtExtractor.getCacheDir();
    final initialSong = songs[startIndex];
    if (initialSong.custom_art_path == null) {
      await ArtExtractor.extractAndCacheArt(
        initialSong.file_path,
        initialSong.id,
      );
    }
    await _loadQueue(songs, cacheDir, initialIndex: startIndex);
    await _player.play();
  }

  Future<void> shuffleAllSongs(List<Song> songs) async {
    if (songs.isEmpty) return;

    _queueState = QueueState(
      source: QueueSource.allSongs,
      queue: songs,
      unshuffledQueue: songs,
      currentIndex: 0,
    );

    final cacheDir = await ArtExtractor.getCacheDir();
    final initialSong = songs[0];
    if (initialSong.custom_art_path == null) {
      await ArtExtractor.extractAndCacheArt(
        initialSong.file_path,
        initialSong.id,
      );
    }
    await _loadQueue(songs, cacheDir, initialIndex: 0);
    await _player.setShuffleModeEnabled(true);
    await _player.shuffle();
    await _player.play();
  }

  Future<void> shuffleFromTag(String tagId, List<Song> songs) async {
    if (songs.isEmpty) return;

    _queueState = QueueState(
      source: QueueSource.tag,
      tagId: tagId,
      queue: songs,
      unshuffledQueue: songs,
      currentIndex: 0,
    );

    final cacheDir = await ArtExtractor.getCacheDir();
    final initialSong = songs[0];
    if (initialSong.custom_art_path == null) {
      await ArtExtractor.extractAndCacheArt(
        initialSong.file_path,
        initialSong.id,
      );
    }
    await _loadQueue(songs, cacheDir, initialIndex: 0);
    await _player.setShuffleModeEnabled(true);
    await _player.shuffle();
    await _player.play();
  }

  Future<void> play() async => await _player.play();
  Future<void> pause() async => await _player.pause();

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> seek(Duration position) async => await _player.seek(position);

  Future<void> next() async => await _player.seekToNext();

  Future<void> jumpToQueueIndex(int index) async {
    if (index < 0 || index >= _queueState.queue.length) return;

    final sequence = _player.sequenceState.effectiveSequence;
    if (index < sequence.length) {
      final originalIndex = _player.sequenceState.sequence.indexOf(
        sequence[index],
      );
      if (originalIndex != -1) {
        await _player.seek(Duration.zero, index: originalIndex);
        return;
      }
    }

    await _player.seek(Duration.zero, index: index);
  }

  Future<void> previous() async {
    if (_position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }
    await _player.seekToPrevious();
  }

  Future<void> stop() async {
    _isActive = false; // Release ownership so stream events are ignored.
    await _player.stop();
    _isPlaying = false;
    _position = Duration.zero;
    positionNotifier.value = Duration.zero;
    notifyListeners();
  }

  Future<void> toggleShuffle() async {
    final newMode = !_player.shuffleModeEnabled;
    await _player.setShuffleModeEnabled(newMode);
    if (newMode) await _player.shuffle();
  }

  Future<void> toggleRepeat() async {
    RepeatMode nextMode;
    switch (_queueState.repeatMode) {
      case RepeatMode.none:
        nextMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        nextMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        nextMode = RepeatMode.none;
        break;
    }
    await _player.setLoopMode(_mapRepeatMode(nextMode));
  }

  bool get hasNext {
    if (_queueState.queue.isEmpty) return false;
    return _player.hasNext;
  }

  bool get hasPrevious {
    if (_queueState.queue.isEmpty) return false;
    return _player.hasPrevious || _position.inSeconds > 3;
  }

  @override
  void dispose() {
    // The player is owned by UnifiedAudioService — do not dispose it here.
    super.dispose();
  }
}
