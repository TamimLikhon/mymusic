import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'unified_audio_service.dart';

/// Holds the song title, artist, and thumbnail URL extracted from the
/// YouTube Music DOM via the JavaScript MutationObserver bridge.
class WebNowPlaying {
  final String title;
  final String artist;
  final String? artUrl; // YouTube Music thumbnail URL (may be empty)

  const WebNowPlaying({
    required this.title,
    required this.artist,
    this.artUrl,
  });

  @override
  bool operator ==(Object other) =>
      other is WebNowPlaying &&
      other.title == title &&
      other.artist == artist &&
      other.artUrl == artUrl;

  @override
  int get hashCode => Object.hash(title, artist, artUrl);
}

/// Bridges the InAppWebView's YouTube Music player state to the Flutter layer.
///
/// Responsibilities:
/// - Stores the currently-playing song info (extracted via JS bridge).
/// - Manages a silent-audio lock screen session via [UnifiedAudioService] so
///   Android displays a media notification with song metadata.
class WebAudioService extends ChangeNotifier {
  WebNowPlaying? _nowPlaying;
  bool _isWebPlaying = false;
  bool _lockScreenActive = false;
  bool _isSyncingFromWeb = false;
  StreamSubscription<PlayerState>? _playerStateSub;

  /// Set by [WebStreamPage] once the WebView controller is ready.
  /// Allows this service to evaluate JS in the WebView (e.g. pause/resume video).
  Future<void> Function(String js)? _jsEvaluator;

  WebNowPlaying? get nowPlaying => _nowPlaying;
  bool get isWebPlaying => _isWebPlaying;

  AudioPlayer get _player => UnifiedAudioService.instance.player;

  WebAudioService() {
    // Listen to notification / lock screen playback events (Play / Pause button taps)
    _playerStateSub = _player.playerStateStream.listen((state) {
      if (!_lockScreenActive) return;
      if (_isSyncingFromWeb) return; // Prevent feedback loop

      final isPlaying = state.playing;
      if (isPlaying && !_isWebPlaying) {
        _isWebPlaying = true;
        _jsEvaluator?.call(
          "if (window._myMusicPlay) { window._myMusicPlay(); } else { const v = document.querySelector('video'); if (v) v.play().catch(()=>{}); }",
        );
        notifyListeners();
      } else if (!isPlaying && _isWebPlaying) {
        _isWebPlaying = false;
        _jsEvaluator?.call(
          "if (window._myMusicPause) { window._myMusicPause(); } else { const v = document.querySelector('video'); if (v) v.pause(); }",
        );
        notifyListeners();
      }
    });
  }

  /// Called by [WebStreamPage] to give this service JS execution capability.
  void setJsEvaluator(Future<void> Function(String js)? evaluator) {
    _jsEvaluator = evaluator;
  }

  /// Toggles YouTube Music video playback from the Flutter side.
  Future<void> toggleStreamPlayback() async {
    if (_isWebPlaying) {
      await _jsEvaluator?.call(
        "if (window._myMusicPause) { window._myMusicPause(); } else { document.querySelector('video')?.pause(); }",
      );
      setWebPaused(true);
    } else {
      await _jsEvaluator?.call(
        "if (window._myMusicPlay) { window._myMusicPlay(); } else { document.querySelector('video')?.play().catch(()=>{}); }",
      );
      setWebPaused(false);
    }
  }

  // ── Playback State Synchronization ───────────────────────────────────────

  /// Called when YouTube Music's play/pause state changes in the WebView DOM.
  void syncWebPlaybackState(bool isPlaying) {
    if (_isWebPlaying == isPlaying) return;
    _isWebPlaying = isPlaying;
    notifyListeners();

    if (_lockScreenActive) {
      _isSyncingFromWeb = true;
      if (isPlaying && !_player.playing) {
        _player.play().catchError((_) {}).whenComplete(() {
          _isSyncingFromWeb = false;
        });
      } else if (!isPlaying && _player.playing) {
        _player.pause().catchError((_) {}).whenComplete(() {
          _isSyncingFromWeb = false;
        });
      } else {
        _isSyncingFromWeb = false;
      }
    }
  }

  // ── Now Playing ──────────────────────────────────────────────────────────

  /// Called by the JS bridge handler when the YouTube Music DOM title changes.
  void updateNowPlaying(WebNowPlaying? info) {
    // Guard: YouTube Music briefly emits an empty title between songs.
    // Ignoring these prevents premature session teardown during transitions.
    if (info != null && info.title.isEmpty) return;

    if (_nowPlaying == info) return; // no-op if unchanged

    _nowPlaying = info;
    _isWebPlaying = info != null;
    notifyListeners();

    if (info != null) {
      _startLockScreenSession(info.title, info.artist, info.artUrl);
    } else {
      _stopLockScreenSession();
    }
  }

  /// Called when the web player is explicitly paused (detected via JS).
  void setWebPaused(bool paused) {
    syncWebPlaybackState(!paused);
  }

  // ── Lock Screen (Silent Audio Trick) ─────────────────────────────────────

  /// Loads a looping silent MP3 into [UnifiedAudioService.player] and sets its
  /// [MediaItem] tag so Android's lock screen / notification shows the correct
  /// song title and artist.  The silent player produces no audible output —
  /// YouTube Music (inside the WebView) is the source of real audio.
  Future<void> _startLockScreenSession(
    String title,
    String artist,
    String? artUrl,
  ) async {
    try {
      // Resolve artwork URI — prefer the YouTube thumbnail URL.
      final artUri = (artUrl != null && artUrl.isNotEmpty)
          ? Uri.tryParse(artUrl)
          : null;

      if (_lockScreenActive) {
        // Session is already active — just update the MediaItem tag.
        await _player.setAudioSource(
          AudioSource.asset(
            'assets/silence.mp3',
            tag: MediaItem(
              id: 'web_stream_session',
              title: title,
              artist: artist,
              artUri: artUri,
            ),
          ),
          preload: false,
          initialPosition: null,
        );
        return;
      }

      // Fresh session start — load source, set loop, begin playing.
      await _player.setAudioSource(
        AudioSource.asset(
          'assets/silence.mp3',
          tag: MediaItem(
            id: 'web_stream_session',
            title: title,
            artist: artist,
            artUri: artUri,
          ),
        ),
        preload: true,
      );

      // Loop infinitely so the lock screen notification is never dismissed.
      await _player.setLoopMode(LoopMode.one);
      _lockScreenActive = true;
      await _player.play();
    } catch (e) {
      if (kDebugMode) print('WebAudioService._startLockScreenSession error: $e');
    }
  }

  Future<void> _stopLockScreenSession() async {
    if (!_lockScreenActive) return;
    try {
      await _player.stop();
      _lockScreenActive = false;
    } catch (e) {
      if (kDebugMode) print('WebAudioService._stopLockScreenSession error: $e');
    }
  }

  /// Call this when the local audio engine (AudioProvider) starts playing
  /// so we stop the WebView session gracefully.
  Future<void> handleLocalPlaybackStarted() async {
    _nowPlaying = null;
    _isWebPlaying = false;
    _lockScreenActive = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    _stopLockScreenSession();
    super.dispose();
  }
}
