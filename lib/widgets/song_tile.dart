import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/neumorphic.dart';
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
  late AnimationController _highlightController;
  late Animation<double> _highlightAnim;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _highlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _highlightAnim = CurvedAnimation(
      parent: _highlightController,
      curve: Curves.easeOut,
    );
    if (widget.isPlaying) _highlightController.forward();
  }

  @override
  void didUpdateWidget(SongTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _highlightController.forward();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _highlightController.reverse();
    }
  }

  @override
  void dispose() {
    _highlightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _highlightAnim,
      builder: (context, child) {
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
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: widget.isPlaying
                ? Neumorphic.raised(
                    radius: 16,
                    color: Color.lerp(
                      AppColors.background,
                      AppColors.primaryLight,
                      _highlightAnim.value,
                    )!,
                  )
                : _isPressed
                    ? Neumorphic.pressed(radius: 16)
                    : BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                      ),
            child: Row(
              children: [
                if (widget.index != null)
                  SizedBox(
                    width: 28,
                    child: widget.isPlaying
                        ? const SizedBox.shrink()
                        : Text(
                            '${widget.index! + 1}',
                            style: AppTypography.caption,
                            textAlign: TextAlign.center,
                          ),
                  ),
                _buildLeadingIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.song.title,
                        style: AppTypography.body.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: widget.isPlaying
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
                  style: AppTypography.caption.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeadingIcon() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      width: 44,
      height: 44,
      decoration: widget.isPlaying
          ? Neumorphic.raisedAccent(radius: 14, accent: AppColors.primary)
          : Neumorphic.raised(radius: 14),
      child: Center(
        child: widget.isPlaying
            ? AnimatedBars(
                isPlaying: true,
                width: 20,
                height: 20,
                color: Colors.white,
              )
            : Icon(
                Icons.music_note_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
      ),
    );
  }
}
