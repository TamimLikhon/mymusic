import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../services/ad_block/ad_block_service.dart';
import '../../services/stream/stream_session_controller.dart';

/// The controlled YouTube Music session.
class WebStreamPage extends StatefulWidget {
  const WebStreamPage({super.key});

  @override
  State<WebStreamPage> createState() => _WebStreamPageState();
}

class _WebStreamPageState extends State<WebStreamPage> {
  int _webViewGeneration = 0;

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
            },
            onLoadStop: (controller, url) async {
              await streamSession.handlePageLoaded(url);
              // Inject full ad-block: CSS cosmetics + JS scriptlets
              final script = AdBlockService.instance.fullScript;
              if (script.isNotEmpty) {
                await controller.evaluateJavascript(source: script);
              }
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
            },
            onRenderProcessGone: (_, _) {
              streamSession.handleRendererGone();
              if (mounted) {
                setState(() {
                  _webViewGeneration++;
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
    );
  }
}
