import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../services/ad_block/ad_block_service.dart';
import '../../services/stream/stream_session_controller.dart';

/// The controlled YouTube Music session with glassmorphic status HUD overlay.
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
    // Non-main-frame requests (iframes, auth popups, subresources) must be allowed
    if (!action.isForMainFrame) {
      return NavigationActionPolicy.ALLOW;
    }

    final url = action.request.url;
    if (StreamSessionController.isMusicUrl(url) ||
        StreamSessionController.isGoogleSignInUrl(url)) {
      return NavigationActionPolicy.ALLOW;
    }

    // Keep external destinations out of the authenticated stream WebView.
    if (url != null) {
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
                    mixedContentMode:
                        MixedContentMode.MIXED_CONTENT_NEVER_ALLOW,
                    useShouldOverrideUrlLoading: true,
                    useShouldInterceptRequest: true,
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
                  onLoadStop: (controller, url) async {
                    await streamSession.handlePageLoaded(url);
                    // Inject full ad-block: CSS cosmetics + JS scriptlets
                    final script = AdBlockService.instance.fullScript;
                    if (script.isNotEmpty) {
                      await controller.evaluateJavascript(source: script);
                    }
                    if (mounted) setState(() => _isLoading = false);
                  },
                  onUpdateVisitedHistory: (controller, url, _) async {
                    await streamSession.handleVisitedHistory(url);
                    // Re-inject on SPA navigations (YouTube Music is a SPA)
                    final script = AdBlockService.instance.fullScript;
                    if (script.isNotEmpty) {
                      await controller.evaluateJavascript(source: script);
                    }
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
                  shouldInterceptRequest: (_, request) async {
                    final url = request.url.toString();
                    if (AdBlockService.instance.shouldBlock(url)) {
                      return WebResourceResponse(
                        contentType: 'text/plain',
                        statusCode: 204,
                        data: Uint8List(0),
                      );
                    }
                    return null;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: unused_element
class _StreamStatusCard extends StatelessWidget {
  final StreamSessionController session;
  final VoidCallback onRetry;

  const _StreamStatusCard({required this.session, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final failed = session.capabilityTier == StreamCapabilityTier.unavailable;
    final pageOnly = session.capabilityTier == StreamCapabilityTier.pageOnly;
    final nowPlaying = session.nowPlaying;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: failed
                  ? AppColors.secondary.withValues(alpha: 0.5)
                  : AppColors.glassBorderStrong,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (failed)
                GestureDetector(
                  onTap: onRetry,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowReloadHorizontal,
                        color: AppColors.secondary,
                        size: 16,
                      ),
                    ),
                  ),
                )
              else if (!pageOnly)
                GestureDetector(
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Center(
                      child: HugeIcon(
                        icon: session.isPlaying
                            ? HugeIcons.strokeRoundedPause
                            : HugeIcons.strokeRoundedPlay,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 10),
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
                  style: AppTypography.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
