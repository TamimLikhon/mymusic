/// Comprehensive ad-block rules for YouTube Music — Brave/uBlock-equivalent.
///
/// Covers:
///   1. Network rules  — block ad/tracker domains at request level
///   2. Cosmetic rules — CSS `display:none` injection for ad UI elements
///   3. JS injection   — auto-skip ads, mute ad audio, remove overlays
///
/// Format (Adblock Plus / uBlock Origin compatible subset):
///   `!`        — comment line
///   `@@`       — allowlist (never block this URL)
///   `||host^`  — block any request to host
///   `host##selector` — cosmetic CSS hide rule
const String kYouTubeMusicAdBlockRules = r'''
! ====================================================
! NETWORK BLOCK RULES  (request-level blocking)
! ====================================================

! ── Google Ad Infrastructure ─────────────────────────────────────────────────
||doubleclick.net^
||googleads.g.doubleclick.net^
||securepubads.g.doubleclick.net^
||static.doubleclick.net^
||stats.g.doubleclick.net^
||cm.g.doubleclick.net^
||fls.doubleclick.net^
||pagead2.googlesyndication.com^
||googlesyndication.com^
||googleadservices.com^
||adservice.google.com^
||adservice.google.ae^
||adservice.google.com.au^
||adservice.google.co.uk^
||tpc.googlesyndication.com^
||partner.googleadservices.com^

! ── YouTube / YouTube Music Ad Endpoints ─────────────────────────────────────
||ad.youtube.com^
||ads.youtube.com^
||youtube.com/api/stats/ads^
||youtube.com/pagead^
||youtube.com/ptracking^
||youtube.com/api/stats/atr^
||youtube.com/get_video_info*adformat^
||s.ytimg.com/yts/jsbin/www-pagead^
||youtube.com/csi*adformat^
||yt3.ggpht.com/ytc/ad^
||youtube.com/api/ads^
||youtube.com/youtubei/v1/log_event^
||r1---sn-*.googlevideo.com/initplayback^

! ── Google Analytics / Tracking ──────────────────────────────────────────────
||google-analytics.com^
||googletagmanager.com^
||googletagservices.com^
||ssl.google-analytics.com^
||analytics.google.com^
||www.google-analytics.com^
||in.hotjar.com^
||analytics.hotjar.com^
||static.hotjar.com^
||script.hotjar.com^
||connect.facebook.net/*/fbevents.js^
||connect.facebook.net/*/all.js^

! ── Ad Networks & Trackers ────────────────────────────────────────────────────
||amazon-adsystem.com^
||adsafeprotected.com^
||adsrvr.org^
||adnxs.com^
||advertising.com^
||adobedtm.com^
||omtrdc.net^
||demdex.net^
||moatads.com^
||outbrain.com^
||taboola.com^
||adsymptotic.com^
||imasdk.googleapis.com^
||ima3.googleapis.com^
||s0.2mdn.net^
||mads.amazon.com^
||c.amazon-adsystem.com^
||serving-sys.com^
||rubiconproject.com^
||openx.net^
||pubmatic.com^
||criteo.com^
||criteo.net^
||scorecardresearch.com^
||quantserve.com^
||casalemedia.com^
||mediamind.com^
||cdn.syndication.twimg.com^
||ads.twitter.com^
||static.ads-twitter.com^

! ── IMA SDK (in-stream video ads) ────────────────────────────────────────────
||imasdk.googleapis.com^
||gads.googleapis.com^

! ====================================================
! ALLOWLIST — never block these, critical for function
! ====================================================
@@||accounts.google.com^
@@||fonts.googleapis.com^
@@||fonts.gstatic.com^
@@||i.ytimg.com^
@@||lh3.googleusercontent.com^
@@||music.youtube.com^
@@||www.youtube.com^
@@||youtube.com/watch^
@@||youtube.com/youtubei^
@@||yt4.ggpht.com^
@@||yt3.ggpht.com^
@@||ytimg.com^
@@||gstatic.com^
@@||api.ipify.org^

! ====================================================
! COSMETIC FILTER RULES  (CSS element hiding)
! ====================================================

! ── Pre-roll / mid-roll video ad containers ──────────────────────────────────
music.youtube.com##.ad-showing
music.youtube.com##.ytp-ad-module
music.youtube.com##.ytp-ad-overlay-container
music.youtube.com##.ytp-ad-text-overlay
music.youtube.com##.ytp-ad-progress
music.youtube.com##.ytp-ad-progress-list
music.youtube.com##.ytp-ad-preview-container
music.youtube.com##.ytp-ad-preview-text
music.youtube.com##.ytp-ad-preview-image
music.youtube.com##.ytp-ad-skip-button-container
music.youtube.com##.ytp-ad-skip-button-modern
music.youtube.com##.ytp-ad-skip-button
music.youtube.com##.ytp-ad-button
music.youtube.com##.ytp-ad-button-icon
music.youtube.com##.ytp-ad-image-overlay
music.youtube.com##.ytp-ad-player-overlay
music.youtube.com##.ytp-ad-player-overlay-skip-or-preview
music.youtube.com##.ytp-ad-player-overlay-layout
music.youtube.com##.videoAdUiSkipContainer
music.youtube.com##.videoAdUi
music.youtube.com##.video-ads
music.youtube.com##ytd-player-legacy-desktop-watch-ads-renderer

! ── YouTube Music specific ad elements ───────────────────────────────────────
music.youtube.com##ytmusic-mealbar-promo-renderer
music.youtube.com##ytmusic-statement-banner-renderer
music.youtube.com##ytmusic-shelf-renderer[page-type="MUSIC_PAGE_TYPE_PREMIUM_OFFER"]
music.youtube.com##ytmusic-immersive-header-renderer[aria-label*="Premium"]
music.youtube.com##ytmusic-shelf-renderer[aria-label*="Premium"]
music.youtube.com##ytmusic-responsive-list-item-renderer[aria-label*="ad"]
music.youtube.com##ytd-promoted-sparkles-web-renderer
music.youtube.com##ytd-ad-slot-renderer
music.youtube.com##ytd-companion-slot-renderer
music.youtube.com##ytd-display-ad-renderer
music.youtube.com##ytd-banner-promo-renderer
music.youtube.com##ytd-statement-banner-renderer

! ── Overlay / banner ads ─────────────────────────────────────────────────────
music.youtube.com##.yt-mealbar-promo-renderer
music.youtube.com##.ytd-mealbar-promo-renderer
music.youtube.com##[class*="ad-showing"]
music.youtube.com##[class*="ad-container"]
music.youtube.com##[id*="player-ads"]
music.youtube.com##[id*="ad_creative_div"]
music.youtube.com##[aria-label*="Advertisement"]
music.youtube.com##[aria-label*="Skip Ad"]
''';

