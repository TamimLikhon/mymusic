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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.background,
            pinned: true,
            leading: IconButton(
              icon: Container(
                width: 36,
                height: 36,
                decoration: GlassCard.card(radius: 10),
                child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowLeft01,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('Settings', style: AppTypography.heading),
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
                          const SnackBar(
                            content: Text('Scanning for songs...'),
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
                      subtitle: 'Version 1.0.8',
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
                const SizedBox(height: 40),
              ],
            ),
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
      decoration: GlassCard.card(radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedFolder01,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Music Folders',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (dirs.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 52, bottom: 4),
              child: Text(
                'No folders selected — add one below',
                style: AppTypography.caption,
              ),
            )
          else
            ...dirs.map(
              (dir) => Padding(
                padding: const EdgeInsets.only(left: 52, bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        dir,
                        style: AppTypography.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => songProvider.removeDirectory(dir),
                      child: const HugeIcon(
                        icon: HugeIcons.strokeRoundedCancel01,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 52),
            child: GestureDetector(
              onTap: () => _pickDirectory(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
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
                        fontWeight: FontWeight.w600,
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
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: Text(title.toUpperCase(), style: AppTypography.overline),
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: GlassCard.card(radius: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: HugeIcon(icon: icon, color: color, size: 20),
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
                    Text(subtitle, style: AppTypography.caption),
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
      builder: (context) => AlertDialog(
        title: Text('Clear All Data', style: AppTypography.heading),
        content: Text(
          'This will remove all songs and tags from your library. Songs on your device will not be deleted.',
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
                const SnackBar(content: Text('All data cleared')),
              );
            },
            child: Text(
              'Clear',
              style: AppTypography.body.copyWith(color: AppColors.secondary),
            ),
          ),
        ],
      ),
    );
  }
}
