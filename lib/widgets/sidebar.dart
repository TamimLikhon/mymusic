import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/neumorphic.dart';
import '../providers/tag_provider.dart';

class Sidebar extends StatelessWidget {
  final String currentRoute;
  final Function(String) onNavigate;

  const Sidebar({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      elevation: 0,
      child: SafeArea(
        child: Column(
          children: [
            // Logo / header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
              child: Container(
                decoration: Neumorphic.raised(radius: 20, color: Colors.black),
                padding: const EdgeInsets.all(16),
                child: Image.asset(
                  'assets/icon.png',
                  height: 64,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Divider(color: AppColors.divider, thickness: 1),
            ),
            const SizedBox(height: 8),
            _buildItem(context, Icons.search_rounded, 'Search', '/search'),
            _buildItem(context, Icons.home_rounded, 'Vibe', '/vibe'),
            _buildItem(context, Icons.label_rounded, 'Tags', '/tags'),
            Consumer<TagProvider>(
              builder: (context, tagProvider, _) {
                if (tagProvider.tags.isEmpty) return const SizedBox();
                return Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: tagProvider.tags.length,
                    itemBuilder: (context, index) {
                      final tag = tagProvider.tags[index];
                      final isTagActive = currentRoute == '/tag/${tag.id}';
                      return _buildTagItem(context, tag.name, tag.id, isTagActive);
                    },
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Divider(color: AppColors.divider, thickness: 1),
            ),
            const SizedBox(height: 8),
            _buildItem(context, Icons.settings_rounded, 'Settings', '/settings'),
            _buildItem(context, Icons.info_rounded, 'About', '/about'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    IconData icon,
    String title,
    String route,
  ) {
    final isActive = currentRoute == route;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GestureDetector(
        onTap: () {
          onNavigate(route);
          Navigator.pop(context);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: isActive
              ? Neumorphic.raisedAccent(radius: 14, accent: AppColors.primary)
              : Neumorphic.pressed(radius: 14),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: AppTypography.body.copyWith(
                  color: isActive ? Colors.white : AppColors.textPrimary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagItem(
    BuildContext context,
    String name,
    String id,
    bool isActive,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 48, right: 16, top: 2, bottom: 2),
      child: GestureDetector(
        onTap: () {
          onNavigate('/tag/$id');
          Navigator.pop(context);
        },
        child: Row(
          children: [
            Icon(
              Icons.music_note_rounded,
              size: 14,
              color: isActive ? AppColors.primary : AppColors.textDisabled,
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: AppTypography.caption.copyWith(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
