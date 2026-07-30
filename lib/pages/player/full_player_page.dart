import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/glass_card.dart';
import '../../providers/audio_provider.dart';
import '../../data/database/app_database.dart';
import '../../data/models/queue_state.dart' as queue;
import '../../services/custom_art_service.dart';
import '../../widgets/retro_seek_bar.dart';
import '../../widgets/assign_tag_sheet.dart';

class FullPlayerPage extends StatelessWidget {
  const FullPlayerPage({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => const FullPlayerPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, _) {
        final song = audioProvider.currentSong;

        if (song == null) {
          return Container(
            height: 200,
            decoration: const BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Center(
              child: Text('No song playing', style: AppTypography.caption),
            ),
          );
        }

        final colors = AppColors.seedGradient(song.title);

        return Container(
          height: MediaQuery.of(context).size.height * 0.93,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Stack(
            children: [
              // Ambient gradient background
              _AmbientBackground(colors: colors),

              // Content
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    _buildHandle(context),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          // Art card
                          _buildArtCard(audioProvider, colors, song),
                          const SizedBox(height: 28),
                          // Song info
                          _buildSongInfo(song.title, song.artist, song.album),
                          const SizedBox(height: 24),
                          // Seek bar
                          _buildSeekBar(audioProvider),
                          const SizedBox(height: 20),
                          // Controls
                          _buildControls(audioProvider),
                          const SizedBox(height: 20),
                          // Extra actions
                          _buildExtraActions(context, song),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          const Spacer(),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.surfaceBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: GlassCard.card(radius: 10),
              child: const HugeIcon(
                icon: HugeIcons.strokeRoundedArrowDown01,
                color: AppColors.textSecondary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtCard(
    AudioProvider audioProvider,
    List<Color> colors,
    dynamic song,
  ) {
    return _SongArtCard(
      audioProvider: audioProvider,
      colors: colors,
      song: song,
    );
  }

  Widget _buildSongInfo(String title, String artist, String album) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.playerTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  artist,
                  style: AppTypography.playerArtist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (album != 'Unknown') ...[
                  const SizedBox(height: 2),
                  Text(
                    album,
                    style: AppTypography.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeekBar(AudioProvider audioProvider) {
    return ValueListenableBuilder<Duration>(
      valueListenable: audioProvider.positionNotifier,
      builder: (context, position, _) {
        return RetroSeekBar(
          position: position,
          duration: audioProvider.duration,
          onChangeEnd: (newPosition) => audioProvider.seek(newPosition),
        );
      },
    );
  }

  Widget _buildControls(AudioProvider audioProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Shuffle
          _ControlIcon(
            icon: audioProvider.queueState.isShuffled
                ? HugeIcons.strokeRoundedShuffle
                : HugeIcons.strokeRoundedShuffle,
            onTap: audioProvider.toggleShuffle,
            isActive: audioProvider.queueState.isShuffled,
          ),
          // Previous
          _ControlIcon(
            icon: HugeIcons.strokeRoundedPrevious,
            onTap: audioProvider.previous,
            size: 32,
          ),
          // Play/Pause — large
          _BigPlayPause(
            isPlaying: audioProvider.isPlaying,
            isLoading: audioProvider.isLoading,
            onPressed: audioProvider.togglePlayPause,
          ),
          // Next
          _ControlIcon(
            icon: HugeIcons.strokeRoundedNext,
            onTap: audioProvider.next,
            size: 32,
          ),
          // Repeat
          _ControlIcon(
            icon: _getRepeatIcon(audioProvider.queueState.repeatMode),
            onTap: audioProvider.toggleRepeat,
            isActive:
                audioProvider.queueState.repeatMode != queue.RepeatMode.none,
          ),
        ],
      ),
    );
  }

  dynamic _getRepeatIcon(queue.RepeatMode mode) {
    switch (mode) {
      case queue.RepeatMode.none:
        return HugeIcons.strokeRoundedRepeat;
      case queue.RepeatMode.all:
        return HugeIcons.strokeRoundedRepeat;
      case queue.RepeatMode.one:
        return HugeIcons.strokeRoundedRepeatOne01;
    }
  }

  Widget _buildExtraActions(BuildContext context, dynamic song) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _TextAction(
            icon: HugeIcons.strokeRoundedTag01,
            label: 'Tag',
            onTap: () => AssignTagSheet.show(
              context,
              song.id as String,
              song.title as String,
            ),
          ),
          _TextAction(
            icon: HugeIcons.strokeRoundedImage01,
            label: 'Art',
            onTap: () => _setCustomArt(context, song),
          ),
          _TextAction(
            icon: HugeIcons.strokeRoundedPlaylist01,
            label: 'Queue',
            onTap: () => _showQueueSheet(context),
          ),
        ],
      ),
    );
  }

  Future<void> _setCustomArt(BuildContext context, dynamic song) async {
    final db = context.read<AppDatabase>();
    final service = CustomArtService(db);
    final path = await service.pickAndSetArt(song.id as String);
    if (path != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Thumbnail set for ${song.title}'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _showQueueSheet(BuildContext context) {
    final audioProvider = context.read<AudioProvider>();
    final q = audioProvider.queueState.queue;
    final currentIndex = audioProvider.queueState.currentIndex;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 14, bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: GlassCard.card(radius: 10),
                        child: const HugeIcon(
                          icon: HugeIcons.strokeRoundedPlaylist01,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('Up Next', style: AppTypography.heading),
                      const Spacer(),
                      Text('${q.length} songs', style: AppTypography.caption),
                    ],
                  ),
                ),
                Divider(height: 1, color: AppColors.divider),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: q.length,
                    itemBuilder: (context, index) {
                      final s = q[index];
                      final isCurrent = index == currentIndex;
                      final colors = AppColors.seedGradient(s.title);
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: colors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: isCurrent
                                ? Border.all(color: AppColors.primary, width: 2)
                                : null,
                          ),
                          child: Center(
                            child: isCurrent
                                ? const HugeIcon(
                                    icon: HugeIcons.strokeRoundedMusicNote01,
                                    size: 18,
                                    color: Colors.white,
                                  )
                                : Text(
                                    s.title.isNotEmpty
                                        ? s.title[0].toUpperCase()
                                        : '♪',
                                    style: AppTypography.heading.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                        title: Text(
                          s.title,
                          style: AppTypography.bodyMedium.copyWith(
                            fontSize: 13,
                            color: isCurrent
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          s.artist,
                          style: AppTypography.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: isCurrent
                            ? const HugeIcon(
                                icon: HugeIcons.strokeRoundedMusicNote01,
                                color: AppColors.primary,
                                size: 18,
                              )
                            : Text(
                                '${index + 1}',
                                style: AppTypography.caption,
                              ),
                        onTap: () {
                          context.read<AudioProvider>().jumpToQueueIndex(index);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ── Ambient Background ────────────────────────────────────────────────────────

class _AmbientBackground extends StatelessWidget {
  final List<Color> colors;
  const _AmbientBackground({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: Stack(
          children: [
            // Base dark
            Container(color: AppColors.background),
            // Top-left blob
            Positioned(
              top: -60,
              left: -80,
              child: _GlowBlob(color: colors[0], size: 280),
            ),
            // Bottom-right blob
            Positioned(
              bottom: 40,
              right: -60,
              child: _GlowBlob(color: colors[1], size: 220),
            ),
            // Overlay darken
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background.withValues(alpha: 0.55),
                    AppColors.background.withValues(alpha: 0.90),
                    AppColors.background,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.28),
            blurRadius: size * 0.7,
            spreadRadius: size * 0.1,
          ),
        ],
      ),
    );
  }
}

// ── Static Vinyl Icon (compact) ─────────────────────────────────────────────

class _StaticVinylIcon extends StatelessWidget {
  const _StaticVinylIcon();

  @override
  Widget build(BuildContext context) {
    return HugeIcon(
      icon: HugeIcons.strokeRoundedMusicNote02,
      size: 100,
      color: Colors.white.withValues(alpha: 0.35),
    );
  }
}

// ── Song Art Card ─────────────────────────────────────────────────────────────

class _SongArtCard extends StatefulWidget {
  final AudioProvider audioProvider;
  final List<Color> colors;
  final dynamic song;

  const _SongArtCard({
    required this.audioProvider,
    required this.colors,
    required this.song,
  });

  @override
  State<_SongArtCard> createState() => _SongArtCardState();
}

class _SongArtCardState extends State<_SongArtCard> {
  Future<Uint8List?>? _imageFuture;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant _SongArtCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.song.id != widget.song.id ||
        oldWidget.song.custom_art_path != widget.song.custom_art_path) {
      _loadImage();
    }
  }

  void _loadImage() {
    final customArt = widget.song.custom_art_path as String?;
    if (customArt != null) {
      _imageFuture = Future.value(File(customArt).readAsBytesSync());
      return;
    }
    final filePath = widget.song.file_path;
    _imageFuture = compute((path) {
      try {
        final metadata = readMetadata(File(path), getImage: true);
        final pictures = metadata.pictures;
        if (pictures.isNotEmpty) {
          return pictures.first.bytes;
        }
      } catch (_) {}
      return null;
    }, filePath as String);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: AspectRatio(
        aspectRatio: 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.colors[0].withValues(alpha: 0.4),
                blurRadius: 40,
                offset: const Offset(0, 20),
                spreadRadius: -8,
              ),
            ],
          ),
          child: FutureBuilder<Uint8List?>(
            future: _imageFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.memory(snapshot.data!, fit: BoxFit.cover),
                );
              }

              // Fallback if no image or still loading
              return Center(
                child: widget.audioProvider.isPlaying
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [_StaticVinylIcon()],
                      )
                    : Text(
                        widget.song.title.isNotEmpty
                            ? widget.song.title[0].toUpperCase()
                            : '♪',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 96,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Control Icons ─────────────────────────────────────────────────────────────

class _ControlIcon extends StatefulWidget {
  final dynamic icon;
  final VoidCallback? onTap;
  final double size;
  final bool isActive;

  const _ControlIcon({
    required this.icon,
    this.onTap,
    this.size = 24,
    this.isActive = false,
  });

  @override
  State<_ControlIcon> createState() => _ControlIconState();
}

class _ControlIconState extends State<_ControlIcon> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedOpacity(
        opacity: _pressed ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: HugeIcon(
            icon: widget.icon,
            size: widget.size,
            color: widget.isActive
                ? AppColors.primary
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ── Big Play/Pause ────────────────────────────────────────────────────────────

class _BigPlayPause extends StatefulWidget {
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _BigPlayPause({
    required this.isPlaying,
    required this.isLoading,
    this.onPressed,
  });

  @override
  State<_BigPlayPause> createState() => _BigPlayPauseState();
}

class _BigPlayPauseState extends State<_BigPlayPause>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.9,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _scaleCtrl;
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleCtrl.reverse(),
      onTapUp: (_) {
        _scaleCtrl.forward();
        widget.onPressed?.call();
      },
      onTapCancel: () => _scaleCtrl.forward(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.2),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: widget.isLoading
              ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.background,
                    ),
                  ),
                )
              : Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: HugeIcon(
                      icon: widget.isPlaying
                          ? HugeIcons.strokeRoundedPause
                          : HugeIcons.strokeRoundedPlay,
                      key: ValueKey(widget.isPlaying),
                      size: 38,
                      color: AppColors.background,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

// ── Text Action ───────────────────────────────────────────────────────────────

class _TextAction extends StatelessWidget {
  final dynamic icon;
  final String label;
  final VoidCallback? onTap;

  const _TextAction({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: GlassCard.card(radius: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(icon: icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
