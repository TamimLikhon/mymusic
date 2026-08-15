import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../core/theme/app_colors.dart';

class YoutubeBrowserPage extends StatefulWidget {
  const YoutubeBrowserPage({super.key});

  @override
  State<YoutubeBrowserPage> createState() => _YoutubeBrowserPageState();
}

class _YoutubeBrowserPageState extends State<YoutubeBrowserPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri('https://music.youtube.com'),
            ),
            initialSettings: InAppWebViewSettings(
              userAgent:
                  'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Mobile Safari/537.36',
              javaScriptEnabled: true,
              domStorageEnabled: true,
              cacheEnabled: true,
              allowsInlineMediaPlayback: true,
              mediaPlaybackRequiresUserGesture: false,
              allowBackgroundAudioPlaying: true,
            ),
            onLoadStart: (controller, url) {
              if (mounted) setState(() => _isLoading = true);
            },
            onLoadStop: (controller, url) async {
              if (mounted) setState(() => _isLoading = false);
            },
          ),
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
        ],
      ),
    );
  }
}
