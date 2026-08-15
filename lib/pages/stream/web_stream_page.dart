import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../services/auth_service.dart';
import '../../services/web_audio_service.dart';
import 'youtube_login_page.dart';

/// The "Stream" tab.
///
/// Contains a persistent [InAppWebView] that loads music.youtube.com.
/// The WebView is kept alive at all times (never disposed) via the [Offstage]
/// wrapper in AppShell, so music keeps playing when the user switches tabs.
class WebStreamPage extends StatefulWidget {
  const WebStreamPage({super.key});

  @override
  State<WebStreamPage> createState() => _WebStreamPageState();
}

class _WebStreamPageState extends State<WebStreamPage> {
  InAppWebViewController? _controller;
  final _authService = AuthService();
  bool _isLoading = true;
  bool _hasError = false;
  bool _isLoggedIn = false;

  // ── JavaScript injected after every page load ────────────────────────────

  /// Watches the YouTube Music player bar DOM for title/artist changes and
  /// calls our Flutter handler with the new values.
  static const _nowPlayingObserverJs = '''
(function() {
  if (window._myMusicObserverActive) return;
  window._myMusicObserverActive = true;

  function getTitle() {
    const el = document.querySelector(
      'yt-formatted-string.title.style-scope.ytmusic-player-bar'
    );
    return el ? el.textContent.trim() : '';
  }

  function getArtist() {
    const el = document.querySelector(
      'span.subtitle.style-scope.ytmusic-player-bar'
    );
    return el ? el.textContent.trim() : '';
  }

  function getPlayState() {
    const btn = document.querySelector('.play-pause-button');
    if (!btn) return null;
    const label = btn.getAttribute('aria-label') || '';
    return label.toLowerCase().includes('pause');  // true = playing
  }

  let lastTitle = '';
  let lastArtist = '';

  function notify() {
    const t = getTitle();
    const a = getArtist();
    if (t !== lastTitle || a !== lastArtist) {
      lastTitle = t;
      lastArtist = a;
      window.flutter_inappwebview.callHandler('onNowPlayingChanged', t, a);
    }
  }

  // Poll every 1 second instead of using a heavy MutationObserver
  // that runs on every DOM change in YouTube Music.
  setInterval(notify, 1000);

  // Fire once immediately in case the page already has a song loaded.
  notify();
})();
''';

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _checkLoginState();
  }

  Future<void> _checkLoginState() async {
    final loggedIn = await _authService.isLoggedIn;
    if (mounted) setState(() => _isLoggedIn = loggedIn);
  }

  Future<void> _openLoginPage() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const YoutubeLoginPage()),
    );
    if (result == true && mounted) {
      setState(() => _isLoggedIn = true);
      // Re-inject the new cookies into the running WebView immediately.
      if (_controller != null) {
        await context.read<WebAudioService>().injectCookies(_controller!);
        await _controller!.reload();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Signed in to YouTube!'),
            backgroundColor: Color(0xFF6C63FF),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _signOut() async {
    await _authService.clearCookies();
    // Clear WebView cookies too
    await CookieManager.instance().deleteAllCookies();
    if (mounted) {
      setState(() => _isLoggedIn = false);
      _controller?.loadUrl(
        urlRequest: URLRequest(url: WebUri('https://music.youtube.com')),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signed out of YouTube.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _clearCache() async {
    await CookieManager.instance().deleteAllCookies();
    await _controller?.clearCache();
    await WebStorageManager.instance().deleteAllData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cache & cookies cleared. Reloading...'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _controller?.reload();
    }
  }

  Future<void> _injectObserver() async {
    if (_controller == null) return;
    await _controller!.evaluateJavascript(source: _nowPlayingObserverJs);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final webAudioService = context.read<WebAudioService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header: Sign In / Account row ──────────────────────────────
            _buildHeader(),

            // ── WebView ────────────────────────────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  InAppWebView(
                    initialUrlRequest: URLRequest(
                      url: WebUri('https://music.youtube.com'),
                    ),
                    initialSettings: InAppWebViewSettings(
                      userAgent:
                          'Mozilla/5.0 (Linux; Android 13; Pixel 7) '
                          'AppleWebKit/537.36 (KHTML, like Gecko) '
                          'Chrome/125.0.0.0 Mobile Safari/537.36',
                      javaScriptEnabled: true,
                      domStorageEnabled: true,
                      databaseEnabled: true,
                      cacheEnabled: true,
                      clearCache: false,
                      allowsInlineMediaPlayback: true,
                      mediaPlaybackRequiresUserGesture: false,
                      allowBackgroundAudioPlaying: true,
                      // Suppress mixed-content warnings
                      mixedContentMode:
                          MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                    ),
                    onWebViewCreated: (controller) async {
                      _controller = controller;

                      // 1. Inject cookies BEFORE the page loads so YouTube
                      //    sees the session on the very first request.
                      await webAudioService.injectCookies(controller);

                      // 2. Register the JS → Dart handler for now-playing.
                      controller.addJavaScriptHandler(
                        handlerName: 'onNowPlayingChanged',
                        callback: (args) {
                          if (args.length < 2) return;
                          final title = (args[0] as String?) ?? '';
                          final artist = (args[1] as String?) ?? '';
                          webAudioService.updateNowPlaying(
                            title.isNotEmpty
                                ? WebNowPlaying(title: title, artist: artist)
                                : null,
                          );
                        },
                      );
                    },
                    onLoadStart: (controller, url) {
                      if (mounted) {
                        setState(() {
                          _isLoading = true;
                          _hasError = false;
                        });
                      }
                    },
                    onLoadStop: (controller, url) async {
                      if (mounted) {
                        setState(() => _isLoading = false);
                      }
                      // Inject the MutationObserver on every successful load.
                      await _injectObserver();
                    },
                    onReceivedError: (controller, request, error) {
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                          _hasError = true;
                        });
                      }
                    },
                    onConsoleMessage: (controller, msg) {
                      if (kDebugMode) {
                        debugPrint('[WebView] ${msg.message}');
                      }
                    },
                  ),

                  // Loading bar
                  if (_isLoading)
                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.transparent,
                        color: Color(0xFF6C63FF),
                        minHeight: 3,
                      ),
                    ),

                  // Error overlay with reload button
                  if (_hasError) _buildErrorOverlay(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.surfaceBorder, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Brand icon
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF3ECFCF)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const HugeIcon(
              icon: HugeIcons.strokeRoundedRadio,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'YouTube Music',
            style: AppTypography.heading.copyWith(fontSize: 20),
          ),
          const Spacer(),

          // Sign-In / Account button
          if (_isLoggedIn)
            PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF6C63FF),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFF6C63FF),
                  size: 18,
                ),
              ),
              color: AppColors.surfaceHigh,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'signout',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.logout_rounded,
                        color: AppColors.textPrimary,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text('Sign Out', style: AppTypography.bodyMedium),
                    ],
                  ),
                ),
              ],
              onSelected: (v) {
                if (v == 'signout') _signOut();
              },
            )
          else
            GestureDetector(
              onTap: _openLoginPage,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF3ECFCF)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.login_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Sign In',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Options Menu (Reload, Clear Cache)
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: AppColors.textSecondary,
              size: 22,
            ),
            color: AppColors.surfaceHigh,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'reload',
                child: Row(
                  children: [
                    const Icon(
                      Icons.refresh_rounded,
                      color: AppColors.textPrimary,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text('Reload Page', style: AppTypography.bodyMedium),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clearcache',
                child: Row(
                  children: [
                    const Icon(
                      Icons.cleaning_services_rounded,
                      color: AppColors.textPrimary,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text('Clear Cache & Cookies', style: AppTypography.bodyMedium),
                  ],
                ),
              ),
            ],
            onSelected: (v) {
              if (v == 'reload') _controller?.reload();
              if (v == 'clearcache') _clearCache();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorOverlay() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: AppColors.background.withValues(alpha: 0.85),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  color: AppColors.textSecondary,
                  size: 56,
                ),
                const SizedBox(height: 16),
                Text(
                  'Could not load YouTube Music',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Check your internet connection',
                  style: AppTypography.caption,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    setState(() => _hasError = false);
                    _controller?.reload();
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Retry'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