/// JavaScript injection source: auto-skip ads, remove ad overlays,
/// mute video during ad playback — equivalent to uBlock Origin's scriptlets.
const String kYouTubeMusicAdBlockScript = r'''
(function() {
  'use strict';

  // ── Prevent duplicate injection ────────────────────────────────────────────
  if (window.__mymusic_adblock_injected) return;
  window.__mymusic_adblock_injected = true;

  // ── Helper: safely remove a node ──────────────────────────────────────────
  function removeNode(node) {
    if (node && node.parentNode) node.parentNode.removeChild(node);
  }

  // ── Helper: click "Skip Ad" button if present ─────────────────────────────
  function trySkipAd() {
    const skipSelectors = [
      '.ytp-ad-skip-button',
      '.ytp-ad-skip-button-modern',
      '.ytp-skip-ad-button',
      'button[class*="skip"]',
    ];
    for (const sel of skipSelectors) {
      const btn = document.querySelector(sel);
      if (btn) { btn.click(); return true; }
    }
    return false;
  }

  // ── Helper: detect if an ad video is playing ──────────────────────────────
  function isAdPlaying() {
    return !!(
      document.querySelector('.ad-showing') ||
      document.querySelector('.ytp-ad-player-overlay') ||
      document.querySelector('.ytp-ad-module')
    );
  }

  // ── Auto-skip: poll every 300ms for skip button or ad end ─────────────────
  setInterval(function() {
    if (!isAdPlaying()) return;

    // Try clicking skip button immediately
    if (trySkipAd()) return;

    // Fast-forward the ad video to end it
    const video = document.querySelector('video');
    if (video && video.duration && !isNaN(video.duration) && isFinite(video.duration)) {
      try { video.currentTime = video.duration; } catch(e) {}
    }
  }, 300);

  // ── Mute video during ads and restore after ───────────────────────────────
  let wasMuted = false;
  setInterval(function() {
    const video = document.querySelector('video');
    if (!video) return;
    const adActive = isAdPlaying();
    if (adActive && !video.muted) {
      wasMuted = video.muted;
      video.muted = true;
      video.volume = 0;
    } else if (!adActive && video.muted && !wasMuted) {
      video.muted = false;
      if (video.volume === 0) video.volume = 1;
    }
  }, 300);

  // ── Remove ad UI elements with MutationObserver ───────────────────────────
  const adSelectors = [
    '.ytp-ad-module',
    '.ytp-ad-overlay-container',
    '.ytp-ad-text-overlay',
    '.ytp-ad-player-overlay',
    '.ytp-ad-preview-container',
    '.ytp-ad-skip-button-container',
    '.ytp-ad-button',
    '.ytp-ad-image-overlay',
    '.videoAdUi',
    '.video-ads',
    'ytmusic-mealbar-promo-renderer',
    'ytmusic-statement-banner-renderer',
    'ytd-promoted-sparkles-web-renderer',
    'ytd-ad-slot-renderer',
    'ytd-companion-slot-renderer',
    'ytd-display-ad-renderer',
    'ytd-banner-promo-renderer',
  ];

  function removeAdElements() {
    for (const sel of adSelectors) {
      document.querySelectorAll(sel).forEach(removeNode);
    }
    // Remove Premium upsell shelf
    document.querySelectorAll('ytmusic-shelf-renderer').forEach(function(el) {
      const pt = el.getAttribute('page-type') || '';
      if (pt.indexOf('PREMIUM') !== -1) removeNode(el);
    });
  }

  // Initial pass
  removeAdElements();

  // Watch DOM mutations
  const observer = new MutationObserver(function(mutations) {
    let changed = false;
    for (const m of mutations) {
      if (m.addedNodes.length) { changed = true; break; }
    }
    if (changed) removeAdElements();
  });

  observer.observe(document.documentElement, {
    childList: true,
    subtree: true,
  });

  // ── Block IMA SDK from loading ─────────────────────────────────────────────
  // Override the global google.ima namespace so ad SDK calls silently no-op
  Object.defineProperty(window, 'google', {
    get: function() { return window.__google_real__; },
    set: function(v) {
      window.__google_real__ = v;
      if (v && v.ima) {
        // Stub out IMA SDK ad display containers
        v.ima.AdDisplayContainer = function() {};
        v.ima.AdDisplayContainer.prototype.initialize = function() {};
        v.ima.AdDisplayContainer.prototype.destroy = function() {};
        v.ima.AdsLoader = function() { return { requestAds: function(){}, addEventListener: function(){}, destroy: function(){} }; };
        v.ima.AdsRequest = function() {};
        v.ima.AdsManager = function() {};
      }
    },
    configurable: true,
  });

})();
''';
