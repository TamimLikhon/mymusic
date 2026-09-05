import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'services/permission_service.dart';
import 'services/analytics_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_typography.dart';
import 'widgets/mini_player.dart';
import 'pages/vibe/vibe_page.dart';
import 'pages/tags/all_tags_page.dart';
import 'pages/tags/tag_detail_page.dart';
import 'pages/settings/settings_page.dart';
import 'pages/about/about_page.dart';
import 'pages/search/search_page.dart';
import 'pages/stream/web_stream_page.dart';
import 'package:provider/provider.dart';
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
    _requestPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      widget.audioProvider.stop();
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
      // Automatically fires screen_view events on every route change.
      // Visible in Firebase Console: Analytics → Events → screen_view
      navigatorObservers: [AnalyticsService.instance.observer],
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

enum _NavTab { home, stream, search, tags }

class _AppShell extends StatefulWidget {
  const _AppShell();

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  _NavTab _tab = _NavTab.home;

  void _onTabChanged(int index) {
    setState(() => _tab = _NavTab.values[index]);
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
      body: Stack(
        children: [
          // ── All tab pages are always mounted (Offstage keeps them alive).
          //    This is critical for the WebView — it must never be disposed
          //    or music.youtube.com will lose its state and stop playing.
          Offstage(
            offstage: _tab != _NavTab.home,
            child: TickerMode(
              enabled: _tab == _NavTab.home,
              child: VibePage(onSettingsTap: _navigateToSettings),
            ),
          ),
          Offstage(
            offstage: _tab != _NavTab.stream,
            child: TickerMode(
              enabled: _tab == _NavTab.stream,
              child: const WebStreamPage(),
            ),
          ),
          Offstage(
            offstage: _tab != _NavTab.search,
            child: TickerMode(
              enabled: _tab == _NavTab.search,
              child: const SearchPage(),
            ),
          ),
          Offstage(
            offstage: _tab != _NavTab.tags,
            child: TickerMode(
              enabled: _tab == _NavTab.tags,
              child: const AllTagsPage(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Mini Player ─────────────────────────────────────────────────
          // Local MiniPlayer shows when a local song is active.
          Consumer<AudioProvider>(
            builder: (context, audio, _) {
              if (audio.currentSong != null) {
                return const MiniPlayer();
              }
              return const SizedBox.shrink();
            },
          ),
          _SpotifyBottomNav(
            currentIndex: _tab.index,
            onTap: _onTabChanged,
          ),
        ],
      ),
    );
  }
}

// ── Custom Bottom Navigation ──────────────────────────────────────────────────

class _SpotifyBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _SpotifyBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      (HugeIcons.strokeRoundedHome01, HugeIcons.strokeRoundedHome01, 'Home'),
      (HugeIcons.strokeRoundedRadio, HugeIcons.strokeRoundedRadio, 'Stream'),
      (
        HugeIcons.strokeRoundedSearch01,
        HugeIcons.strokeRoundedSearch01,
        'Search',
      ),
      (
        HugeIcons.strokeRoundedFolderMusic,
        HugeIcons.strokeRoundedFolderMusic,
        'Library',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.surfaceBorder, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (int i = 0; i < items.length; i++)
                _NavItem(
                  activeIcon: items[i].$1,
                  inactiveIcon: items[i].$2,
                  label: items[i].$3,
                  isActive: currentIndex == i,
                  onTap: () => onTap(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final dynamic activeIcon;
  final dynamic inactiveIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.activeIcon,
    required this.inactiveIcon,
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: isActive
            ? BoxDecoration(
                color: AppColors.primaryFaint,
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: HugeIcon(
                icon: isActive ? activeIcon : inactiveIcon,
                key: ValueKey(isActive),
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTypography.label.copyWith(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
