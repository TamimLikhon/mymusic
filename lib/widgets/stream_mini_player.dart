import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../providers/stream_provider.dart';
import '../pages/stream/stream_player_sheet.dart';
import 'add_to_playlist_sheet.dart';

class StreamMiniPlayer extends StatelessWidget {
  const StreamMiniPlayer({super.key});

  void _openPlayerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const StreamPlayerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final streamProvider = context.watch<MusicStreamProvider>();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, anim) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
        child: FadeTransition(opacity: anim, child: child),
      ),
      child: streamProvider.hasSong
          ? _MiniPlayerContent(
              key: const Key('stream_mini_player_active'),
              streamProvider: streamProvider,
              onTap: () => _openPlayerSheet(context),
            )
          : const SizedBox.shrink(key: Key('stream_mini_player_empty')),
    );
  }
}

class _MiniPlayerContent extends StatelessWidget {
  final MusicStreamProvider streamProvider;
  final VoidCallback onTap;

  const _MiniPlayerContent({
    super.key,
    required this.streamProvider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final song = streamProvider.currentSong!;

    return GestureDetector(
      onTap: onTap,
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          onTap();
        }
      },
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          streamProvider.previous();
        } else if (details.primaryVelocity! < 0) {
          streamProvider.next();
        }
      },
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: AppColors.surfaceHigh,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(
                  Icons.playlist_play_rounded,
                  color: AppColors.textPrimary,
                ),
                title: Text('Play Next', style: AppTypography.bodyMedium),
                onTap: () {
                  // Logic for play next (insert into queue at index + 1)
                  streamProvider.addToQueue(song);
                  streamProvider.reorderQueue(
                    streamProvider.queue.length - 1,
                    streamProvider.queueIndex + 1,
                  );
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.queue_music_rounded,
                  color: AppColors.textPrimary,
                ),
                title: Text('Add to Queue', style: AppTypography.bodyMedium),
                onTap: () {
                  streamProvider.addToQueue(song);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.playlist_add_rounded,
                  color: AppColors.textPrimary,
                ),
                title: Text('Add to Playlist', style: AppTypography.bodyMedium),
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => AddToPlaylistSheet(song: song),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        height: 68,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Blurred thumbnail background
              if (song.thumbUrl != null)
                Positioned.fill(
                  child: Image.network(
                    song.thumbUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.88),
                      border: Border.all(
                        color: AppColors.surfaceBorder,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              // Progress line at top
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _ProgressLine(streamProvider: streamProvider),
              ),

              // Row content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    // Thumbnail
                    _Thumbnail(
                      thumbUrl: song.thumbUrl,
                      isBuffering: streamProvider.isBuffering,
                    ),
                    const SizedBox(width: 12),

                    // Title & Artist
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            song.artists,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ),

                    // Play/Pause
                    _PlayPauseIcon(streamProvider: streamProvider),

                    // Next
                    IconButton(
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedNext,
                        color: AppColors.textSecondary,
                        size: 22,
                      ),
                      onPressed: streamProvider.next,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),

                    // Add to Playlist
                    IconButton(
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedPlaylist01,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => AddToPlaylistSheet(song: song),
                        );
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  final MusicStreamProvider streamProvider;
  const _ProgressLine({required this.streamProvider});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(height: 2, color: AppColors.surfaceBorder),
        ValueListenableBuilder<Duration>(
          valueListenable: streamProvider.positionNotifier,
          builder: (context, position, _) {
            final progress = streamProvider.duration.inMilliseconds > 0
                ? (position.inMilliseconds /
                          streamProvider.duration.inMilliseconds)
                      .clamp(0.0, 1.0)
                : 0.0;
            return FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 2,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF3ECFCF)],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final String? thumbUrl;
  final bool isBuffering;
  const _Thumbnail({required this.thumbUrl, this.isBuffering = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: thumbUrl != null
              ? Image.network(
                  thumbUrl!,
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _placeholder(),
                )
              : _placeholder(),
        ),
        if (isBuffering)
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _placeholder() {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF3ECFCF)],
        ),
      ),
      child: const Icon(Icons.music_note, color: Colors.white54, size: 20),
    );
  }
}

class _PlayPauseIcon extends StatelessWidget {
  final MusicStreamProvider streamProvider;
  const _PlayPauseIcon({required this.streamProvider});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: IconButton(
          key: ValueKey(streamProvider.isPlaying),
          icon: HugeIcon(
            icon: streamProvider.isPlaying
                ? HugeIcons.strokeRoundedPause
                : HugeIcons.strokeRoundedPlay,
            color: AppColors.textPrimary,
            size: 22,
          ),
          onPressed: streamProvider.togglePlayPause,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
      ),
    );
  }
}
