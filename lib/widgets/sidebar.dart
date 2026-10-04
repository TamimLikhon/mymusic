import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/glass_card.dart';
import '../providers/tag_provider.dart';

/// Glassmorphic Sidebar drawer.
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
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            color: AppColors.background.withValues(alpha: 0.9),
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: GlassCard.accent(radius: 14),
                          child: const Center(
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedFolderMusic,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Colors.white, AppColors.primaryLight],
                          ).createShader(bounds),
                          child: Text(
                            'MyMusic',
                            style: AppTypography.hero.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: AppColors.glassBorder),
                  const SizedBox(height: 12),
                  _buildItem(
                    context,
                    HugeIcons.strokeRoundedHome01,
                    'Home',
                    '/vibe',
                  ),
                  _buildItem(
                    context,
                    HugeIcons.strokeRoundedSearch01,
                    'Search',
                    '/search',
                  ),
                  _buildItem(
                    context,
                    HugeIcons.strokeRoundedTag01,
                    'Tags',
                    '/tags',
                  ),
                  Consumer<TagProvider>(
                    builder: (context, tagProvider, _) {
                      if (tagProvider.tags.isEmpty) return const SizedBox();
                      return Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: tagProvider.tags.length,
                          itemBuilder: (context, index) {
                            final tag = tagProvider.tags[index];
                            final isTagActive = currentRoute == '/tag/${tag.id}';
                            return _buildTagItem(
                              context,
                              tag.name,
                              tag.id,
                              Color(tag.color),
                              isTagActive,
                            );
                          },
                        ),
                      );
                    },
                  ),
                  Divider(height: 1, color: AppColors.glassBorder),
                  const SizedBox(height: 8),
                  _buildItem(
                    context,
                    HugeIcons.strokeRoundedSettings01,
                    'Settings',
                    '/settings',
                  ),
                  _buildItem(
                    context,
                    HugeIcons.strokeRoundedInformationCircle,
                    'About',
                    '/about',
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    dynamic icon,
    String title,
    String route,
  ) {
    final isActive = currentRoute == route;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      child: GestureDetector(
        onTap: () {
          onNavigate(route);
          Navigator.pop(context);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: isActive
              ? GlassCard.accent(radius: 14, accentColor: AppColors.primary)
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
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
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
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
    Color color,
    bool isActive,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 44, right: 14, top: 2, bottom: 2),
      child: GestureDetector(
        onTap: () {
          onNavigate('/tag/$id');
          Navigator.pop(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? color.withValues(alpha: 0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isActive
                ? Border.all(color: color.withValues(alpha: 0.4))
                : null,
          ),
          child: Row(
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedTag01,
                size: 14,
                color: isActive ? color : AppColors.textDisabled,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: AppTypography.caption.copyWith(
                    color: isActive ? color : AppColors.textSecondary,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
