import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'stream_bridge_message.dart';

enum StreamCapabilityTier { full, pageOnly, unavailable }

enum StreamCommandType { play, pause }

class StreamNowPlaying {
  final String title;
  final String artist;
  final String? artUrl;

  const StreamNowPlaying({
    required this.title,
    required this.artist,
    this.artUrl,
  });

  @override
  bool operator ==(Object other) =>
      other is StreamNowPlaying &&
      other.title == title &&
      other.artist == artist &&
      other.artUrl == artUrl;

  @override
  int get hashCode => Object.hash(title, artist, artUrl);
}

class StreamCommandResult {
  final String id;
  final bool acknowledged;
  final bool timedOut;
  final String? reason;

  const StreamCommandResult._({
    required this.id,
    required this.acknowledged,
    required this.timedOut,
    this.reason,
  });

  factory StreamCommandResult.acknowledged(String id) =>
      StreamCommandResult._(id: id, acknowledged: true, timedOut: false);

  factory StreamCommandResult.rejected(String id, String reason) =>
      StreamCommandResult._(
        id: id,
        acknowledged: false,
        timedOut: false,
        reason: reason,
      );

  factory StreamCommandResult.timedOut(String id) => StreamCommandResult._(
        id: id,
        acknowledged: false,
        timedOut: true,
        reason: 'The stream page did not acknowledge the command.',
      );
}

/// Owns the trusted WebView bridge only. It never owns a [just_audio]
/// player, which keeps web playback separate from offline playback.
class StreamSessionController extends ChangeNotifier {
  static const _musicOrigin = 'https://music.youtube.com';
  static const _musicHome = 'https://music.youtube.com/';
  static const _bridgeObjectName = 'mymusicStreamBridge';
  static const _commandTimeout = Duration(seconds: 4);

  final StreamBridgeMessageGate _messageGate = StreamBridgeMessageGate();
  final Map<String, Completer<StreamCommandResult>> _pendingCommands = {};
  final List<_PlaybackWaiter> _playbackWaiters = [];

  InAppWebViewController? _controller;
  WebMessageListener? _messageListener;
  int _nextDocumentGeneration = 0;
  int _nextCommandNumber = 0;
  bool _transportAvailable = false;
  bool _bridgeReady = false;
  bool _controlsAvailable = false;
  bool _isPlaying = false;
  bool _isPageLoading = false;
  bool _isMusicPage = false;
  bool _isRecovering = false;
  StreamNowPlaying? _nowPlaying;
  String? _lastFailure;
  WebUri _restorationUrl = WebUri(_musicHome);
  StreamCapabilityTier _capabilityTier = StreamCapabilityTier.pageOnly;

  InAppWebViewController? get webViewController => _controller;
  StreamCapabilityTier get capabilityTier => _capabilityTier;
  bool get bridgeReady => _bridgeReady;
  bool get controlsAvailable => _controlsAvailable;
  bool get canControlPlayback =>
      _capabilityTier == StreamCapabilityTier.full &&
      _bridgeReady &&
      _controlsAvailable;
  bool get isPlaying => _isPlaying;
  bool get isPageLoading => _isPageLoading;
  bool get isMusicPage => _isMusicPage;
  bool get isRecovering => _isRecovering;
  StreamNowPlaying? get nowPlaying => _nowPlaying;
  String? get lastFailure => _lastFailure;
  WebUri get restorationUrl => _restorationUrl;
  int get documentGeneration => _messageGate.documentGeneration;

  static bool isMusicUrl(WebUri? url) {
    final uri = Uri.tryParse(url?.toString() ?? '');
    return uri != null && uri.scheme == 'https' && uri.host == 'music.youtube.com';
  }

  static bool isGoogleSignInUrl(WebUri? url) {
    final uri = Uri.tryParse(url?.toString() ?? '');
    return uri != null && uri.scheme == 'https' && uri.host == 'accounts.google.com';
  }

  Future<void> attachWebView(InAppWebViewController controller) async {
    _messageListener?.dispose();
    _messageListener = null;
    _controller = controller;
    _isRecovering = false;
    _lastFailure = null;
    _transportAvailable = false;
    _bridgeReady = false;
    _controlsAvailable = false;
    _capabilityTier = StreamCapabilityTier.pageOnly;
    notifyListeners();

    if (defaultTargetPlatform == TargetPlatform.android &&
        !await WebViewFeature.isFeatureSupported(
          WebViewFeature.WEB_MESSAGE_LISTENER,
        )) {
      return;
    }

    final listener = WebMessageListener(
      jsObjectName: _bridgeObjectName,
      allowedOriginRules: const {_musicOrigin},
      onPostMessage: (message, sourceOrigin, isMainFrame, _) {
        _handleBridgeMessage(message?.data, sourceOrigin, isMainFrame);
      },
    );

    try {
      await controller.addWebMessageListener(listener);
      _messageListener = listener;
      _transportAvailable = true;
      notifyListeners();
    } catch (_) {
      listener.dispose();
      _transportAvailable = false;
      _capabilityTier = StreamCapabilityTier.pageOnly;
      notifyListeners();
    }
  }

