import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../services/playback_coordinator.dart';
import '../../services/stream/stream_session_controller.dart';

/// The controlled YouTube Music session. The controller is the sole bridge
/// owner; this widget only owns the native WebView lifetime and recovery UI.
class WebStreamPage extends StatefulWidget {
  const WebStreamPage({super.key});

  @override
  State<WebStreamPage> createState() => _WebStreamPageState();
}

class _WebStreamPageState extends State<WebStreamPage> {
  int _webViewGeneration = 0;
  bool _isLoading = true;

  void _recreateWebView(StreamSessionController session) {
    session.beginRecovery();
    setState(() {
      _webViewGeneration++;
      _isLoading = true;
    });
  }

  Future<NavigationActionPolicy> _handleNavigation(
    NavigationAction action,
  ) async {
    final url = action.request.url;
    if (StreamSessionController.isMusicUrl(url) ||
        StreamSessionController.isGoogleSignInUrl(url)) {
      return NavigationActionPolicy.ALLOW;
    }

    // Keep external destinations out of the authenticated stream WebView.
    if (action.isForMainFrame && url != null) {
      unawaited(
        launchUrl(
          Uri.parse(url.toString()),
          mode: LaunchMode.externalApplication,
        ),
      );
    }
    return NavigationActionPolicy.CANCEL;
  }

  @override
  Widget build(BuildContext context) {
    final streamSession = context.watch<StreamSessionController>();
    final coordinator = context.read<PlaybackCoordinator>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: KeyedSubtree(
                key: ValueKey(_webViewGeneration),
                child: InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: streamSession.restorationUrl,
                  ),
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  },
                  initialSettings: InAppWebViewSettings(
                    javaScriptEnabled: true,
                    domStorageEnabled: true,
                    databaseEnabled: true,
                    cacheEnabled: true,
                    allowsInlineMediaPlayback: true,
                    allowBackgroundAudioPlaying: true,
                    mediaPlaybackRequiresUserGesture: true,
                    mixedContentMode: MixedContentMode.MIXED_CONTENT_NEVER_ALLOW,
                    useShouldOverrideUrlLoading: true,
                    hardwareAcceleration: true,
                    supportZoom: false,
                    overScrollMode: OverScrollMode.NEVER,
                  ),
                  onWebViewCreated: (controller) async {
                    await streamSession.attachWebView(controller);
                  },
                  onLoadStart: (_, url) {
                    streamSession.handleNavigationStart(url);
                    if (mounted) setState(() => _isLoading = true);
                  },
                  onLoadStop: (_, url) async {
                    await streamSession.handlePageLoaded(url);
                    if (mounted) setState(() => _isLoading = false);
                  },
                  onUpdateVisitedHistory: (_, url, _) async {
                    await streamSession.handleVisitedHistory(url);
                  },
                  onReceivedError: (_, _, _) {
                    streamSession.handlePageLoadError();
                    if (mounted) setState(() => _isLoading = false);
                  },
                  onRenderProcessGone: (_, _) {
                    streamSession.handleRendererGone();
                    if (mounted) {
                      setState(() {
                        _webViewGeneration++;
                        _isLoading = true;
                      });
                    }
                  },
                  shouldOverrideUrlLoading: (_, action) =>
                      _handleNavigation(action),
                ),
              ),
            ),
            if (_isLoading)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(minHeight: 2),
              ),
            Positioned(
              right: 12,
              bottom: 12,
              child: _StreamStatusCard(
                session: streamSession,
                coordinator: coordinator,
                onRetry: () => _recreateWebView(streamSession),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreamStatusCard extends StatelessWidget {
  final StreamSessionController session;
  final PlaybackCoordinator coordinator;
  final VoidCallback onRetry;

  const _StreamStatusCard({
    required this.session,
    required this.coordinator,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final failed = session.capabilityTier == StreamCapabilityTier.unavailable;
    final pageOnly = session.capabilityTier == StreamCapabilityTier.pageOnly;
    final nowPlaying = session.nowPlaying;

    return Material(
      color: Colors.black87,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (failed)
              IconButton(
                tooltip: 'Recreate stream page',
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, color: Colors.white),
              )
            else if (!pageOnly)
              IconButton(
                tooltip: session.isPlaying ? 'Pause stream' : 'Play stream',
                onPressed: coordinator.toggleStreamPlayback,
                icon: Icon(
                  session.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
              ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 180),
              child: Text(
                failed
                    ? (session.lastFailure ?? 'Stream unavailable. Retry.')
                    : pageOnly
                    ? 'Native stream controls unavailable'
                    : nowPlaying?.title ?? 'Stream controls ready',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
