import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/glass_card.dart';
import '../providers/tag_provider.dart';

/// Legacy Sidebar — kept for backward compatibility.
/// The primary navigation is now the bottom nav bar in app.dart.
/// This drawer is no longer attached to the shell scaffold.
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
      backgroundColor: AppColors.surface,
      elevation: 0,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: GlassCard.accent(radius: 14),
                    child: const HugeIcon(icon: HugeIcons.strokeRoundedFolderMusic,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Text('MyMusic', style: AppTypography.hero.copyWith(fontSize: 20)),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 8),
            _buildItem(context, HugeIcons.strokeRoundedSearch01, 'Search', '/search'),
            _buildItem(context, HugeIcons.strokeRoundedHome01, 'Home', '/vibe'),
            _buildItem(context, HugeIcons.strokeRoundedTag01, 'Tags', '/tags'),
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
            Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 8),
            _buildItem(context, HugeIcons.strokeRoundedSettings01, 'Settings', '/settings'),
            _buildItem(context, HugeIcons.strokeRoundedInformationCircle, 'About', '/about'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, dynamic icon, String title, String route) {
    final isActive = currentRoute == route;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: GestureDetector(
        onTap: () {
          onNavigate(route);
          Navigator.pop(context);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: isActive
              ? GlassCard.accent(radius: 12, accentColor: AppColors.primary)
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.transparent,
                ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              HugeIcon(
                icon: icon,
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

  Widget _buildTagItem(BuildContext context, String name, String id, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(left: 44, right: 12, top: 2, bottom: 2),
      child: GestureDetector(
        onTap: () {
          onNavigate('/tag/$id');
          Navigator.pop(context);
        },
        child: Row(
          children: [
            HugeIcon(icon: HugeIcons.strokeRoundedMusicNote01,
              size: 13,
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
