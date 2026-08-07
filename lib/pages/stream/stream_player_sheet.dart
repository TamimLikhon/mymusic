import 'dart:ui';
import 'package:flutter/material.dart' hide RepeatMode;
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/stream_provider.dart';
import '../../widgets/retro_seek_bar.dart';
import '../../widgets/add_to_playlist_sheet.dart';
import '../../widgets/queue_sheet.dart';

class StreamPlayerSheet extends StatelessWidget {
  const StreamPlayerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final streamProvider = context.watch<MusicStreamProvider>();
    final song = streamProvider.currentSong;

    if (song == null) {
      return const SizedBox.shrink();
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: Stack(
            children: [
              // ── Blurred Background ──────────────────────────────────────
              if (song.thumbUrl != null)
                Positioned.fill(
                  child: Image.network(
                    song.thumbUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const ColoredBox(color: Color(0xFF0D0D1A)),
                  ),
                ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                  child: Container(
                    color: const Color(0xFF0D0D1A).withValues(alpha: 0.75),
                  ),
                ),
              ),

              // ── Content ─────────────────────────────────────────────────
              SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    children: [
                      // Drag handle
                      Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Album Art ──────────────────────────────────────
                      _AlbumArt(
                        thumbUrl: song.thumbUrl,
                        isPlaying: streamProvider.isPlaying,
                        isBuffering: streamProvider.isBuffering,
                      ),
                      const SizedBox(height: 36),

                      // ── Title & Artist ─────────────────────────────────
                      Text(
                        song.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.heading.copyWith(
                          fontSize: 22,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        song.artists,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 36),

                      // ── Extra Controls ───────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.playlist_add_rounded,
                              color: Colors.white.withValues(alpha: 0.85),
                              size: 28,
                            ),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => AddToPlaylistSheet(song: song),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.queue_music_rounded,
                              color: Colors.white.withValues(alpha: 0.85),
                              size: 28,
                            ),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => const QueueSheet(),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── Seek Bar ─────────────────────────────────────────
                      ValueListenableBuilder<Duration>(
                        valueListenable: context
                            .read<MusicStreamProvider>()
                            .positionNotifier,
                        builder: (context, position, _) {
                          return RetroSeekBar(
                            position: position,
                            duration: streamProvider.duration,
                            onChanged: (pos) => streamProvider.seek(pos),
                          );
                        },
                      ),
                      const SizedBox(height: 32),

                      // ── Main Controls ────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ShuffleButton(streamProvider: streamProvider),
                          _ControlButton(
                            icon: HugeIcons.strokeRoundedPrevious,
                            onPressed: streamProvider.previous,
                            size: 28,
                          ),
                          _PlayPauseButton(
                            isPlaying: streamProvider.isPlaying,
                            isBuffering: streamProvider.isBuffering,
                            onPressed: streamProvider.togglePlayPause,
                          ),
                          _ControlButton(
                            icon: HugeIcons.strokeRoundedNext,
                            onPressed: streamProvider.next,
                            size: 28,
                          ),
                          _RepeatButton(streamProvider: streamProvider),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Album Art with subtle scale animation ─────────────────────────────────────

class _AlbumArt extends StatefulWidget {
  final String? thumbUrl;
  final bool isPlaying;
  final bool isBuffering;

  const _AlbumArt({
    required this.thumbUrl,
    required this.isPlaying,
    required this.isBuffering,
  });

  @override
  State<_AlbumArt> createState() => _AlbumArtState();
}

class _AlbumArtState extends State<_AlbumArt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: widget.isPlaying ? 1.0 : 0.0,
    );
    _scale = Tween<double>(
      begin: 0.88,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(covariant _AlbumArt oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _ctrl.forward();
      } else {
        _ctrl.reverse();
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.55),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Thumbnail
              widget.thumbUrl != null
                  ? Image.network(
                      widget.thumbUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _ArtPlaceholder(),
                    )
                  : _ArtPlaceholder(),

              // Buffering overlay
              if (widget.isBuffering)
                Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
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

class _ArtPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF3ECFCF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.music_note, color: Colors.white54, size: 80),
      ),
    );
  }
}

// ── Controls ──────────────────────────────────────────────────────────────────

class _ControlButton extends StatelessWidget {
  final dynamic icon;
  final VoidCallback? onPressed;
  final double size;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: HugeIcon(
        icon: icon,
        color: Colors.white.withValues(alpha: 0.85),
        size: size,
      ),
      onPressed: onPressed,
      padding: const EdgeInsets.all(12),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final bool isBuffering;
  final VoidCallback? onPressed;

  const _PlayPauseButton({
    required this.isPlaying,
    required this.isBuffering,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isBuffering ? null : onPressed,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.15),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.35),
              blurRadius: 24,
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isBuffering
              ? const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : HugeIcon(
                  key: ValueKey(isPlaying),
                  icon: isPlaying
                      ? HugeIcons.strokeRoundedPause
                      : HugeIcons.strokeRoundedPlay,
                  color: Colors.white,
                  size: 40,
                ),
        ),
      ),
    );
  }
}

class _ShuffleButton extends StatelessWidget {
  final MusicStreamProvider streamProvider;
  const _ShuffleButton({required this.streamProvider});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: HugeIcon(
        icon: HugeIcons.strokeRoundedShuffle,
        color: streamProvider.shuffle
            ? const Color(0xFF6C63FF)
            : Colors.white.withValues(alpha: 0.5),
        size: 24,
      ),
      onPressed: streamProvider.toggleShuffle,
      padding: const EdgeInsets.all(12),
    );
  }
}

class _RepeatButton extends StatelessWidget {
  final MusicStreamProvider streamProvider;
  const _RepeatButton({required this.streamProvider});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (streamProvider.repeatMode) {
      case RepeatMode.none:
        icon = Icons.repeat_rounded;
        color = Colors.white.withValues(alpha: 0.5);
        break;
      case RepeatMode.all:
        icon = Icons.repeat_rounded;
        color = const Color(0xFF6C63FF);
        break;
      case RepeatMode.one:
        icon = Icons.repeat_one_rounded;
        color = const Color(0xFF6C63FF);
        break;
    }

    return IconButton(
      icon: Icon(icon, color: color, size: 24),
      onPressed: streamProvider.toggleRepeatMode,
      padding: const EdgeInsets.all(12),
    );
  }
}
