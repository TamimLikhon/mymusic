import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../data/models/stream_song.dart';
import '../providers/playlist_provider.dart';
import '../pages/stream/create_playlist_page.dart';

/// Bottom sheet for adding a [song] to an existing playlist.
/// Each playlist row shows a filled/outlined icon to indicate if the
/// song is already in that playlist — no text snackbars needed.
class AddToPlaylistSheet extends StatefulWidget {
  final StreamSong song;

  const AddToPlaylistSheet({super.key, required this.song});

  @override
  State<AddToPlaylistSheet> createState() => _AddToPlaylistSheetState();
}

class _AddToPlaylistSheetState extends State<AddToPlaylistSheet> {
  // Track which playlists are being toggled (for micro-animation)
  final Set<String> _loading = {};

  Future<void> _toggle(PlaylistProvider provider, String playlistId) async {
    if (_loading.contains(playlistId)) return;
    setState(() => _loading.add(playlistId));

    final alreadyIn = provider.songIsInPlaylist(playlistId, widget.song.videoId);
    if (alreadyIn) {
      await provider.removeSongFromPlaylist(playlistId, widget.song.videoId);
    } else {
      await provider.addSongToPlaylist(playlistId, widget.song);
    }

    if (mounted) setState(() => _loading.remove(playlistId));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, provider, _) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                children: [
                  // ── Drag handle ───────────────────────────────────────────
                  const SizedBox(height: 12),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Header ────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        // Song thumbnail
                        if (widget.song.thumbUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              widget.song.thumbUrl!,
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _ThumbnailPlaceholder(size: 44),
                            ),
                          )
                        else
                          _ThumbnailPlaceholder(size: 44),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Add to playlist',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Divider(color: AppColors.surfaceBorder, height: 1),

                  // ── "New playlist" shortcut ───────────────────────────────
                  InkWell(
                    onTap: () async {
                      Navigator.pop(context);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreatePlaylistPage(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            'New Playlist',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(color: AppColors.surfaceBorder, height: 1),

                  // ── Playlist list ─────────────────────────────────────────
                  Expanded(
                    child: provider.playlists.isEmpty
                        ? _EmptyPlaylistsHint()
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: provider.playlists.length,
                            itemBuilder: (context, i) {
                              final playlist = provider.playlists[i];
                              final inPlaylist = provider.songIsInPlaylist(
                                  playlist.id, widget.song.videoId);
                              final isLoading =
                                  _loading.contains(playlist.id);

                              return _PlaylistRow(
                                playlist: playlist,
                                inPlaylist: inPlaylist,
                                isLoading: isLoading,
                                onTap: () =>
                                    _toggle(provider, playlist.id),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── Playlist Row ──────────────────────────────────────────────────────────────

class _PlaylistRow extends StatelessWidget {
  final dynamic playlist; // StreamPlaylist
  final bool inPlaylist;
  final bool isLoading;
  final VoidCallback onTap;

  const _PlaylistRow({
    required this.playlist,
    required this.inPlaylist,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            // ── Playlist thumbnail ──────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: playlist.thumbnailUrl != null
                  ? Image.network(
                      playlist.thumbnailUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _GradientThumb(name: playlist.name),
                    )
                  : _GradientThumb(name: playlist.name),
            ),
            const SizedBox(width: 14),

            // ── Name + song count ───────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${playlist.songs.length} song${playlist.songs.length == 1 ? '' : 's'}',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),

            // ── Add / Already-added icon ────────────────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: isLoading
                  ? const SizedBox(
                      key: ValueKey('loading'),
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : Icon(
                      key: ValueKey(inPlaylist),
                      inPlaylist
                          ? Icons.playlist_add_check_rounded
                          : Icons.playlist_add_rounded,
                      size: 28,
                      color: inPlaylist
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _ThumbnailPlaceholder extends StatelessWidget {
  final double size;
  const _ThumbnailPlaceholder({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Icon(
        Icons.music_note,
        color: AppColors.textSecondary.withValues(alpha: 0.5),
        size: size * 0.4,
      ),
    );
  }
}

class _GradientThumb extends StatelessWidget {
  final String name;
  const _GradientThumb({required this.name});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.seedGradient(name);
    return Container(
      width: 48,
      height: 48,
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
          color: Colors.white.withValues(alpha: 0.8),
          size: 22,
        ),
      ),
    );
  }
}

class _EmptyPlaylistsHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.queue_music_rounded,
              color: AppColors.textDisabled,
              size: 52,
            ),
            const SizedBox(height: 16),
            Text(
              'No playlists yet',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap "New Playlist" above to get started',
              style: AppTypography.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
