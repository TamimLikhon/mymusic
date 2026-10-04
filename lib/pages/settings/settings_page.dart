import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/glass_card.dart';
import '../../providers/song_provider.dart';
import '../../providers/tag_provider.dart';
import '../../services/directory_settings_service.dart';

class SettingsPage extends StatelessWidget {
  final VoidCallback? onNavigateAbout;
  const SettingsPage({super.key, this.onNavigateAbout});

  Future<void> _pickDirectory(BuildContext context) async {
    final songProvider = context.read<SongProvider>();
    final result = await FilePicker.platform.getDirectoryPath();
    if (result == null) return;
    final parsed = DirectorySettingsService().parseSafUri(result);
    if (parsed != null) songProvider.addDirectory(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Cosmos Ambient Glow Orbs ───────────────────────────────────────
          Positioned(
            top: -40,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Scroll Content ────────────────────────────────────────────────
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                pinned: true,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: GlassCard.card(radius: 12),
                        child: const Center(
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedArrowLeft01,
                            size: 20,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                title: Text(
                  'Settings',
                  style: AppTypography.heading.copyWith(fontSize: 20),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildSection(
                      title: 'Library',
                      children: [
                        Consumer<SongProvider>(
                          builder: (context, songProvider, _) =>
                              _buildDirectoriesTile(context, songProvider),
                        ),
                        _buildTile(
                          context: context,
                          icon: HugeIcons.strokeRoundedArrowReloadHorizontal,
                          title: 'Rescan Library',
                          subtitle: 'Scan selected folders for new songs',
                          onTap: () {
                            context.read<SongProvider>().scanAndImport();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Scanning for songs...'),
                                backgroundColor: AppColors.surfaceHigh,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    _buildSection(
                      title: 'Data',
                      children: [
                        Consumer<SongProvider>(
                          builder: (context, songProvider, _) => _buildTile(
                            context: context,
                            icon: HugeIcons.strokeRoundedFolderMusic,
                            title: 'Library Size',
                            subtitle:
                                '${songProvider.songs.length} songs in library',
                            onTap: () {},
                          ),
                        ),
                        _buildTile(
                          context: context,
                          icon: HugeIcons.strokeRoundedDelete02,
                          title: 'Clear All Data',
                          subtitle: 'Remove all songs and tags from library',
                          iconColor: AppColors.secondary,
                          onTap: () => _confirmClearData(context),
                        ),
                      ],
                    ),
                    _buildSection(
                      title: 'About',
                      children: [
                        _buildTile(
                          context: context,
                          icon: HugeIcons.strokeRoundedInformationCircle,
                          title: 'About MyMusic',
                          subtitle: 'Version 1.0.1 • Crafted with glassmorphism',
                          onTap: () {
                            if (onNavigateAbout != null) {
                              onNavigateAbout!();
                            } else {
                              Navigator.pushNamed(context, '/about');
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDirectoriesTile(
    BuildContext context,
    SongProvider songProvider,
  ) {
    final dirs = songProvider.musicDirectories;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: GlassCard.card(radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: const Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedFolder01,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                'Music Folders',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (dirs.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 56, bottom: 4),
              child: Text(
                'No folders selected — add one below',
                style: AppTypography.caption,
              ),
            )
          else
            ...dirs.map(
              (dir) => Padding(
                padding: const EdgeInsets.only(left: 56, bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        dir,
                        style: AppTypography.caption.copyWith(
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => songProvider.removeDirectory(dir),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const HugeIcon(
                          icon: HugeIcons.strokeRoundedCancel01,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 56),
            child: GestureDetector(
              onTap: () => _pickDirectory(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                decoration: GlassCard.accent(
                  radius: 20,
                  accentColor: AppColors.primary,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const HugeIcon(
                      icon: HugeIcons.strokeRoundedAdd01,
                      size: 15,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Add Folder',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 8),
          child: Text(
            title.toUpperCase(),
            style: AppTypography.overline.copyWith(
              color: AppColors.primaryLight.withValues(alpha: 0.7),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...children,
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildTile({
    required BuildContext context,
    required dynamic icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final color = iconColor ?? AppColors.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: GlassCard.card(radius: 16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: color.withValues(alpha: 0.25),
                  ),
                ),
                child: Center(
                  child: HugeIcon(icon: icon, color: color, size: 20),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const HugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                size: 18,
                color: AppColors.textDisabled,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmClearData(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AlertDialog(
            backgroundColor: AppColors.surfaceHigh.withValues(alpha: 0.92),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(24)),
              side: BorderSide(color: AppColors.glassBorderStrong, width: 1),
            ),
            title: Text('Clear All Data', style: AppTypography.heading),
            content: Text(
              'This will remove all songs and tags from your library. Music files on your device will remain untouched.',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final songProvider = context.read<SongProvider>();
                  final tagProvider = context.read<TagProvider>();
                  Navigator.pop(context);
                  await songProvider.clearAllData();
                  await tagProvider.clearAllData();
                  messenger.showSnackBar(
                    SnackBar(
                      content: const Text('All data cleared'),
                      backgroundColor: AppColors.surfaceHigh,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                child: Text(
                  'Clear',
                  style: AppTypography.body.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
