import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/neumorphic.dart';
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
    if (parsed != null) {
      songProvider.addDirectory(parsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => context.findRootAncestorStateOfType<ScaffoldState>()?.openDrawer(),
          ),
        ),
        title: Text('Settings', style: AppTypography.heading),
      ),
      body: ListView(
        children: [
          _buildSection(
            title: 'Library',
            children: [
              Consumer<SongProvider>(
                builder: (context, songProvider, _) {
                  return _buildDirectoriesTile(context, songProvider);
                },
              ),
              _buildTile(
                icon: Icons.refresh,
                title: 'Rescan Library',
                subtitle: 'Scan selected folders for new songs',
                onTap: () {
                  context.read<SongProvider>().scanAndImport();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Scanning for songs...'),
                      backgroundColor: AppColors.amber,
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
                builder: (context, songProvider, _) {
                  return _buildTile(
                    icon: Icons.storage,
                    title: 'Library Size',
                    subtitle: '${songProvider.songs.length} songs',
                    onTap: () {},
                  );
                },
              ),
              _buildTile(
                icon: Icons.delete_sweep,
                title: 'Clear All Data',
                subtitle: 'Remove all songs and tags',
                onTap: () => _confirmClearData(context),
              ),
            ],
          ),
          _buildSection(
            title: 'About',
            children: [
              _buildTile(
                icon: Icons.info_outline,
                title: 'About MyMusic',
                subtitle: 'Version 1.0.0',
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
        ],
      ),
    );
  }

  Widget _buildDirectoriesTile(BuildContext context, SongProvider songProvider) {
    final dirs = songProvider.musicDirectories;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: Neumorphic.raised(radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: Neumorphic.raised(radius: 10),
                child: Icon(Icons.folder_rounded,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                'Music Folders',
                style: AppTypography.body.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (dirs.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 52, bottom: 8),
              child: Text(
                'No folders selected — add one below',
                style: AppTypography.caption,
              ),
            )
          else
            ...dirs.map((dir) => Padding(
              padding: const EdgeInsets.only(left: 52, bottom: 4),
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
                    child: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 52),
            child: GestureDetector(
              onTap: () => _pickDirectory(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: Neumorphic.raisedAccent(
                  radius: 20,
                  accent: AppColors.primary,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded, size: 16, color: Colors.white),
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

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            title,
            style: AppTypography.heading.copyWith(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ...children,
        const Divider(color: AppColors.divider),
      ],
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: Neumorphic.raised(radius: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: Neumorphic.raised(radius: 10),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTypography.body.copyWith(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  Text(subtitle, style: AppTypography.caption),
                ],
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
        backgroundColor: AppColors.background,
        title: Text('Clear All Data', style: AppTypography.heading.copyWith(fontSize: 16)),
        content: Text(
          'This will remove all songs and tags from your library. Songs on your device will not be deleted.',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTypography.caption),
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
                const SnackBar(
                  content: Text('All data cleared'),
                  backgroundColor: AppColors.burntOrange,
                ),
              );
            },
            child: Text('Clear', style: AppTypography.body.copyWith(color: AppColors.burntOrange)),
          ),
        ],
      ),
    );
  }
}
