import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'services/permission_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_typography.dart';
import 'core/theme/glass_card.dart';
import 'widgets/mini_player.dart';
import 'pages/vibe/vibe_page.dart';
import 'pages/tags/all_tags_page.dart';
import 'pages/tags/tag_detail_page.dart';
import 'pages/settings/settings_page.dart';
import 'pages/about/about_page.dart';
import 'pages/search/search_page.dart';

class MyMusicApp extends StatefulWidget {
  const MyMusicApp({super.key});

  @override
  State<MyMusicApp> createState() => _MyMusicAppState();
}

class _MyMusicAppState extends State<MyMusicApp> {
  @override
  void initState() {
    super.initState();
    _requestPermissions();
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
          return MaterialPageRoute(
            builder: (_) => TagDetailPage(tagId: tagId),
          );
        }
        return null;
      },
    );
  }
}

// ── Navigation Items ─────────────────────────────────────────────────────────

enum _NavTab { home, search, tags }

class _AppShell extends StatefulWidget {
  const _AppShell();

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> with SingleTickerProviderStateMixin {
  _NavTab _tab = _NavTab.home;

  void _onTabChanged(int index) {
    setState(() => _tab = _NavTab.values[index]);
  }

  Widget _buildPage() {
    switch (_tab) {
      case _NavTab.home:
        return VibePage(onMoreTap: _showMoreSheet);
      case _NavTab.search:
        return const SearchPage();
      case _NavTab.tags:
        return const AllTagsPage();
    }
  }

  void _showMoreSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => _MoreSheet(
        onSettings: () {
          Navigator.pop(context);
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
        },
        onAbout: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AboutPage()),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: KeyedSubtree(
          key: ValueKey(_tab),
          child: _buildPage(),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
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

  const _SpotifyBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (HugeIcons.strokeRoundedHome01, HugeIcons.strokeRoundedHome01, 'Home'),
      (HugeIcons.strokeRoundedSearch01, HugeIcons.strokeRoundedSearch01, 'Search'),
      (HugeIcons.strokeRoundedFolderMusic, HugeIcons.strokeRoundedFolderMusic, 'Library'),
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

// ── More Sheet ────────────────────────────────────────────────────────────────

class _MoreSheet extends StatelessWidget {
  final VoidCallback onSettings;
  final VoidCallback onAbout;

  const _MoreSheet({required this.onSettings, required this.onAbout});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.surfaceBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('More', style: AppTypography.heading),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: GlassCard.card(radius: 12),
              child: const HugeIcon(icon: HugeIcons.strokeRoundedSettings01, size: 20, color: AppColors.textSecondary),
            ),
            title: Text('Settings', style: AppTypography.body),
            onTap: onSettings,
          ),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: GlassCard.card(radius: 12),
              child: const HugeIcon(icon: HugeIcons.strokeRoundedInformationCircle, size: 20, color: AppColors.textSecondary),
            ),
            title: Text('About', style: AppTypography.body),
            onTap: onAbout,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
