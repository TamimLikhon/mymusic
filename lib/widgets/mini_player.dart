import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/neumorphic.dart';
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
        if (song == null) return const SizedBox.shrink();

        return Dismissible(
          key: const Key('mini_player'),
          direction: DismissDirection.down,
          onDismissed: (_) => audioProvider.stop(),
          child: GestureDetector(
            onTap: () => FullPlayerPage.show(context),
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              decoration: Neumorphic.raised(radius: 20),
              padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Album art / animated bars
                      Container(
                        width: 46,
                        height: 46,
                        decoration: Neumorphic.raisedCircle(),
                        child: Center(
                          child: audioProvider.isPlaying
                              ? AnimatedBars(
                                  isPlaying: true,
                                  width: 18,
                                  height: 18,
                                )
                              : Icon(
                                  Icons.music_note_rounded,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Song info
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              style: AppTypography.body.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              song.artist,
                              style: AppTypography.caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Controls
                      _NeuIconButton(
                        icon: Icons.skip_previous_rounded,
                        onPressed: audioProvider.previous,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      _NeuIconButton(
                        icon: audioProvider.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        onPressed: audioProvider.togglePlayPause,
                        isAccent: true,
                        size: 22,
                      ),
                      const SizedBox(width: 4),
                      _NeuIconButton(
                        icon: Icons.skip_next_rounded,
                        onPressed: audioProvider.next,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Progress bar
                  if (audioProvider.duration.inMilliseconds > 0)
                    _NeuProgressBar(
                      value: audioProvider.position.inMilliseconds /
                          audioProvider.duration.inMilliseconds,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NeuIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final bool isAccent;

  const _NeuIconButton({
    required this.icon,
    this.onPressed,
    this.size = 20,
    this.isAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: isAccent ? 42 : 36,
        height: isAccent ? 42 : 36,
        decoration: isAccent
            ? Neumorphic.raisedAccent(radius: 50, accent: AppColors.primary)
            : Neumorphic.raisedCircle(),
        child: Icon(
          icon,
          size: size,
          color: isAccent ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _NeuProgressBar extends StatelessWidget {
  final double value;
  const _NeuProgressBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.shadowDark,
        borderRadius: BorderRadius.circular(2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            offset: Offset(0, -1),
            blurRadius: 2,
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.accent],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
