import 'blocklist_engine.dart';
import 'ad_block_rules.dart';

/// Singleton that pre-compiles Brave/uBlock-equivalent ad-block rules.
///
/// Three-layer protection:
///   1. [shouldBlock]      — network-level URL filtering (request interception)
///   2. [cosmeticScript]   — CSS injection that hides ad UI elements
///   3. [scriptletScript]  — JS injection: auto-skip ads, mute ad audio,
///                           DOM mutation observer, IMA SDK stubbing
class AdBlockService {
  AdBlockService._();
  static final AdBlockService instance = AdBlockService._();

  late final BlocklistEngine _engine;

  /// CSS injection — hides ad elements via `display:none !important`.
  late final String cosmeticScript;

  /// JS scriptlet injection — auto-skip, mute, IMA stub, MutationObserver.
  late final String scriptletScript;

  /// Combined script: run cosmetic CSS + all scriptlets in a single eval.
  late final String fullScript;

  /// Must be called once (e.g. in main()) before the WebView is created.
  void initialize() {
    _engine = BlocklistEngine.parse(kYouTubeMusicAdBlockRules);
    cosmeticScript = _buildCosmeticScript(_engine.cosmeticSelectors);
    scriptletScript = kYouTubeMusicAdBlockScript;
    // Combine both into one injection for efficiency
    fullScript = '$cosmeticScript\n$scriptletScript';
  }

  /// Returns true if [url] matches a block rule and is NOT in the allowlist.
  bool shouldBlock(String url) => _engine.matches(url);

  static String _buildCosmeticScript(List<String> selectors) {
    if (selectors.isEmpty) return '';

    final css = selectors
        .map((s) =>
            '$s { display: none !important; visibility: hidden !important; height: 0 !important; max-height: 0 !important; }')
        .join('\n');

    // Use <style> tag injection — survives SPA navigations that replace child
    // nodes but not <head>. The ID check prevents duplicate injections.
    return '''
(function() {
  const STYLE_ID = '__mymusic_adblock_styles';
  if (document.getElementById(STYLE_ID)) return;
  const style = document.createElement('style');
  style.id = STYLE_ID;
  style.textContent = ${_jsString(css)};
  (document.head || document.documentElement).appendChild(style);
})();
''';
  }

  /// Wraps [s] as a JS backtick template literal with proper escaping.
  static String _jsString(String s) {
    final escaped = s
        .replaceAll(r'\', r'\\')
        .replaceAll('`', r'\`')
        .replaceAll(r'$', r'\$');
    return '`$escaped`';
  }
}
