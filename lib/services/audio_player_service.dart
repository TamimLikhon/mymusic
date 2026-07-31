import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';
import '../data/database/app_database.dart';

class AudioPlayerService {
  late AudioPlayer _player;
  bool _isInitialized = false;

  AudioPlayer get player => _player;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Configure audio session for background playback
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Handle interruptions
    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.duck:
            _player.setVolume(0.3);
            break;
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            _player.pause();
            break;
        }
      } else {
        switch (event.type) {
          case AudioInterruptionType.duck:
            _player.setVolume(1.0);
            break;
          case AudioInterruptionType.pause:
            _player.play();
            break;
          case AudioInterruptionType.unknown:
            break;
        }
      }
    });

    // Handle headphone disconnect
    session.becomingNoisyEventStream.listen((_) {
      _player.pause();
    });

    _player = AudioPlayer();
    _isInitialized = true;
  }

  Future<void> setQueue(List<Song> songs, String cacheDirPath, {int initialIndex = 0}) async {
    if (!_isInitialized) await initialize();

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

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> stop() => _player.stop();
  Future<void> seek(Duration position, {int? index}) =>
      _player.seek(position, index: index);
  Future<void> seekToNext() => _player.seekToNext();
  Future<void> seekToPrevious() => _player.seekToPrevious();
  Future<void> setVolume(double volume) => _player.setVolume(volume);
  Future<void> setLoopMode(LoopMode mode) => _player.setLoopMode(mode);
  Future<void> setShuffleModeEnabled(bool enabled) =>
      _player.setShuffleModeEnabled(enabled);

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<int?> get currentIndexStream => _player.currentIndexStream;
  Stream<SequenceState?> get sequenceStateStream => _player.sequenceStateStream;

  void dispose() {
    _player.dispose();
  }
}
