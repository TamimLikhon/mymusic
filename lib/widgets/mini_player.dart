import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../providers/audio_provider.dart';
import '../pages/player/full_player_page.dart';
import 'animated_bars.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, _) {
        final song = audioProvider.currentSong;

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
          child: song == null || !audioProvider.isLocalSessionActive
              ? const SizedBox.shrink(key: Key('mini_player_empty'))
              : _MiniPlayerContent(
                  key: const Key('mini_player_active'),
                  audioProvider: audioProvider,
                  song: song,
                ),
        );
      },
    );
  }
}

class _MiniPlayerContent extends StatelessWidget {
  final AudioProvider audioProvider;
  final dynamic song;

  const _MiniPlayerContent({
    super.key,
    required this.audioProvider,
    required this.song,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.seedGradient(song.title as String);

    return Dismissible(
      key: const Key('mini_player_dismissible'),
      direction: DismissDirection.down,
      onDismissed: (_) => audioProvider.stop(),
      child: GestureDetector(
        onTap: () => FullPlayerPage.show(context),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(0),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.95),
                border: Border(
                  top: BorderSide(color: AppColors.surfaceBorder, width: 1),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress line at the very top
                  Stack(
                    children: [
                      Container(height: 2, color: AppColors.surfaceBorder),
                      ValueListenableBuilder<Duration>(
                        valueListenable: audioProvider.positionNotifier,
                        builder: (context, position, _) {
                          final progress =
                              audioProvider.duration.inMilliseconds > 0
                              ? (position.inMilliseconds /
                                        audioProvider.duration.inMilliseconds)
                                    .clamp(0.0, 1.0)
                              : 0.0;
                          return FractionallySizedBox(
                            widthFactor: progress,
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: colors),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 10, 12),
                    child: Row(
                      children: [
                        // Album art
                        _MiniPlayerArt(
                          song: song,
                          colors: colors,
                          audioProvider: audioProvider,
                        ),
                        const SizedBox(width: 12),
                        // Song info
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title as String,
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                song.artist as String,
                                style: AppTypography.caption,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Controls
                        _FlatIconButton(
                          icon: HugeIcons.strokeRoundedPrevious,
                          onPressed: audioProvider.previous,
                          size: 22,
                          tooltip: 'Previous',
                        ),
                        _PlayPauseBtn(
                          isPlaying: audioProvider.isPlaying,
                          onPressed: audioProvider.togglePlayPause,
                          colors: colors,
                        ),
                        _FlatIconButton(
                          icon: HugeIcons.strokeRoundedNext,
                          onPressed: audioProvider.next,
                          size: 22,
                          tooltip: 'Next',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FlatIconButton extends StatelessWidget {
  final dynamic icon;
  final VoidCallback? onPressed;
  final double size;
  final String? tooltip;

  const _FlatIconButton({
    required this.icon,
    this.onPressed,
    this.size = 22,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: HugeIcon(icon: icon, size: size, color: AppColors.textSecondary),
      onPressed: onPressed,
      tooltip: tooltip,
      splashRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
    );
  }
}

class _PlayPauseBtn extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback? onPressed;
  final List<Color> colors;

  const _PlayPauseBtn({
    required this.isPlaying,
    required this.colors,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isPlaying ? 'Pause' : 'Play',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: colors[0].withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            splashColor: Colors.white24,
            child: SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: HugeIcon(
                    icon: isPlaying
                        ? HugeIcons.strokeRoundedPause
                        : HugeIcons.strokeRoundedPlay,
                    key: ValueKey(isPlaying),
                    size: 22,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Mini Player Art ──────────────────────────────────────────────────────────

class _MiniPlayerArt extends StatefulWidget {
  final dynamic song;
  final List<Color> colors;
  final AudioProvider audioProvider;

  const _MiniPlayerArt({
    required this.song,
    required this.colors,
    required this.audioProvider,
  });

  @override
  State<_MiniPlayerArt> createState() => _MiniPlayerArtState();
}

class _MiniPlayerArtState extends State<_MiniPlayerArt> {
  Future<Uint8List?>? _imageFuture;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant _MiniPlayerArt oldWidget) {
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
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: FutureBuilder<Uint8List?>(
        future: _imageFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
                cacheWidth: 150,
              ),
            );
          }

          // Fallback if no image or still loading
          return Center(
            child: widget.audioProvider.isPlaying
                ? AnimatedBars(
                    isPlaying: true,
                    width: 18,
                    height: 18,
                    color: Colors.white.withValues(alpha: 0.9),
                  )
                : Text(
                    (widget.song.title as String).isNotEmpty
                        ? (widget.song.title as String)[0].toUpperCase()
                        : '♪',
                    style: AppTypography.heading.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          );
        },
      ),
    );
  }
}