  void handleNavigationStart(WebUri? url) {
    _isPageLoading = true;
    _lastFailure = null;

    if (isMusicUrl(url)) {
      _isMusicPage = true;
      _restorationUrl = url!;
      _beginDocument();
    } else {
      _isMusicPage = false;
      _beginDocument();
      _disableBridgeForNonMusicPage();
    }
    notifyListeners();
  }

  Future<void> handlePageLoaded(WebUri? url) async {
    _isPageLoading = false;
    if (!isMusicUrl(url)) {
      _isMusicPage = false;
      notifyListeners();
      return;
    }

    _isMusicPage = true;
    _restorationUrl = url!;
    if (documentGeneration == 0) _beginDocument();
    await _installPageAdapter();
    notifyListeners();
  }

  Future<void> handleVisitedHistory(WebUri? url) async {
    if (!isMusicUrl(url)) {
      _isMusicPage = false;
      _beginDocument();
      _disableBridgeForNonMusicPage();
      notifyListeners();
      return;
    }

    _isMusicPage = true;
    _restorationUrl = url!;
    if (documentGeneration == 0) _beginDocument();
    await _installPageAdapter();
  }

  void handlePageLoadError() {
    _isPageLoading = false;
    _bridgeReady = false;
    _controlsAvailable = false;
    _isPlaying = false;
    _capabilityTier = StreamCapabilityTier.unavailable;
    _lastFailure = 'The stream page could not be loaded.';
    _completePendingCommands('The stream page is unavailable.');
    _completePlaybackWaiters(false);
    notifyListeners();
  }

  void handleRendererGone() {
    _controller = null;
    _messageListener?.dispose();
    _messageListener = null;
    _transportAvailable = false;
    _bridgeReady = false;
    _controlsAvailable = false;
    _isPlaying = false;
    _isPageLoading = false;
    _isMusicPage = false;
    _isRecovering = true;
    _capabilityTier = StreamCapabilityTier.unavailable;
    _lastFailure = 'The Android WebView renderer stopped. Recreate the stream page to continue.';
    _beginDocument();
    _completePendingCommands('The stream renderer stopped.');
    _completePlaybackWaiters(false);
    notifyListeners();
  }

  void beginRecovery() {
    _isRecovering = true;
    _lastFailure = null;
    _bridgeReady = false;
    _controlsAvailable = false;
    _capabilityTier = StreamCapabilityTier.unavailable;
    notifyListeners();
  }

  Future<StreamCommandResult> requestPlay() =>
      _dispatchCommand(StreamCommandType.play);

  Future<StreamCommandResult> requestPause() =>
      _dispatchCommand(StreamCommandType.pause);

  /// Used before local playback claims ownership. A pause acknowledgement and
  /// an observed paused state are both required; timeout remains predictable.
  Future<bool> pauseAndWaitForStopped() async {
    if (!_isPlaying) return true;

    final result = await requestPause();
    if (!result.acknowledged) return false;
    if (!_isPlaying) return true;

    final waiter = Completer<bool>();
    _playbackWaiters.add(_PlaybackWaiter(false, waiter));
    return waiter.future.timeout(
      _commandTimeout,
      onTimeout: () {
        _playbackWaiters.removeWhere((entry) => identical(entry.completer, waiter));
        return false;
      },
    );
  }

  void disposeWebViewBridge() {
    _controller = null;
    _messageListener?.dispose();
    _messageListener = null;
    _transportAvailable = false;
    _bridgeReady = false;
    _controlsAvailable = false;
    _completePendingCommands('The stream page was closed.');
    _completePlaybackWaiters(false);
  }

  Future<StreamCommandResult> _dispatchCommand(StreamCommandType type) async {
    final id = 'stream-${++_nextCommandNumber}';
    if (!canControlPlayback || _controller == null) {
      return StreamCommandResult.rejected(
        id,
        'Native stream controls are unavailable for this page.',
      );
    }

    final command = <String, Object>{
      'id': id,
      'type': type.name,
      'documentGeneration': documentGeneration,
    };
    final completer = Completer<StreamCommandResult>();
    _pendingCommands[id] = completer;

    try {
      await _controller!.evaluateJavascript(
        source:
            'window.__myMusicStreamAdapter?.command(${jsonEncode(command)});',
      );
    } catch (_) {
      _pendingCommands.remove(id);
      return StreamCommandResult.rejected(id, 'The stream page is no longer available.');
    }

    return completer.future.timeout(
      _commandTimeout,
      onTimeout: () {
        _pendingCommands.remove(id);
        return StreamCommandResult.timedOut(id);
      },
    );
  }

