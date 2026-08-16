import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../services/web_audio_service.dart';
import '../../services/ad_block/ad_block_service.dart';

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
  bool _isLoading = true;
  bool _hasError = false;

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

  static const _adBlockCosmeticJs = '''
(function() {
  if (window._myMusicAdBlockActive) return;
  window._myMusicAdBlockActive = true;

  const CSS_RULES = `
    .ad-showing .video-ads,
    .ytp-ad-overlay-container,
    .ytp-ad-text-overlay,
    .ytp-ad-skip-button-container,
    .ytp-ad-module,
    .ytp-ad-player-overlay,
    ytmusic-shelf-renderer[is-music-shelf][role="main"] [is-carousel-item],
    ytd-promoted-sparkles-web-renderer,
    ytd-display-ad-renderer,
    ytd-banner-promo-renderer,
    ytd-action-companion-ad-renderer,
    ytmusic-responsive-list-item-renderer[is-music-premium],
    [component-style="MUSIC_RESPONSIVE_LIST_ITEM_STYLE_COMPACT_WITH_MENU"][is-premium-only],
    ytmusic-mealbar-promo-renderer,
    [dialog-style="MUSIC_IMMERSIVE_DIALOG_STYLE_DEFAULT"],
    ytd-masthead-ad-renderer {
      display: none !important;
      visibility: hidden !important;
      height: 0 !important;
      pointer-events: none !important;
    }
  `;

  const style = document.createElement('style');
  style.id = 'mymusic-adblock-styles';
  style.textContent = CSS_RULES;
  (document.head || document.documentElement).appendChild(style);

  function skipAd() {
    const skipBtn = document.querySelector('.ytp-ad-skip-button, .ytp-skip-ad-button');
    if (skipBtn) {
      skipBtn.click();
      window.flutter_inappwebview.callHandler('onAdSkipped', 'video_ad_skipped');
      return;
    }
    const video = document.querySelector('video');
    if (video && video.duration && !isNaN(video.duration)) {
      const adShowing = document.querySelector('.ad-showing');
      if (adShowing) {
        video.currentTime = video.duration;
        window.flutter_inappwebview.callHandler('onAdSkipped', 'nonskippable_ad_skipped');
      }
    }
  }

  const adObserver = new MutationObserver(() => {
    const adShowing = document.querySelector('.ad-showing, .ytp-ad-player-overlay');
    if (adShowing) skipAd();
  });

  adObserver.observe(document.documentElement, {
    childList: true,
    subtree: true,
    attributes: true,
    attributeFilter: ['class'],
  });

  skipAd();
})();
''';

  static const _autoPlayInjectorJs = '''
(function() {
  if (window._myMusicAutoPlayActive) return;
  window._myMusicAutoPlayActive = true;

  // ── 1. AudioContext unlock (Brave's technique) ──────────────────────────
  // Android WebView blocks autoplay until an AudioContext has been
  // "resumed" by a real user gesture. We unlock it on the first touch.
  let audioContextUnlocked = false;

  function unlockAudioContext() {
    if (audioContextUnlocked) return;
    try {
      const ctx = new (window.AudioContext || window.webkitAudioContext)();
      const buf = ctx.createBuffer(1, 1, 22050);
      const src = ctx.createBufferSource();
      src.buffer = buf;
      src.connect(ctx.destination);
      src.start(0);
      ctx.resume().then(() => {
        audioContextUnlocked = true;
      });
    } catch (e) {}
  }

  // Unlock on any user touch — fires on the very first tap (song click)
  document.addEventListener('touchstart', unlockAudioContext, { once: true, passive: true });
  document.addEventListener('click',      unlockAudioContext, { once: true });

  // ── 2. Play button auto-clicker ──────────────────────────────────────────
  // When a song is selected, YouTube Music loads it but may not auto-play.
  // We watch for title changes and programmatically click Play.

  function clickPlay() {
    // Primary selector: the main player bar play/pause button
    const btn = document.querySelector(
      'ytmusic-player-bar .play-pause-button, ' +
      '#play-pause-button, ' +
      '.ytmusic-player-bar tp-yt-paper-icon-button[aria-label*="Play"]'
    );
    if (btn) {
      const ariaLabel = btn.getAttribute('aria-label') || '';
      // Only click if currently paused (aria-label contains "Play", not "Pause")
      const isPaused = ariaLabel.toLowerCase().includes('play') &&
                       !ariaLabel.toLowerCase().includes('pause');
      if (isPaused) {
        btn.click();
        return true;
      }
    }
    return false;
  }

  function ensurePlayingAfterSongChange() {
    // Try immediately, then retry with backoff in case DOM is still updating
    if (!clickPlay()) {
      setTimeout(() => {
        if (!clickPlay()) {
          setTimeout(clickPlay, 400);
        }
      }, 250);
    }
  }

  // ── 3. video.play() intercept — catch and retry (Brave's exact technique)
  const originalPlay = HTMLMediaElement.prototype.play;
  HTMLMediaElement.prototype.play = function() {
    const result = originalPlay.apply(this, arguments);
    if (result && typeof result.then === 'function') {
      result.catch((err) => {
        if (err && err.name === 'NotAllowedError') {
          // Autoplay was blocked — schedule a retry via button click
          setTimeout(ensurePlayingAfterSongChange, 200);
        }
      });
    }
    return result;
  };

  // ── 4. MutationObserver on title element — detect song changes ───────────
  const titleEl = () => document.querySelector(
    'yt-formatted-string.title.style-scope.ytmusic-player-bar'
  );

  let lastSeenTitle = '';

  function checkTitleChange() {
    const el = titleEl();
    if (!el) return;
    const title = el.textContent.trim();
    if (title && title !== lastSeenTitle) {
      lastSeenTitle = title;
      // New song detected — ensure it plays
      ensurePlayingAfterSongChange();
    }
  }

  // Poll aligned with the existing now-playing observer (same 1s interval)
  setInterval(checkTitleChange, 500); // 500ms for snappier response

})();
''';

  static const _uiCleanupCosmeticJs = '''
(function() {
  if (window._myMusicUiCleanupActive) return;
  window._myMusicUiCleanupActive = true;

  const CSS = `
    /* Hide YouTube Music logo in top bar (all variations) */
    ytmusic-logo,
    .ytmusic-nav-bar-logo,
    a.ytmusic-nav-bar-logo,
    a#logo,
    #logo,
    .header-logo,
    ytm-mobile-topbar-renderer .header-logo,
    ytm-mobile-topbar-renderer ytm-logo,
    ytmusic-nav-bar #left-content ytmusic-logo,
    ytmusic-nav-bar #left-content a#logo,
    ytmusic-nav-bar #left-content .ytmusic-logo,
    a.yt-simple-endpoint.style-scope.ytmusic-logo,
    
    /* Hide YouTube Music branding / logo in sidebar / guide drawer */
    ytmusic-guide-renderer #header,
    ytmusic-guide-renderer ytmusic-logo,
    ytmusic-guide-renderer .logo,
    ytm-navigation-drawer-header-renderer,
    tp-yt-app-drawer #header,
    tp-yt-app-drawer ytmusic-logo,
    ytmusic-guide-entry-renderer[is-primary] ytmusic-logo,
    ytmusic-guide-entry-renderer a[href*="premium"],
    ytmusic-guide-entry-renderer[is-music-premium],
    ytmusic-mealbar-promo-renderer {
      display: none !important;
      visibility: hidden !important;
      opacity: 0 !important;
      pointer-events: none !important;
      width: 0 !important;
      max-width: 0 !important;
      height: 0 !important;
      overflow: hidden !important;
    }

    /* Keep left content neat so hamburger is still aligned */
    ytmusic-nav-bar #left-content {
      min-width: 48px !important;
    }
  `;

  const style = document.createElement('style');
  style.id = 'mymusic-uicleanup-styles';
  style.textContent = CSS;
  (document.head || document.documentElement).appendChild(style);
})();
''';

  @override
  void initState() {
    super.initState();
  }

  Future<void> _clearCache() async {
    await CookieManager.instance().deleteAllCookies();
    // ignore: deprecated_member_use
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

  Future<void> _injectScripts() async {
    if (_controller == null) return;
    await _controller!.evaluateJavascript(source: _nowPlayingObserverJs);
    await _controller!.evaluateJavascript(source: _autoPlayInjectorJs);
    await _controller!.evaluateJavascript(source: _uiCleanupCosmeticJs);
    // ignore: use_build_context_synchronously
    final adBlock = context.read<AdBlockService>();
    if (adBlock.isEnabled) {
      await _controller!.evaluateJavascript(source: _adBlockCosmeticJs);
    }
  }

  @override
  Widget build(BuildContext context) {
    final webAudioService = context.read<WebAudioService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Full-screen embedded WebView
            Positioned.fill(
              child: InAppWebView(
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
                  mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                  hardwareAcceleration: true,
                  useWideViewPort: true,
                  supportZoom: false,
                  overScrollMode: OverScrollMode.NEVER,
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

                      // Dart-side failsafe: trigger play from Flutter side
                      Future.delayed(const Duration(milliseconds: 600), () {
                        _controller?.evaluateJavascript(
                          source: '''
                            (function() {
                              const video = document.querySelector('video');
                              if (video && video.paused && !video.ended) {
                                video.play().catch(() => {});
                              }
                            })();
                          ''',
                        );
                      });
                    },
                  );

                  // 3. Register ad skipped handler
                  controller.addJavaScriptHandler(
                    handlerName: 'onAdSkipped',
                    callback: (args) {
                      final reason = args.isNotEmpty
                          ? args[0] as String
                          : 'unknown';
                      debugPrint('[AdBlock] Ad skipped via JS: $reason');
                      context.read<AdBlockService>().recordSkippedAd();
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
                  // Inject the scripts on every successful load.
                  await _injectScripts();
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
                shouldOverrideUrlLoading: (controller, action) async {
                  final url = action.request.url?.toString() ?? '';
                  final adBlock = context.read<AdBlockService>();
                  if (adBlock.shouldBlock(url)) {
                    debugPrint('[AdBlock] BLOCKED (nav): $url');
                    return NavigationActionPolicy.CANCEL;
                  }
                  return NavigationActionPolicy.ALLOW;
                },
                shouldInterceptRequest: (controller, request) async {
                  final url = request.url.toString();
                  final adBlock = context.read<AdBlockService>();
                  if (adBlock.shouldBlock(url)) {
                    debugPrint('[AdBlock] BLOCKED (resource): $url');
                    return WebResourceResponse(
                      contentType: 'text/plain',
                      statusCode: 200,
                      data: Uint8List(0),
                    );
                  }
                  return null;
                },
              ),
            ),

            // Shield badge embedded right after the hamburger menu (top left)
            Positioned(top: 15, left: 65, child: _buildShieldWidget()),

            // Loading bar
            if (_isLoading)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  color: Color.fromARGB(255, 247, 7, 7),
                  minHeight: 2.5,
                ),
              ),

            // Error overlay with reload button
            if (_hasError) _buildErrorOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildShieldWidget() {
    return Consumer<AdBlockService>(
      builder: (context, adBlock, _) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              _controller?.evaluateJavascript(
                source:
                    "if (document.activeElement) document.activeElement.blur();",
              );
              _showAdBlockStats(context, adBlock);
            },
            onLongPress: () {
              adBlock.toggle();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    adBlock.isEnabled
                        ? '🛡️ Ad Blocker ON'
                        : '⚠️ Ad Blocker OFF',
                  ),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: adBlock.isEnabled
                      ? const Color.fromARGB(255, 102, 255, 0)
                      : Colors.grey[850],
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    adBlock.isEnabled
                        ? Icons.shield_rounded
                        : Icons.shield_outlined,
                    color: adBlock.isEnabled
                        ? const Color.fromARGB(255, 102, 255, 0)
                        : const Color.fromARGB(255, 255, 255, 255),
                    size: 23,
                  ),
                  if (adBlock.blockedCount > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(
                          255,
                          102,
                          255,
                          0,
                        ).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${adBlock.blockedCount}',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 102, 255, 0),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAdBlockStats(BuildContext context, AdBlockService adBlock) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceHigh,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return Consumer<AdBlockService>(
          builder: (context, adBlock, _) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 102, 255, 0),
                                Color.fromARGB(255, 10, 0, 0),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.shield_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ads Shield & Controls',
                                style: AppTypography.heading.copyWith(
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                adBlock.isEnabled
                                    ? 'Protection is actively blocking ads'
                                    : 'Protection is currently paused',
                                style: AppTypography.caption.copyWith(
                                  color: adBlock.isEnabled
                                      ? const Color.fromARGB(255, 102, 255, 0)
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: adBlock.isEnabled,
                          onChanged: (val) {
                            adBlock.toggle();
                          },
                          activeThumbColor: const Color.fromARGB(
                            255,
                            102,
                            255,
                            0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Stats Cards Row
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.surfaceBorder,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${adBlock.blockedCount}',
                                  style: AppTypography.heading.copyWith(
                                    fontSize: 24,
                                    color: const Color.fromARGB(
                                      255,
                                      102,
                                      255,
                                      0,
                                    ),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Requests Blocked',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.surfaceBorder,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${adBlock.skippedAdsCount}',
                                  style: AppTypography.heading.copyWith(
                                    fontSize: 24,
                                    color: const Color.fromARGB(
                                      255,
                                      102,
                                      255,
                                      0,
                                    ),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Video Ads Skipped',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (adBlock.blockedCount > 0 || adBlock.skippedAdsCount > 0)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => adBlock.resetStats(),
                          icon: const Icon(
                            Icons.refresh,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          label: Text(
                            'Reset Counts',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 8),
                    const Divider(color: AppColors.surfaceBorder, height: 1),
                    const SizedBox(height: 12),

                    // Quick Page Controls (Reload / Clear Cache)
                    Text(
                      'PAGE CONTROLS',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),

                    InkWell(
                      onTap: () {
                        Navigator.pop(modalContext);
                        _controller?.reload();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.refresh_rounded,
                              color: AppColors.textPrimary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Reload Page',
                                style: AppTypography.bodyMedium,
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textSecondary,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    InkWell(
                      onTap: () {
                        Navigator.pop(modalContext);
                        _clearCache();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.cleaning_services_rounded,
                              color: AppColors.textPrimary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Clear Cache & Cookies',
                                style: AppTypography.bodyMedium,
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textSecondary,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
