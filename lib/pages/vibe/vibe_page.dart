import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/glass_card.dart';
import '../../data/database/app_database.dart';
import '../../providers/song_provider.dart';
import '../../providers/tag_provider.dart';
import '../../providers/audio_provider.dart';
import '../../services/permission_service.dart';
import '../../widgets/song_tile.dart';
import '../../widgets/tag_chip.dart';
import '../../widgets/assign_tag_sheet.dart';

class VibePage extends StatefulWidget {
  final VoidCallback? onSettingsTap;
  const VibePage({super.key, this.onSettingsTap});

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
            content: Text(
              count > 0 ? 'Found $count new songs 🎵' : 'No new songs found',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }

    setState(() => _isScanning = false);
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer3<SongProvider, TagProvider, AudioProvider>(
        builder: (context, songProvider, tagProvider, audioProvider, _) {
          if (songProvider.isLoading && songProvider.songs.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
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
    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const HugeIcon(
                    icon: HugeIcons.strokeRoundedFolderMusic,
                    size: 56,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Your library is empty',
                  style: AppTypography.hero.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 12),
                Text(
                  'Scan your device to find audio files and start listening.',
                  style: AppTypography.caption.copyWith(height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
                GestureDetector(
                  onTap: _scanSongs,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    decoration: GlassCard.accent(
                      radius: 30,
                      accentColor: AppColors.primary,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const HugeIcon(
                          icon: HugeIcons.strokeRoundedSearch01,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Scan Device',
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 20,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: GestureDetector(
                onTap: widget.onSettingsTap,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: GlassCard.card(radius: 12),
                  child: const HugeIcon(
                    icon: HugeIcons.strokeRoundedSettings01,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(
    SongProvider songProvider,
    TagProvider tagProvider,
    AudioProvider audioProvider,
  ) {
    return CustomScrollView(
      slivers: [
        // ── App Bar ──────────────────────────────────────────────────────────
        SliverAppBar(
          backgroundColor: AppColors.background,
          pinned: false,
          floating: true,
          snap: true,
          expandedHeight: 74,
          toolbarHeight: 0,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greeting(),
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'MyMusic',
                              style: AppTypography.display.copyWith(
                                fontSize: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Scan button
                      GestureDetector(
                        onTap: _isScanning ? null : _scanSongs,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: GlassCard.card(radius: 12),
                          child: _isScanning
                              ? const Center(
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                )
                              : const HugeIcon(
                                  icon: HugeIcons
                                      .strokeRoundedArrowReloadHorizontal,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Shuffle button
                      GestureDetector(
                        onTap: () {
                          final songs = context.read<SongProvider>().songs;
                          if (songs.isNotEmpty) {
                            context.read<AudioProvider>().shuffleAllSongs(
                              songs,
                            );
                          }
                        },
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: GlassCard.card(radius: 12),
                          child: const HugeIcon(
                            icon: HugeIcons.strokeRoundedShuffle,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: widget.onSettingsTap,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: GlassCard.card(radius: 12),
                          child: const HugeIcon(
                            icon: HugeIcons.strokeRoundedSettings01,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Recently Played ───────────────────────────────────────────────────
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
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: Text(
                      'RECENTLY PLAYED',
                      style: AppTypography.overline,
                    ),
                  ),
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: recentSongs.length,
                      itemBuilder: (context, index) {
                        final song = recentSongs[index];
                        final isActive =
                            audioProvider.currentSong?.id == song.id;
                        final colors = AppColors.seedGradient(song.title);
                        return GestureDetector(
                          onTap: () {
                            audioProvider.playAllSongs(
                              songProvider.songs,
                              startIndex: songProvider.songs.indexWhere(
                                (s) => s.id == song.id,
                              ),
                            );
                          },
                          child: Container(
                            width: 90,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: isActive
                                      ? BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: AppColors.primary,
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.4),
                                              blurRadius: 12,
                                            ),
                                          ],
                                        )
                                      : null,
                                  child: SongArtWidget(
                                    song: song,
                                    colors: colors,
                                    isPlaying: isActive,
                                    size: 76,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  song.title,
                                  style: AppTypography.caption.copyWith(
                                    fontSize: 10,
                                  ),
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
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        ),

        // ── Tags ──────────────────────────────────────────────────────────────
        if (tagProvider.tags.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Text('YOUR TAGS', style: AppTypography.overline),
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

        // ── All Songs ─────────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('ALL SONGS', style: AppTypography.overline),
                Text(
                  '${songProvider.songs.length} tracks',
                  style: AppTypography.caption.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ),

        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
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
              onLongPress: () => _showSongOptions(song),
            );
          }, childCount: songProvider.songs.length),
        ),

        const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
      ],
    );
  }

  void _showSongOptions(Song song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      isScrollControlled: true,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: AppColors.surfaceHigh.withValues(alpha: 0.7),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(top: 12, bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        song.title,
                        style: AppTypography.heading,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: GlassCard.card(radius: 12),
                        child: const Icon(
                          Icons.edit,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      title: Text('Edit Name', style: AppTypography.body),
                      onTap: () {
                        Navigator.pop(context);
                        _showRenameDialog(song);
                      },
                    ),
                    ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: GlassCard.card(radius: 12),
                        child: const HugeIcon(
                          icon: HugeIcons.strokeRoundedTag01,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      title: Text('Assign to tag', style: AppTypography.body),
                      onTap: () {
                        Navigator.pop(context);
                        AssignTagSheet.show(context, song.id, song.title);
                      },
                    ),
                    ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: GlassCard.card(radius: 12),
                        child: const HugeIcon(
                          icon: HugeIcons.strokeRoundedDelete01,
                          color: AppColors.secondary,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'Remove from library',
                        style: AppTypography.body.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _confirmDelete(song.id, song.title);
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showRenameDialog(Song song) {
    final controller = TextEditingController(text: song.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Edit Song Name', style: AppTypography.heading),
        content: TextField(
          controller: controller,
          style: AppTypography.body,
          decoration: InputDecoration(
            hintText: 'New song name',
            hintStyle: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          autofocus: true,
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
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty && newTitle != song.title) {
                final nav = Navigator.of(context);
                final scaffoldMsg = ScaffoldMessenger.of(context);
                final success = await context.read<SongProvider>().renameSong(
                  song,
                  newTitle,
                );

                nav.pop();
                if (success) {
                  scaffoldMsg.showSnackBar(
                    const SnackBar(content: Text('Song renamed successfully')),
                  );
                } else {
                  scaffoldMsg.showSnackBar(
                    const SnackBar(content: Text('Failed to rename song')),
                  );
                }
              } else {
                Navigator.pop(context);
              }
            },
            child: Text(
              'Save',
              style: AppTypography.body.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String songId, String songTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Song', style: AppTypography.heading),
        content: Text(
          'Remove "$songTitle" from your library?',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
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
            onPressed: () {
              context.read<SongProvider>().deleteSong(songId);
              Navigator.pop(context);
            },
            child: Text(
              'Remove',
              style: AppTypography.body.copyWith(color: AppColors.secondary),
            ),
          ),
        ],
      ),
    );
  }
}
