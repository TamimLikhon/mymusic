import 'dart:async';

import 'package:flutter/foundation.dart';

import 'stream/stream_session_controller.dart';
import 'system_media_session_adapter.dart';

enum PlaybackCoordinatorState {
  idle,
  localLoading,
  localPlaying,
  localPaused,
  streamLoading,
  streamReady,
  streamPlaying,
  streamPaused,
  recovering,
  failed,
}

typedef StopLocalPlayback = Future<void> Function();

/// The only component allowed to transition between offline and web playback.
/// It serializes transitions, keeps the two modes mutually exclusive, and
/// treats WebView acknowledgements as evidence rather than assumptions.
class PlaybackCoordinator extends ChangeNotifier {
  final StreamSessionController streamSession;
  final SystemMediaSessionAdapter _systemMediaSession;

  PlaybackCoordinatorState _state = PlaybackCoordinatorState.idle;
  StopLocalPlayback? _stopLocalPlayback;
  Future<void> _queue = Future<void>.value();
  bool _streamSessionActive = false;
  bool _suppressStreamUntilStopped = false;
  bool _disposed = false;

  PlaybackCoordinator({
    required this.streamSession,
    SystemMediaSessionAdapter? systemMediaSession,
  }) : _systemMediaSession = systemMediaSession ?? SystemMediaSessionAdapter() {
    streamSession.addListener(_onStreamSessionChanged);
  }

  PlaybackCoordinatorState get state => _state;
  bool get isLocalSessionActive => switch (_state) {
        PlaybackCoordinatorState.localLoading ||
        PlaybackCoordinatorState.localPlaying ||
        PlaybackCoordinatorState.localPaused => true,
        _ => false,
      };
  bool get isStreamSessionActive => _streamSessionActive;
  bool get isStreamPlaying => _state == PlaybackCoordinatorState.streamPlaying;

  Future<void> initialize() => _systemMediaSession.initialize(_onMediaCommand);

  void registerLocalPlayback(StopLocalPlayback stopLocalPlayback) {
    _stopLocalPlayback = stopLocalPlayback;
  }

  /// Called by [AudioProvider] before loading or resuming an offline source.
  /// Local playback is refused if the active WebView cannot confirm it paused;
  /// this is stricter than risking two audible sources at once.
  Future<void> prepareLocalPlayback() => _serialize(() async {
        if (_streamSessionActive || streamSession.isPlaying) {
          final stopped = await streamSession.pauseAndWaitForStopped();
          if (!stopped) {
            _setState(PlaybackCoordinatorState.recovering);
            throw StateError(
              'Local playback was not started because the web stream did not pause.',
            );
          }
        }
        _streamSessionActive = false;
        _suppressStreamUntilStopped = false;
        await _systemMediaSession.clear();
        _setState(PlaybackCoordinatorState.localLoading);
      });

  void reportLocalPlaybackState(bool isPlaying) {
    if (!isLocalSessionActive) return;
    _setState(
      isPlaying
          ? PlaybackCoordinatorState.localPlaying
          : PlaybackCoordinatorState.localPaused,
    );
  }

  void reportLocalPlaybackStopped() {
    if (isLocalSessionActive) _setState(PlaybackCoordinatorState.idle);
  }

  Future<StreamCommandResult> requestStreamPlay() => _serialize(() async {
        if (!streamSession.canControlPlayback) {
          return StreamCommandResult.rejected(
            'stream-unavailable',
            'Native stream controls are unavailable. Start playback in the page.',
          );
        }

        await _stopLocalPlayback?.call();
        _streamSessionActive = true;
        _suppressStreamUntilStopped = false;
        _setState(PlaybackCoordinatorState.streamLoading);
        final result = await streamSession.requestPlay();
        if (!result.acknowledged && !streamSession.isPlaying) {
          _setState(PlaybackCoordinatorState.streamReady);
        }
        return result;
      });

  Future<StreamCommandResult> requestStreamPause() => _serialize(() async {
        if (!streamSession.canControlPlayback) {
          return StreamCommandResult.rejected(
            'stream-unavailable',
            'Native stream controls are unavailable.',
          );
        }
        final result = await streamSession.requestPause();
        if (!result.acknowledged && streamSession.isPlaying) {
          _setState(PlaybackCoordinatorState.streamPlaying);
        }
        return result;
      });

  Future<StreamCommandResult> toggleStreamPlayback() {
    return streamSession.isPlaying ? requestStreamPause() : requestStreamPlay();
  }

  Future<void> stopAll() => _serialize(() async {
        await _stopLocalPlayback?.call();
        if (streamSession.isPlaying) await streamSession.requestPause();
        _streamSessionActive = false;
        _suppressStreamUntilStopped = true;
        await _systemMediaSession.clear();
        _setState(PlaybackCoordinatorState.idle);
      });

  void _onStreamSessionChanged() {
    if (_disposed) return;
    unawaited(_serialize(_synchronizeStreamState));
  }

  Future<void> _synchronizeStreamState() async {
    if (streamSession.isRecovering) {
      if (_streamSessionActive) {
        _setState(PlaybackCoordinatorState.recovering);
        await _systemMediaSession.clear();
      }
      return;
    }

    // Google sign-in and every non-music destination intentionally have no
    // bridge or system-media session, even if the previous stream was active.
    if (!streamSession.isMusicPage) {
      if (_streamSessionActive) {
        _streamSessionActive = false;
        _setState(PlaybackCoordinatorState.idle);
        await _systemMediaSession.clear();
      }
      return;
    }

    if (streamSession.capabilityTier == StreamCapabilityTier.unavailable &&
        _streamSessionActive) {
      _setState(PlaybackCoordinatorState.failed);
      await _systemMediaSession.clear();
      return;
    }

    if (_suppressStreamUntilStopped) {
      if (!streamSession.isPlaying) _suppressStreamUntilStopped = false;
      return;
    }

    // A real play event from the page is the only non-native path that can
    // activate a stream session. Stop the local player immediately first.
    if (streamSession.isPlaying && !_streamSessionActive) {
      await _stopLocalPlayback?.call();
      _streamSessionActive = true;
    }

    if (!_streamSessionActive) return;

    if (streamSession.isPlaying) {
      _setState(PlaybackCoordinatorState.streamPlaying);
    } else if (streamSession.bridgeReady) {
      _setState(PlaybackCoordinatorState.streamPaused);
    } else {
      _setState(PlaybackCoordinatorState.streamLoading);
    }

    await _systemMediaSession.update(
      active: true,
      isPlaying: streamSession.isPlaying,
      nowPlaying: streamSession.nowPlaying,
    );
  }

  Future<void> _onMediaCommand(SystemMediaCommand command) async {
    switch (command) {
      case SystemMediaCommand.play:
        await requestStreamPlay();
      case SystemMediaCommand.pause:
      case SystemMediaCommand.stop:
        await requestStreamPause();
    }
  }

  Future<T> _serialize<T>(Future<T> Function() operation) {
    final result = Completer<T>();
    _queue = _queue.catchError((_) {}).then((_) async {
      try {
        result.complete(await operation());
      } catch (error, stackTrace) {
        result.completeError(error, stackTrace);
      }
    });
    return result.future;
  }

  void _setState(PlaybackCoordinatorState value) {
    if (_state == value) return;
    _state = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    streamSession.removeListener(_onStreamSessionChanged);
    unawaited(_systemMediaSession.dispose());
    super.dispose();
  }
}
