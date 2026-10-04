import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/utils/duration_formatter.dart';
import '../data/database/app_database.dart';
import 'animated_bars.dart';

class SongTile extends StatefulWidget {
  final Song song;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final int? index;
  final bool isPlaying;
  final Widget? trailing;

  const SongTile({
    super.key,
    required this.song,
    this.onTap,
    this.onLongPress,
    this.index,
    this.isPlaying = false,
    this.trailing,
  });

  @override
  State<SongTile> createState() => _SongTileState();
}

class _SongTileState extends State<SongTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.seedGradient(widget.song.title);
    final isPlaying = widget.isPlaying;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap?.call();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        onLongPress: widget.onLongPress,
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _isPressed
                  ? AppColors.glassFillStrong
                  : isPlaying
                      ? AppColors.primary.withValues(alpha: 0.14)
                      : AppColors.glassFill,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isPlaying
                    ? AppColors.primary.withValues(alpha: 0.6)
                    : _isPressed
                        ? AppColors.glassBorderStrong
                        : AppColors.glassBorder,
                width: isPlaying ? 1.2 : 0.8,
              ),
              boxShadow: isPlaying
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.22),
                        blurRadius: 18,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              children: [
                // Index or glowing playing indicator
                if (widget.index != null)
                  SizedBox(
                    width: 28,
                    child: isPlaying
                        ? Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.9),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Text(
                            '${widget.index! + 1}',
                            style: AppTypography.caption.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDisabled,
                            ),
                            textAlign: TextAlign.center,
                          ),
                  ),

                // Art thumbnail
                SongArtWidget(
                  song: widget.song,
                  colors: colors,
                  isPlaying: isPlaying,
                ),
                const SizedBox(width: 12),

                // Song info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.song.title,
                        style: AppTypography.bodyMedium.copyWith(
                          fontSize: 14,
                          fontWeight: isPlaying ? FontWeight.w700 : FontWeight.w600,
                          color: isPlaying
                              ? AppColors.primaryLight
                              : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.song.artist.isNotEmpty
                            ? widget.song.artist
                            : 'Unknown Artist',
                        style: AppTypography.caption.copyWith(
                          fontSize: 12,
                          color: isPlaying
                              ? AppColors.textSecondary
                              : AppColors.textDisabled,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Trailing duration, bars or custom widget
                if (widget.trailing != null)
                  widget.trailing!
                else if (isPlaying)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: AnimatedBars(
                      isPlaying: true,
                      width: 16,
                      height: 14,
                      color: AppColors.primaryLight,
                    ),
                  )
                else
                  Text(
                    formatDuration(widget.song.duration),
                    style: AppTypography.caption.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDisabled,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Song Tile Art ─────────────────────────────────────────────────────────────

class SongArtWidget extends StatefulWidget {
  final Song song;
  final List<Color> colors;
  final bool isPlaying;
  final double size;

  const SongArtWidget({
    super.key,
    required this.song,
    required this.colors,
    required this.isPlaying,
    this.size = 46,
  });

  @override
  State<SongArtWidget> createState() => _SongArtWidgetState();
}

class _SongArtWidgetState extends State<SongArtWidget> {
  Future<Uint8List?>? _imageFuture;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant SongArtWidget old) {
    super.didUpdateWidget(old);
    if (old.song.id != widget.song.id ||
        old.song.custom_art_path != widget.song.custom_art_path) {
      _loadImage();
    }
  }

  void _loadImage() {
    final customArt = widget.song.custom_art_path;
    if (customArt != null && File(customArt).existsSync()) {
      _imageFuture = File(customArt).readAsBytes();
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
    }, filePath);
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final isPlaying = widget.isPlaying;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPlaying
              ? AppColors.primary.withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.18),
          width: 1,
        ),
        boxShadow: isPlaying
            ? [
                BoxShadow(
                  color: colors[0].withValues(alpha: 0.45),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: FutureBuilder<Uint8List?>(
        future: _imageFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Image.memory(
                    snapshot.data!,
                    fit: BoxFit.cover,
                    cacheWidth: 120,
                    gaplessPlayback: true,
                  ),
                ),
                if (isPlaying)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.45),
                      child: Center(
                        child: AnimatedBars(
                          isPlaying: true,
                          width: 18,
                          height: 18,
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }

          return Center(
            child: isPlaying
                ? AnimatedBars(
                    isPlaying: true,
                    width: 18,
                    height: 18,
                    color: Colors.white.withValues(alpha: 0.95),
                  )
                : Text(
                    widget.song.title.isNotEmpty
                        ? widget.song.title[0].toUpperCase()
                        : '♪',
                    style: AppTypography.heading.copyWith(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
          );
        },
      ),
    );
  }
}
