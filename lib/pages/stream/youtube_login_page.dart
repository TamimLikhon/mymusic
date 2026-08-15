import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../services/auth_service.dart';

/// A full-screen WebView that lets the user sign in to their Google/YouTube
/// account.  Once login is detected, the session cookies are extracted and
/// securely stored via [AuthService], then the page closes automatically.
class YoutubeLoginPage extends StatefulWidget {
  const YoutubeLoginPage({super.key});

  @override
  State<YoutubeLoginPage> createState() => _YoutubeLoginPageState();
}

class _YoutubeLoginPageState extends State<YoutubeLoginPage> {
  final _authService = AuthService();
  bool _isLoading = true;
  bool _isExtracting = false;

  // The cookies we care about for YouTube Music API authentication
  static const _targetCookieNames = [
    'SAPISID',
    'SSID',
    'SID',
    'HSID',
    'APISID',
    '__Secure-3PSID',
    '__Secure-3PAPISID',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Text(
          'Sign in to YouTube',
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          if (_isExtracting)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF6C63FF),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(
                'https://accounts.google.com/ServiceLogin?service=youtube&continue=https://music.youtube.com',
              ),
            ),
            initialSettings: InAppWebViewSettings(
              userAgent:
                  'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Mobile Safari/537.36',
              javaScriptEnabled: true,
              domStorageEnabled: true,
              cacheEnabled: true,
              clearCache: false,
            ),
            onWebViewCreated: (controller) {},
            onLoadStart: (controller, url) {
              if (mounted) setState(() => _isLoading = true);
            },
            onLoadStop: (controller, url) async {
              if (mounted) setState(() => _isLoading = false);

              // Detect a successful login: user is back on music.youtube.com
              final urlStr = url?.toString() ?? '';
              if (urlStr.contains('music.youtube.com') &&
                  !urlStr.contains('accounts.google.com') &&
                  !_isExtracting) {
                await _extractAndSaveCookies(url!);
              }
            },
          ),

          // Loading bar at the top
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

          // Extracting overlay
          if (_isExtracting)
            Container(
              color: Colors.black.withValues(alpha: 0.6),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF6C63FF)),
                    const SizedBox(height: 16),
                    Text(
                      'Signing you in…',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _extractAndSaveCookies(WebUri url) async {
    if (!mounted) return;
    setState(() => _isExtracting = true);

    try {
      final cookieManager = CookieManager.instance();

      // Gather cookies from both youtube.com and music.youtube.com
      final ytCookies = await cookieManager.getCookies(
        url: WebUri('https://youtube.com'),
      );
      final ytmCookies = await cookieManager.getCookies(
        url: WebUri('https://music.youtube.com'),
      );

      final allCookies = [...ytCookies, ...ytmCookies];

      // Filter only the auth-critical cookies
      final authCookies = allCookies
          .where((c) => _targetCookieNames.contains(c.name))
          .toList();

      if (authCookies.isEmpty) {
        // Not fully logged in yet — wait for the next page load
        if (mounted) setState(() => _isExtracting = false);
        return;
      }

      // Serialize into "KEY=VALUE; KEY=VALUE" format
      final cookieString = authCookies
          .map((c) => '${c.name}=${c.value}')
          .join('; ');

      await _authService.saveCookies(cookieString);

      if (mounted) {
        // Pop with success so the Stream page can refresh
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isExtracting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-in failed: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
