import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

/// Singleton that owns the single [AudioPlayer] instance shared across the
/// entire app.  just_audio_background only permits one player at a time, so
/// both the local-music layer and the streaming layer share this one instance.
class UnifiedAudioService {
  UnifiedAudioService._();
  static final UnifiedAudioService instance = UnifiedAudioService._();

  late final AudioPlayer player;
  bool _wasPlayingBeforeInterruption = false;

  /// Must be awaited once (in main()) before any provider uses the player.
  Future<void> initialize() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    player = AudioPlayer();

    // ── Audio-focus / interruption handling ─────────────────────────────────
    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        _wasPlayingBeforeInterruption = player.playing;
        switch (event.type) {
          case AudioInterruptionType.duck:
            player.setVolume(0.3);
            break;
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            player.pause();
            break;
        }
      } else {
        switch (event.type) {
          case AudioInterruptionType.duck:
            player.setVolume(1.0);
            break;
          case AudioInterruptionType.pause:
            if (_wasPlayingBeforeInterruption) player.play();
            break;
          case AudioInterruptionType.unknown:
            break;
        }
      }
    });

    // ── Headphone-disconnect handling ────────────────────────────────────────
    session.becomingNoisyEventStream.listen((_) {
      player.pause();
    });
  }

  void dispose() {
    player.dispose();
  }
}
