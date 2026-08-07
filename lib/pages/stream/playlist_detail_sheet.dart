import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/stream_playlist.dart';
import '../../data/models/stream_song.dart';
import '../../providers/stream_provider.dart';
import '../../providers/playlist_provider.dart';

class PlaylistDetailSheet extends StatelessWidget {
  final StreamPlaylist playlist;

  const PlaylistDetailSheet({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Consumer2<PlaylistProvider, MusicStreamProvider>(
      builder: (context, playlistProvider, streamProvider, _) {
        // Get fresh playlist reference
        final fresh = playlistProvider.playlists
            .where((p) => p.id == playlist.id)
            .firstOrNull;
        if (fresh == null) {
          Navigator.pop(context);
          return const SizedBox.shrink();
        }

        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              child: Stack(
                children: [
                  // Blurred background from thumbnail
                  if (fresh.thumbnailUrl != null)
                    Positioned.fill(
                      child: Image.network(
                        fresh.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                      child: Container(
                        color: const Color(0xFF0D0D1A).withValues(alpha: 0.85),
                      ),
                    ),
                  ),

                  // Content
                  Column(
                    children: [
                      // Drag handle
                      const SizedBox(height: 12),
                      Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            // Cover art
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: fresh.thumbnailUrl != null
                                  ? Image.network(
                                      fresh.thumbnailUrl!,
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => _GradientCover(
                                        name: fresh.name,
                                        size: 64,
                                      ),
                                    )
                                  : _GradientCover(name: fresh.name, size: 64),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fresh.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.heading.copyWith(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${fresh.songs.length} song${fresh.songs.length == 1 ? '' : 's'}',
                                    style: AppTypography.caption.copyWith(
                                      color: Colors.white60,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Delete playlist
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.white38,
                                size: 22,
                              ),
                              onPressed: () => _confirmDelete(
                                context,
                                playlistProvider,
                                fresh.id,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Divider(
                        color: Colors.white.withValues(alpha: 0.1),
                        height: 1,
                      ),

                      // Song list
                      Expanded(
                        child: fresh.songs.isEmpty
                            ? _EmptyState()
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: fresh.songs.length,
                                itemBuilder: (context, i) {
                                  final song = fresh.songs[i];
                                  final isCurrent =
                                      streamProvider.currentSong?.videoId ==
                                      song.videoId;
                                  return _SongRow(
                                    song: song,
                                    isCurrent: isCurrent,
                                    onTap: () =>
                                        streamProvider.playSong(song, -1),
                                    onRemove: () =>
                                        playlistProvider.removeSongFromPlaylist(
                                          fresh.id,
                                          song.videoId,
                                        ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(
    BuildContext context,
    PlaylistProvider provider,
    String id,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Playlist?',
          style: AppTypography.heading.copyWith(fontSize: 18),
        ),
        content: Text(
          'This will permanently delete this playlist.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              provider.deletePlaylist(id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.secondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _SongRow extends StatelessWidget {
  final StreamSong song;
  final bool isCurrent;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _SongRow({
    required this.song,
    required this.isCurrent,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: isCurrent
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          border: isCurrent
              ? const Border(
                  left: BorderSide(color: AppColors.primary, width: 3),
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: song.thumbUrl != null
                    ? Image.network(
                        song.thumbUrl!,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _miniPlaceholder(),
                      )
                    : _miniPlaceholder(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isCurrent
                            ? const Color(0xFF9D97FF)
                            : Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      song.artists,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.remove_circle_outline_rounded,
                  color: Colors.white30,
                  size: 20,
                ),
                onPressed: onRemove,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniPlaceholder() => Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Icon(
      Icons.music_note,
      color: AppColors.textSecondary,
      size: 20,
    ),
  );
}

class _GradientCover extends StatelessWidget {
  final String name;
  final double size;
  const _GradientCover({required this.name, required this.size});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.seedGradient(name);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: HugeIcon(
          icon: HugeIcons.strokeRoundedMusicNote01,
          color: Colors.white.withValues(alpha: 0.7),
          size: size * 0.4,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.queue_music_rounded,
            color: Colors.white24,
            size: 52,
          ),
          const SizedBox(height: 16),
          Text(
            'No songs yet',
            style: AppTypography.bodyMedium.copyWith(color: Colors.white38),
          ),
          const SizedBox(height: 6),
          Text(
            'Play a song and use the ⊕ button\nto add it here',
            style: AppTypography.caption.copyWith(color: Colors.white24),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
