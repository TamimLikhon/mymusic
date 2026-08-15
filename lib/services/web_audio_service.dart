import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'auth_service.dart';
import 'unified_audio_service.dart';

/// Holds the song title and artist extracted from the YouTube Music DOM
/// via the JavaScript MutationObserver bridge.
class WebNowPlaying {
  final String title;
  final String artist;

  const WebNowPlaying({required this.title, required this.artist});

  @override
  bool operator ==(Object other) =>
      other is WebNowPlaying && other.title == title && other.artist == artist;

  @override
  int get hashCode => Object.hash(title, artist);
}

/// Bridges the InAppWebView's YouTube Music player state to the Flutter layer.
///
/// Responsibilities:
/// - Stores the currently-playing song info (extracted via JS bridge).
/// - Injects saved YouTube session cookies into the WebView before page loads.
/// - Manages a silent-audio lock screen session via [UnifiedAudioService] so
///   Android displays a media notification with song metadata.
class WebAudioService extends ChangeNotifier {
  final _authService = AuthService();

  WebNowPlaying? _nowPlaying;
  bool _isWebPlaying = false;
  bool _lockScreenActive = false;

  WebNowPlaying? get nowPlaying => _nowPlaying;
  bool get isWebPlaying => _isWebPlaying;

  AudioPlayer get _player => UnifiedAudioService.instance.player;

  // ── Now Playing ──────────────────────────────────────────────────────────

  /// Called by the JS bridge handler when the YouTube Music DOM title changes.
  void updateNowPlaying(WebNowPlaying? info) {
    if (_nowPlaying == info) return; // no-op if unchanged

    _nowPlaying = info;
    _isWebPlaying = info != null;
    notifyListeners();

    if (info != null) {
      _startLockScreenSession(info.title, info.artist);
    } else {
      _stopLockScreenSession();
    }
  }

  /// Called when the web player is explicitly paused (detected via JS).
  void setWebPaused(bool paused) {
    if (_isWebPlaying == !paused) return;
    _isWebPlaying = !paused;
    notifyListeners();
    if (paused) {
      _player.pause();
    } else if (_lockScreenActive) {
      _player.play();
    }
  }

  // ── Cookie Injection ─────────────────────────────────────────────────────

  /// Injects saved YouTube session cookies into the WebView's [CookieManager]
  /// before the page loads.  Must be called from [onWebViewCreated].
  Future<void> injectCookies(InAppWebViewController controller) async {
    try {
      final cookieString = await _authService.getCookies();
      if (cookieString == null || cookieString.isEmpty) return;

      final cookieManager = CookieManager.instance();
      final pairs = cookieString.split('; ');

      for (final pair in pairs) {
        final eqIdx = pair.indexOf('=');
        if (eqIdx < 1) continue;
        final name = pair.substring(0, eqIdx).trim();
        final value = pair.substring(eqIdx + 1).trim();

        for (final domain in ['music.youtube.com', 'youtube.com']) {
          await cookieManager.setCookie(
            url: WebUri('https://$domain'),
            name: name,
            value: value,
            domain: '.$domain',
            isSecure: true,
            isHttpOnly: false,
          );
        }
      }
    } catch (e) {
      if (kDebugMode) print('WebAudioService.injectCookies error: $e');
    }
  }

  // ── Lock Screen (Silent Audio Trick) ─────────────────────────────────────

  /// Loads a looping silent MP3 into [UnifiedAudioService.player] and sets its
  /// [MediaItem] tag so Android's lock screen / notification shows the correct
  /// song title and artist.  The silent player produces no audible output —
  /// YouTube Music (inside the WebView) is the source of real audio.
  Future<void> _startLockScreenSession(String title, String artist) async {
    try {
      if (_lockScreenActive &&
          _player.playing &&
          _player.audioSource != null) {
        // Just update the metadata tag — no need to reload the silent audio.
        // just_audio_background picks up the new MediaItem automatically.
        await _player.stop();
      }

      await _player.setAudioSource(
        AudioSource.asset(
          'assets/silence.mp3',
          tag: MediaItem(
            id: 'web_stream_session',
            title: title,
            artist: artist,
          ),
        ),
        preload: true,
      );

      // Loop infinitely so the lock screen notification is never dismissed.
      await _player.setLoopMode(LoopMode.one);
      await _player.play();
      _lockScreenActive = true;
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
    _stopLockScreenSession();
    super.dispose();
  }
}
