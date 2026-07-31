import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../data/database/app_database.dart';
import '../data/models/queue_state.dart';
import '../services/audio_player_service.dart';
import '../core/utils/art_extractor.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayerService _service = AudioPlayerService();
  late final AudioPlayer _player;
  final AppDatabase _db;

  QueueState _queueState = QueueState();
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  final bool _isLoading = false;

  QueueState get queueState => _queueState;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isLoading => _isLoading;
  Song? get currentSong => _queueState.currentSong;
  AudioPlayer get player => _player;

  final ValueNotifier<Duration> positionNotifier = ValueNotifier(Duration.zero);

  AudioProvider(this._db) {
    _initService();
  }

  Future<void> _initService() async {
    await _service.initialize();
    _player = _service.player;
    _initStreams();
  }

  void _initStreams() {
    _service.positionStream.listen((pos) {
      _position = pos;
      positionNotifier.value = pos;
    });

    _service.durationStream.listen((dur) {
      _duration = dur ?? Duration.zero;
      notifyListeners();
    });

    _service.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });

    _service.sequenceStateStream.listen((sequenceState) {
      if (sequenceState == null) return;

      final effectiveSequence = sequenceState.effectiveSequence;
      if (effectiveSequence.isEmpty) return;

      final baseQueue = _queueState.unshuffledQueue ?? _queueState.queue;

      // Update queue to match effective sequence (handles shuffle natively)
      List<Song> newQueue = [];
      for (var source in effectiveSequence) {
        if (source.tag is MediaItem) {
          final tag = source.tag as MediaItem;
          final song = baseQueue.firstWhere(
            (s) => s.id == tag.id,
            orElse: () => baseQueue.first,
          );
          newQueue.add(song);
        }
      }

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
      await ArtExtractor.extractAndCacheArt(initialSong.file_path, initialSong.id);
    }
    await _service.setQueue(songs, cacheDir, initialIndex: startIndex);
    await _service.play();
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
      await ArtExtractor.extractAndCacheArt(initialSong.file_path, initialSong.id);
    }
    await _service.setQueue(songs, cacheDir, initialIndex: startIndex);
    await _service.play();
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
      await ArtExtractor.extractAndCacheArt(initialSong.file_path, initialSong.id);
    }
    await _service.setQueue(songs, cacheDir, initialIndex: 0);
    await _service.setShuffleModeEnabled(true);
    await _service.play();
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
      await ArtExtractor.extractAndCacheArt(initialSong.file_path, initialSong.id);
    }
    await _service.setQueue(songs, cacheDir, initialIndex: 0);
    await _service.setShuffleModeEnabled(true);
    await _service.play();
  }

  Future<void> play() async => await _service.play();
  Future<void> pause() async => await _service.pause();

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> seek(Duration position) async => await _service.seek(position);

  Future<void> next() async => await _service.seekToNext();

  Future<void> jumpToQueueIndex(int index) async {
    if (index < 0 || index >= _queueState.queue.length) return;

    // index is relative to effectiveSequence.
    // We need to map it back to the original source index for just_audio.seek()
    final sequence = _player.sequenceState.effectiveSequence;
    if (index < sequence.length) {
      final originalIndex = _player.sequenceState.sequence.indexOf(
        sequence[index],
      );
      if (originalIndex != -1) {
        await _service.seek(Duration.zero, index: originalIndex);
        return;
      }
    }

    await _service.seek(Duration.zero, index: index);
  }

  Future<void> previous() async {
    if (_position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }
    await _service.seekToPrevious();
  }

  Future<void> stop() async {
    await _service.stop();
    _isPlaying = false;
    _position = Duration.zero;
    positionNotifier.value = Duration.zero;
    notifyListeners();
  }

  Future<void> toggleShuffle() async {
    final newMode = !_player.shuffleModeEnabled;
    await _service.setShuffleModeEnabled(newMode);
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

    await _service.setLoopMode(_mapRepeatMode(nextMode));
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
    _service.dispose();
    super.dispose();
  }
}
