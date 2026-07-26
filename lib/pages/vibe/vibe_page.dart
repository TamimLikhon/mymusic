import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/neumorphic.dart';
import '../../data/database/app_database.dart';
import '../../providers/song_provider.dart';
import '../../providers/tag_provider.dart';
import '../../providers/audio_provider.dart';
import '../../services/permission_service.dart';
import '../../widgets/song_tile.dart';
import '../../widgets/tag_chip.dart';
import '../../widgets/assign_tag_sheet.dart';

class VibePage extends StatefulWidget {
  const VibePage({super.key});

  @override
  State<VibePage> createState() => _VibePageState();
}

class _VibePageState extends State<VibePage> {
  bool _isScanning = false;

  Future<void> _scanSongs() async {
    final permissionService = PermissionService();
    final provider = context.read<SongProvider>();
    final granted = await permissionService.requestStoragePermission();

    if (!granted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Storage permission required to scan songs'),
          backgroundColor: AppColors.burntOrange,
        ),
      );
      return;
    }

    setState(() => _isScanning = true);

    try {
      await provider.scanAndImport();
      if (mounted) {
        final count = provider.scannedCount;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(count > 0 ? 'Found $count new songs' : 'No new songs found'),
            backgroundColor: AppColors.neonGreen.withValues(alpha: 0.8),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.burntOrange,
          ),
        );
      }
    }

    setState(() => _isScanning = false);
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
        title: Text('Vibe', style: AppTypography.heading),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            tooltip: 'Shuffle all',
            onPressed: _isScanning
                ? null
                : () {
                    final songs = context.read<SongProvider>().songs;
                    if (songs.isNotEmpty) {
                      context.read<AudioProvider>().shuffleAllSongs(songs);
                    }
                  },
          ),
          IconButton(
            icon: _isScanning
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.amber,
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: _isScanning ? null : _scanSongs,
          ),
        ],
      ),
      body: Consumer3<SongProvider, TagProvider, AudioProvider>(
        builder: (context, songProvider, tagProvider, audioProvider, _) {
          if (songProvider.isLoading && songProvider.songs.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.amber),
            );
          }

          if (songProvider.songs.isEmpty) {
            return _buildEmptyState();
          }

          return _buildContent(songProvider, tagProvider, audioProvider);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: Neumorphic.raisedCircle(),
              child: const Icon(
                Icons.album_rounded,
                size: 52,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'No songs yet',
              style: AppTypography.heading.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Tap the button below to scan your device.\nThis requires storage permission to find audio files.',
              style: AppTypography.caption,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: _scanSongs,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: Neumorphic.raisedAccent(
                  radius: 28,
                  accent: AppColors.primary,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Scan Device',
                      style: AppTypography.body.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(SongProvider songProvider, TagProvider tagProvider, AudioProvider audioProvider) {
    return CustomScrollView(
      slivers: [
        // Recently Played section
        SliverToBoxAdapter(
          child: FutureBuilder<List<Song>>(
            future: songProvider.getRecentlyPlayed(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox.shrink();
              }
              final recentSongs = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Recently Played',
                      style: AppTypography.heading.copyWith(fontSize: 11),
                    ),
                  ),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: recentSongs.length,
                      itemBuilder: (context, index) {
                        final song = recentSongs[index];
                        return GestureDetector(
                          onTap: () {
                            audioProvider.playAllSongs(
                              songProvider.songs,
                              startIndex: songProvider.songs.indexWhere((s) => s.id == song.id),
                            );
                          },
                          child: Container(
                            width: 70,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: audioProvider.currentSong?.id == song.id
                                      ? Neumorphic.raisedAccent(
                                          radius: 14,
                                          accent: AppColors.primary,
                                        )
                                      : Neumorphic.raised(radius: 14),
                                  child: Center(
                                    child: Icon(
                                      Icons.music_note_rounded,
                                      color: audioProvider.currentSong?.id == song.id
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                      size: 24,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  song.title,
                                  style: AppTypography.caption.copyWith(fontSize: 9),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        // Tags section
        if (tagProvider.tags.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Your Tags',
                style: AppTypography.heading.copyWith(fontSize: 11),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: tagProvider.tags.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final tag = tagProvider.tags[index];
                  final count = tagProvider.songCounts[tag.id] ?? 0;
                  return TagChip(
                    name: tag.name,
                    color: tag.color,
                    songCount: count,
                    onTap: () => Navigator.pushNamed(context, '/tag/${tag.id}'),
                  );
                },
              ),
            ),
          ),
        ],
        // All Songs section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'All Songs',
                  style: AppTypography.heading.copyWith(fontSize: 11),
                ),
                Text(
                  '${songProvider.songs.length} songs',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final song = songProvider.songs[index];
              return SongTile(
                song: song,
                index: index,
                isPlaying: audioProvider.currentSong?.id == song.id,
                onTap: () {
                  audioProvider.playAllSongs(
                    songProvider.songs,
                    startIndex: index,
                  );
                },
                onLongPress: () => _showSongOptions(song.id, song.title),
              );
            },
            childCount: songProvider.songs.length,
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
      ],
    );
  }

  void _showSongOptions(String songId, String songTitle) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  songTitle,
                  style: AppTypography.body.copyWith(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.label_outline, color: AppColors.amber),
                title: Text(
                  'Assign to tag',
                  style: AppTypography.body.copyWith(fontSize: 14),
                ),
                onTap: () {
                  Navigator.pop(context);
                  AssignTagSheet.show(context, songId, songTitle);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.burntOrange),
                title: Text(
                  'Delete from library',
                  style: AppTypography.body.copyWith(
                    fontSize: 14,
                    color: AppColors.burntOrange,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(songId, songTitle);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(String songId, String songTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text(
          'Delete Song',
          style: AppTypography.heading.copyWith(fontSize: 16),
        ),
        content: Text(
          'Remove "$songTitle" from your library?',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTypography.caption),
          ),
          TextButton(
            onPressed: () {
              context.read<SongProvider>().deleteSong(songId);
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: AppTypography.body.copyWith(color: AppColors.burntOrange),
            ),
          ),
        ],
      ),
    );
  }
}