  void _handleBridgeMessage(
    dynamic rawData,
    WebUri? sourceOrigin,
    bool isMainFrame,
  ) {
    if (!isMainFrame || rawData is! String || !_isTrustedOrigin(sourceOrigin)) {
      return;
    }

    final message = StreamBridgeMessage.tryParse(rawData);
    if (message == null || !_messageGate.accepts(message)) return;

    switch (message.type) {
      case 'ready':
        _bridgeReady = true;
        _isRecovering = false;
        _lastFailure = null;
        _applyCapabilities(message.payload);
        break;
      case 'capabilities':
        _applyCapabilities(message.payload);
        break;
      case 'playbackState':
        final state = message.payload['state'];
        if (state is! String) return;
        _setPlaybackState(state == 'playing');
        break;
      case 'metadata':
        _setNowPlaying(message.payload);
        break;
      case 'commandAck':
        _resolveCommand(message.payload);
        break;
      default:
        return;
    }

    notifyListeners();
  }

  void _applyCapabilities(Map<String, dynamic> payload) {
    final canControl = payload['canControl'];
    _controlsAvailable = canControl is bool && canControl;
    _capabilityTier = _bridgeReady && _controlsAvailable
        ? StreamCapabilityTier.full
        : StreamCapabilityTier.pageOnly;
  }

  void _setPlaybackState(bool isPlaying) {
    if (_isPlaying == isPlaying) return;
    _isPlaying = isPlaying;
    _completeMatchingPlaybackWaiters(isPlaying);
  }

  void _setNowPlaying(Map<String, dynamic> payload) {
    final title = payload['title'];
    final artist = payload['artist'];
    final artUrl = payload['artUrl'];
    if (title is! String || artist is! String || title.trim().isEmpty) return;

    final value = StreamNowPlaying(
      title: title.trim(),
      artist: artist.trim(),
      artUrl: artUrl is String && artUrl.isNotEmpty ? artUrl : null,
    );
    if (_nowPlaying == value) return;
    _nowPlaying = value;
  }

  void _resolveCommand(Map<String, dynamic> payload) {
    final id = payload['id'];
    final success = payload['success'];
    if (id is! String || success is! bool) return;

    final completer = _pendingCommands.remove(id);
    if (completer == null || completer.isCompleted) return;
    if (success) {
      completer.complete(StreamCommandResult.acknowledged(id));
    } else {
      final reason = payload['reason'];
      completer.complete(
        StreamCommandResult.rejected(
          id,
          reason is String && reason.isNotEmpty
              ? reason
              : 'The stream page rejected the command.',
        ),
      );
    }
  }

  Future<void> _installPageAdapter() async {
    if (!_transportAvailable || _controller == null || documentGeneration == 0) {
      return;
    }

    try {
      await _controller!.evaluateJavascript(
        source: _pageAdapterScript(documentGeneration),
      );
    } catch (_) {
      _bridgeReady = false;
      _controlsAvailable = false;
      _capabilityTier = StreamCapabilityTier.pageOnly;
      notifyListeners();
    }
  }

  void _beginDocument() {
    _messageGate.beginDocument(++_nextDocumentGeneration);
    _bridgeReady = false;
    _controlsAvailable = false;
    _isPlaying = false;
    _capabilityTier = StreamCapabilityTier.pageOnly;
    _completePendingCommands('The stream document changed.');
    _completePlaybackWaiters(false);
  }

  void _disableBridgeForNonMusicPage() {
    _bridgeReady = false;
    _controlsAvailable = false;
    _isPlaying = false;
    _capabilityTier = StreamCapabilityTier.pageOnly;
    _completePendingCommands('Native controls are disabled on this page.');
    _completePlaybackWaiters(false);
  }

  bool _isTrustedOrigin(WebUri? origin) {
    final uri = Uri.tryParse(origin?.toString() ?? '');
    return uri?.scheme == 'https' && uri?.host == 'music.youtube.com';
  }

  void _completePendingCommands(String reason) {
    final pending = Map<String, Completer<StreamCommandResult>>.from(
      _pendingCommands,
    );
    _pendingCommands.clear();
    for (final entry in pending.entries) {
      if (!entry.value.isCompleted) {
        entry.value.complete(StreamCommandResult.rejected(entry.key, reason));
      }
    }
  }

