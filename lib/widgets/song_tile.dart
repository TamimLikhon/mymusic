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

  const SongTile({
    super.key,
    required this.song,
    this.onTap,
    this.onLongPress,
    this.index,
    this.isPlaying = false,
  });

  @override
  State<SongTile> createState() => _SongTileState();
}

class _SongTileState extends State<SongTile>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.seedGradient(widget.song.title);
    final isPlaying = widget.isPlaying;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      onLongPress: widget.onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _isPressed
              ? AppColors.surface
              : isPlaying
              ? AppColors.primaryFaint
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: isPlaying
              ? Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          children: [
            // Index or playing dot
            if (widget.index != null)
              SizedBox(
                width: 28,
                child: isPlaying
                    ? Center(
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : Text(
                        '${widget.index! + 1}',
                        style: AppTypography.caption.copyWith(
                          fontSize: 11,
                          color: AppColors.textDisabled,
                        ),
                        textAlign: TextAlign.center,
                      ),
              ),
            // Art thumbnail
            _SongTileArt(
              song: widget.song,
              colors: colors,
              isPlaying: isPlaying,
            ),
            const SizedBox(width: 12),
            // Song info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.song.title,
                    style: AppTypography.bodyMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isPlaying
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.song.artist,
                    style: AppTypography.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              formatDuration(widget.song.duration),
              style: AppTypography.caption.copyWith(
                fontSize: 11,
                color: AppColors.textDisabled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Song Tile Art ─────────────────────────────────────────────────────────────

class _SongTileArt extends StatefulWidget {
  final Song song;
  final List<Color> colors;
  final bool isPlaying;

  const _SongTileArt({
    required this.song,
    required this.colors,
    required this.isPlaying,
  });

  @override
  State<_SongTileArt> createState() => _SongTileArtState();
}

class _SongTileArtState extends State<_SongTileArt> {
  Future<Uint8List?>? _imageFuture;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant _SongTileArt old) {
    super.didUpdateWidget(old);
    if (old.song.id != widget.song.id ||
        old.song.custom_art_path != widget.song.custom_art_path) {
      _loadImage();
    }
  }

  void _loadImage() {
    // Prefer custom art set by user
    final customArt = widget.song.custom_art_path;
    if (customArt != null) {
      _imageFuture = Future.value(File(customArt).readAsBytesSync());
      return;
    }

    // Fallback: read embedded metadata art in a background isolate
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
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isPlaying
            ? [
                BoxShadow(
                  color: colors[0].withValues(alpha: 0.5),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: FutureBuilder<Uint8List?>(
        future: _imageFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            // Show actual art image
            return Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    snapshot.data!,
                    fit: BoxFit.cover,
                    cacheWidth: 120,
                    gaplessPlayback: true,
                  ),
                ),
                // Playing overlay
                if (isPlaying)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.45),
                      child: Center(
                        child: AnimatedBars(
                          isPlaying: true,
                          width: 20,
                          height: 20,
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }

          // Fallback: gradient + letter / animated bars
          return Center(
            child: isPlaying
                ? AnimatedBars(
                    isPlaying: true,
                    width: 20,
                    height: 20,
                    color: Colors.white.withValues(alpha: 0.9),
                  )
                : Text(
                    widget.song.title.isNotEmpty
                        ? widget.song.title[0].toUpperCase()
                        : '♪',
                    style: AppTypography.heading.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
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
