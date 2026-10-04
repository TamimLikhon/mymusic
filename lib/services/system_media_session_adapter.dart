import 'dart:io';

import 'package:flutter/services.dart';

import 'stream/stream_session_controller.dart';

enum SystemMediaCommand { play, pause, stop }

/// A thin Android [MediaSession] bridge for web playback. It deliberately
/// updates Android only after the WebView reports its real state, so it never
/// pretends that a silent native audio source is the stream.
class SystemMediaSessionAdapter {
  static const _channel = MethodChannel('com.example.mymusic/stream_media');

  Future<void> Function(SystemMediaCommand command)? _onCommand;
  bool _initialized = false;

  Future<void> initialize(
    Future<void> Function(SystemMediaCommand command) onCommand,
  ) async {
    if (!Platform.isAndroid || _initialized) return;

    _onCommand = onCommand;
    _channel.setMethodCallHandler(_handleMethodCall);
    try {
      await _channel.invokeMethod<void>('initialize');
      _initialized = true;
    } on MissingPluginException {
      // A page-only stream remains usable if the native adapter is unavailable.
      _channel.setMethodCallHandler(null);
    } catch (_) {
      _channel.setMethodCallHandler(null);
    }
  }

  Future<void> update({
    required bool active,
    required bool isPlaying,
    StreamNowPlaying? nowPlaying,
  }) async {
    if (!Platform.isAndroid || !_initialized) return;

    try {
      await _channel.invokeMethod<void>('update', {
        'active': active,
        'isPlaying': isPlaying,
        'title': nowPlaying?.title,
        'artist': nowPlaying?.artist,
        'artUrl': nowPlaying?.artUrl,
      });
    } on MissingPluginException {
      _initialized = false;
    }
  }

  Future<void> clear() => update(
        active: false,
        isPlaying: false,
      );

  Future<void> dispose() async {
    if (Platform.isAndroid && _initialized) {
      try {
        await _channel.invokeMethod<void>('clear');
      } on MissingPluginException {
        // The activity has already gone away.
      }
    }
    _channel.setMethodCallHandler(null);
    _initialized = false;
    _onCommand = null;
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method != 'command') return;
    final arguments = call.arguments;
    final value = arguments is Map ? arguments['command'] : null;
    final command = switch (value) {
      'play' => SystemMediaCommand.play,
      'pause' => SystemMediaCommand.pause,
      'stop' => SystemMediaCommand.stop,
      _ => null,
    };
    if (command != null) await _onCommand?.call(command);
  }
}