  void _completeMatchingPlaybackWaiters(bool isPlaying) {
    final matching = _playbackWaiters
        .where((entry) => entry.expectedPlaying == isPlaying)
        .toList();
    _playbackWaiters.removeWhere((entry) => matching.contains(entry));
    for (final entry in matching) {
      if (!entry.completer.isCompleted) entry.completer.complete(true);
    }
  }

  void _completePlaybackWaiters(bool result) {
    final waiters = List<_PlaybackWaiter>.from(_playbackWaiters);
    _playbackWaiters.clear();
    for (final entry in waiters) {
      if (!entry.completer.isCompleted) entry.completer.complete(result);
    }
  }

  @override
  void dispose() {
    disposeWebViewBridge();
    super.dispose();
  }

  static String _pageAdapterScript(int generation) => '''
(function() {
  const generation = $generation;
  const bridge = window.$_bridgeObjectName;
  if (!bridge || typeof bridge.postMessage !== 'function') return;
  if (window.__myMusicStreamAdapter?.generation === generation) return;

  let sequence = 0;
  let currentPlayer = null;
  let framePending = false;
  let debounceTimer = null;
  let lastState = null;
  let lastMetadata = '';

  function post(type, payload) {
    bridge.postMessage(JSON.stringify({
      version: ${StreamBridgeMessage.protocolVersion},
      documentGeneration: generation,
      sequenceNumber: ++sequence,
      type: type,
      payload: payload || {}
    }));
  }

  function findPlayer() {
    return document.querySelector('video');
  }

  function readMetadata() {
    const title = document.querySelector(
      'yt-formatted-string.title.style-scope.ytmusic-player-bar'
    )?.textContent?.trim() || '';
    const artist = document.querySelector(
      'span.subtitle.style-scope.ytmusic-player-bar'
    )?.textContent?.trim() || '';
    const image = document.querySelector('ytmusic-player-bar img.thumbnail') ||
      document.querySelector('#song-image yt-img-shadow img') ||
      document.querySelector('ytmusic-player-bar yt-img-shadow img');
    const artUrl = image?.src && !image.src.startsWith('data:')
      ? image.src.replace(/=w\\d+-h\\d+/, '=w544-h544')
      : '';
    return { title: title, artist: artist, artUrl: artUrl };
  }

  function emitSnapshot() {
    const player = currentPlayer;
    const state = player && !player.paused && !player.ended ? 'playing' : 'paused';
    if (state !== lastState) {
      lastState = state;
      post('playbackState', { state: state });
    }

    const metadata = readMetadata();
    const metadataKey = JSON.stringify(metadata);
    if (metadata.title && metadataKey !== lastMetadata) {
      lastMetadata = metadataKey;
      post('metadata', metadata);
    }
  }

  function scheduleSnapshot() {
    if (framePending) return;
    framePending = true;
    requestAnimationFrame(function() {
      framePending = false;
      clearTimeout(debounceTimer);
      debounceTimer = setTimeout(emitSnapshot, 80);
    });
  }

  function attachPlayer() {
    const player = findPlayer();
    if (player === currentPlayer) return;
    currentPlayer = player;
    if (!player) {
      post('capabilities', { canControl: false });
      scheduleSnapshot();
      return;
    }

    ['play', 'pause', 'ended', 'loadedmetadata', 'durationchange'].forEach(function(eventName) {
      player.addEventListener(eventName, scheduleSnapshot);
    });
    post('capabilities', { canControl: true });
    scheduleSnapshot();
  }

  const observer = new MutationObserver(function() {
    attachPlayer();
    scheduleSnapshot();
  });
  observer.observe(document.documentElement, { childList: true, subtree: true });

  window.__myMusicStreamAdapter = {
    generation: generation,
    command: function(command) {
      if (!command || command.documentGeneration !== generation || !command.id) return;
      attachPlayer();
      const player = currentPlayer;
      if (!player) {
        post('commandAck', { id: command.id, success: false, reason: 'No media player is available.' });
        return;
      }
      if (command.type === 'play') {
        Promise.resolve(player.play()).then(function() {
          post('commandAck', { id: command.id, success: true });
          scheduleSnapshot();
        }).catch(function() {
          post('commandAck', { id: command.id, success: false, reason: 'Playback requires a page gesture.' });
        });
      } else if (command.type === 'pause') {
        player.pause();
        post('commandAck', { id: command.id, success: true });
        scheduleSnapshot();
      } else {
        post('commandAck', { id: command.id, success: false, reason: 'Unsupported command.' });
      }
    }
  };

  attachPlayer();
  post('ready', { canControl: !!currentPlayer });
  scheduleSnapshot();
})();
''';
}

class _PlaybackWaiter {
  final bool expectedPlaying;
  final Completer<bool> completer;

  const _PlaybackWaiter(this.expectedPlaying, this.completer);
}
