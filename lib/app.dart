import 'package:flutter/material.dart';
import 'services/permission_service.dart';
import 'core/theme/app_theme.dart';
import 'widgets/sidebar.dart';
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
  String _currentRoute = '/vibe';

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

  void _onNavigate(String route) {
    setState(() => _currentRoute = route);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyMusic',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: _AppShell(
        currentRoute: _currentRoute,
        onNavigate: _onNavigate,
      ),
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

class _AppShell extends StatelessWidget {
  final String currentRoute;
  final Function(String) onNavigate;

  const _AppShell({
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: currentRoute == '/vibe',
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        onNavigate('/vibe');
      },
      child: Scaffold(
        drawer: Sidebar(
          currentRoute: currentRoute,
          onNavigate: onNavigate,
        ),
        body: Column(
          children: [
            Expanded(
              child: _buildPage(),
            ),
            const MiniPlayer(),
          ],
        ),
      ),
    );
  }

  Widget _buildPage() {
    switch (currentRoute) {
      case '/vibe':
        return const VibePage();
      case '/tags':
        return const AllTagsPage();
      case '/settings':
        return SettingsPage(onNavigateAbout: () => onNavigate('/about'));
      case '/about':
        return const AboutPage();
      case '/search':
        return const SearchPage();
      default:
        if (currentRoute.startsWith('/tag/')) {
          final tagId = currentRoute.replaceFirst('/tag/', '');
          return TagDetailPage(tagId: tagId);
        }
        return const VibePage();
    }
  }
}
