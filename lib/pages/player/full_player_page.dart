import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/neumorphic.dart';
import '../../providers/audio_provider.dart';
import '../../data/models/queue_state.dart' as queue;
import '../../widgets/vinyl_spinner.dart';
import '../../widgets/retro_seek_bar.dart';
import '../../widgets/assign_tag_sheet.dart';

class FullPlayerPage extends StatelessWidget {
  const FullPlayerPage({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FullPlayerPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Consumer<AudioProvider>(
        builder: (context, audioProvider, _) {
          final song = audioProvider.currentSong;

          if (song == null) {
            return Center(
              child: Text('No song playing', style: AppTypography.caption),
            );
          }

          return Column(
            children: [
              _buildHandle(context),
              const SizedBox(height: 8),
              _buildVinylSection(audioProvider),
              const SizedBox(height: 20),
              _buildSongInfo(song.title, song.artist, song.album),
              const SizedBox(height: 20),
              _buildSeekBar(audioProvider),
              const SizedBox(height: 16),
              _buildControls(audioProvider),
              const SizedBox(height: 20),
              _buildExtraActions(context, song.id, song.title),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHandle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, left: 16, right: 4),
      child: Row(
        children: [
          const Spacer(),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const Spacer(),
          _NeuIconBtn(
            icon: Icons.keyboard_arrow_down_rounded,
            onTap: () => Navigator.of(context).pop(),
            size: 26,
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildVinylSection(AudioProvider audioProvider) {
    return Expanded(
      flex: 3,
      child: Center(
        child: Container(
          decoration: Neumorphic.raisedCircle(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: VinylSpinner(
              isPlaying: audioProvider.isPlaying,
              size: 220,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSongInfo(String title, String artist, String album) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        children: [
          Text(
            title,
            style: AppTypography.heading.copyWith(fontSize: 17),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            artist,
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (album != 'Unknown') ...[
            const SizedBox(height: 4),
            Text(
              album,
              style: AppTypography.caption,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSeekBar(AudioProvider audioProvider) {
    return RetroSeekBar(
      position: audioProvider.position,
      duration: audioProvider.duration,
      onChangeEnd: (position) => audioProvider.seek(position),
    );
  }

  Widget _buildControls(AudioProvider audioProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NeuIconBtn(
            icon: audioProvider.queueState.isShuffled
                ? Icons.shuffle_on_rounded
                : Icons.shuffle_rounded,
            onTap: audioProvider.toggleShuffle,
            isActive: audioProvider.queueState.isShuffled,
          ),
          _NeuIconBtn(
            icon: Icons.skip_previous_rounded,
            onTap: audioProvider.previous,
            size: 30,
          ),
          _PlayPauseButton(
            isPlaying: audioProvider.isPlaying,
            isLoading: audioProvider.isLoading,
            onPressed: audioProvider.togglePlayPause,
          ),
          _NeuIconBtn(
            icon: Icons.skip_next_rounded,
            onTap: audioProvider.next,
            size: 30,
          ),
          _NeuIconBtn(
            icon: _getRepeatIcon(audioProvider.queueState.repeatMode),
            onTap: audioProvider.toggleRepeat,
            isActive: audioProvider.queueState.repeatMode != queue.RepeatMode.none,
          ),
        ],
      ),
    );
  }

  IconData _getRepeatIcon(queue.RepeatMode mode) {
    switch (mode) {
      case queue.RepeatMode.none:
        return Icons.repeat_rounded;
      case queue.RepeatMode.all:
        return Icons.repeat_on_rounded;
      case queue.RepeatMode.one:
        return Icons.repeat_one_on_rounded;
    }
  }

  Widget _buildExtraActions(BuildContext context, String songId, String songTitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NeuTextAction(
            icon: Icons.label_outline_rounded,
            label: 'Tag',
            onTap: () => AssignTagSheet.show(context, songId, songTitle),
          ),
          _NeuTextAction(
            icon: Icons.queue_music_rounded,
            label: 'Queue',
            onTap: () => _showQueueSheet(context),
          ),
        ],
      ),
    );
  }

  void _showQueueSheet(BuildContext context) {
    final audioProvider = context.read<AudioProvider>();
    final q = audioProvider.queueState.queue;
    final currentIndex = audioProvider.queueState.currentIndex;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
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
                  width: 44,
                  height: 5,
                  margin: const EdgeInsets.only(top: 14, bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: Neumorphic.raised(radius: 10),
                        child: const Icon(
                          Icons.queue_music_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('Up Next',
                          style: AppTypography.heading.copyWith(fontSize: 15)),
                      const Spacer(),
                      Text('${q.length} songs',
                          style: AppTypography.caption),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: q.length,
                    itemBuilder: (context, index) {
                      final song = q[index];
                      final isCurrent = index == currentIndex;
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 2),
                        leading: Container(
                          width: 38,
                          height: 38,
                          decoration: isCurrent
                              ? Neumorphic.raisedAccent(
                                  radius: 10, accent: AppColors.primary)
                              : Neumorphic.raised(radius: 10),
                          child: Icon(
                            isCurrent
                                ? Icons.equalizer_rounded
                                : Icons.music_note_rounded,
                            size: 18,
                            color: isCurrent
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                        title: Text(
                          song.title,
                          style: AppTypography.body.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isCurrent
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          song.artist,
                          style: AppTypography.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: isCurrent
                            ? const Icon(Icons.graphic_eq_rounded,
                                color: AppColors.primary, size: 18)
                            : Text(
                                '${index + 1}',
                                style: AppTypography.caption,
                              ),
                        onTap: () {
                          context
                              .read<AudioProvider>()
                              .jumpToQueueIndex(index);
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

// ── Neumorphic icon button ────────────────────────────────────────────────────

class _NeuIconBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final bool isActive;

  const _NeuIconBtn({
    required this.icon,
    this.onTap,
    this.size = 24,
    this.isActive = false,
  });

  @override
  State<_NeuIconBtn> createState() => _NeuIconBtnState();
}

class _NeuIconBtnState extends State<_NeuIconBtn> {
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 48,
        height: 48,
        decoration: _pressed
            ? Neumorphic.pressed(radius: 14)
            : Neumorphic.raised(radius: 14),
        child: Icon(
          widget.icon,
          size: widget.size,
          color: widget.isActive ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ── Play/Pause big button ─────────────────────────────────────────────────────

class _PlayPauseButton extends StatefulWidget {
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _PlayPauseButton({
    required this.isPlaying,
    required this.isLoading,
    this.onPressed,
  });

  @override
  State<_PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<_PlayPauseButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (widget.isLoading) _pulseController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_PlayPauseButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _pulseController.stop();
      _pulseController.animateTo(1.0);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 72,
            height: 72,
            decoration: _pressed
                ? Neumorphic.pressed(radius: 36, color: AppColors.background)
                : Neumorphic.raisedAccent(
                    radius: 36, accent: AppColors.primary),
            child: child,
          );
        },
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            transitionBuilder: (child, anim) => ScaleTransition(
              scale: anim,
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: Icon(
              widget.isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              key: ValueKey(widget.isPlaying),
              size: 36,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Text action button ────────────────────────────────────────────────────────

class _NeuTextAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _NeuTextAction({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: Neumorphic.raised(radius: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(label, style: AppTypography.body.copyWith(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
