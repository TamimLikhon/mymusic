import 'dart:ui';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'services/permission_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_typography.dart';
import 'widgets/mini_player.dart';
import 'pages/vibe/vibe_page.dart';
import 'pages/tags/all_tags_page.dart';
import 'pages/tags/tag_detail_page.dart';
import 'pages/settings/settings_page.dart';
import 'pages/about/about_page.dart';
import 'pages/stream/web_stream_page.dart';
import 'providers/audio_provider.dart';

class MyMusicApp extends StatefulWidget {
  final AudioProvider audioProvider;

  const MyMusicApp({super.key, required this.audioProvider});

  @override
  State<MyMusicApp> createState() => _MyMusicAppState();
}

class _MyMusicAppState extends State<MyMusicApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestPermissions();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // Re-activate the audio session when the app comes back to the
        // foreground. The OS may have silently deactivated it while the app
        // was in the background, breaking lock-screen controls.
        AudioSession.instance.then((session) => session.setActive(true));
        break;
      case AppLifecycleState.detached:
        // Process is being killed — stop cleanly.
        widget.audioProvider.stop();
        break;
      default:
        // paused / inactive / hidden — audio must keep running in background;
        // do not pause or stop the player here.
        break;
    }
  }

  Future<void> _requestPermissions() async {
    final permissionService = PermissionService();
    await permissionService.requestStoragePermission();
    await permissionService.requestNotificationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyMusic',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const _AppShell(),
      onGenerateRoute: (settings) {
        if (settings.name?.startsWith('/tag/') == true) {
          final tagId = settings.name!.replaceFirst('/tag/', '');
          return MaterialPageRoute(builder: (_) => TagDetailPage(tagId: tagId));
        }
        return null;
      },
    );
  }
}

// ── Navigation Items ─────────────────────────────────────────────────────────

enum _NavTab { home, stream, tags }

class _AppShell extends StatefulWidget {
  const _AppShell();

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  _NavTab _tab = _NavTab.home;
  bool _streamVisited = false;

  void _onTabChanged(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    final nextTab = _NavTab.values[index];
    setState(() {
      _tab = nextTab;
      if (nextTab == _NavTab.stream) _streamVisited = true;
    });
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsPage(
          onNavigateAbout: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AboutPage()),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true, // Let content go behind the glass nav bar
      body: Stack(
        children: [
          // ── All tab pages are always mounted (Offstage keeps them alive).
          //    This is critical for the WebView — it must never be disposed
          //    or music.youtube.com will lose its state and stop playing.
          Offstage(
            offstage: _tab != _NavTab.home,
            child: IgnorePointer(
              ignoring: _tab != _NavTab.home,
              child: TickerMode(
                enabled: _tab == _NavTab.home,
                child: VibePage(onSettingsTap: _navigateToSettings),
              ),
            ),
          ),
          if (_streamVisited)
            Offstage(
              offstage: _tab != _NavTab.stream,
              child: IgnorePointer(
                ignoring: _tab != _NavTab.stream,
                child: TickerMode(
                  enabled: _tab == _NavTab.stream,
                  child: const WebStreamPage(),
                ),
              ),
            ),
          Offstage(
            offstage: _tab != _NavTab.tags,
            child: IgnorePointer(
              ignoring: _tab != _NavTab.tags,
              child: TickerMode(
                enabled: _tab == _NavTab.tags,
                child: const AllTagsPage(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _GlassBottomNav(
        currentIndex: _tab.index,
        onTap: _onTabChanged,
      ),
    );
  }
}

// ── Glass Bottom Navigation ───────────────────────────────────────────────────

class _GlassBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _GlassBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      (HugeIcons.strokeRoundedHome01, 'Home'),
      (HugeIcons.strokeRoundedRadio, 'Stream'),
      (HugeIcons.strokeRoundedFolderMusic, 'Library'),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Mini Player (hidden on Stream tab) ──────────────────────────
        if (currentIndex != 1) const MiniPlayer(),
        // ── Glassmorphic Nav Bar ─────────────────────────────────────────
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.surface.withValues(alpha: 0.65),
                    AppColors.background.withValues(alpha: 0.92),
                  ],
                ),
                border: const Border(
                  top: BorderSide(color: AppColors.glassBorder, width: 0.8),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      for (int i = 0; i < items.length; i++)
                        _GlassNavItem(
                          icon: items[i].$1,
                          label: items[i].$2,
                          isActive: currentIndex == i,
                          onTap: () => onTap(i),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassNavItem extends StatelessWidget {
  final dynamic icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _GlassNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
        decoration: isActive
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.20),
                    AppColors.accent.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.30),
                  width: 0.8,
                ),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isActive ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: HugeIcon(
                icon: icon,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: AppTypography.label.copyWith(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
