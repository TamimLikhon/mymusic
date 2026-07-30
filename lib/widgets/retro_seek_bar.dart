import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/duration_formatter.dart';

class RetroSeekBar extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;

  const RetroSeekBar({
    super.key,
    required this.position,
    required this.duration,
    this.onChanged,
    this.onChangeEnd,
  });

  @override
  State<RetroSeekBar> createState() => _RetroSeekBarState();
}

class _RetroSeekBarState extends State<RetroSeekBar> {
  bool _isDragging = false;
  double _dragValue = 0;

  @override
  Widget build(BuildContext context) {
    final duration = widget.duration.inMilliseconds.toDouble();
    final position = _isDragging
        ? _dragValue
        : widget.position.inMilliseconds.toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.surfaceBorder,
              thumbColor: Colors.white,
              thumbShape: _SpotifyThumb(),
              trackHeight: 3,
              overlayColor: AppColors.primary.withValues(alpha: 0.2),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              trackShape: const RoundedRectSliderTrackShape(),
            ),
            child: Slider(
              min: 0,
              max: duration > 0 ? duration : 1,
              value: position.clamp(0, duration > 0 ? duration : 1),
              onChangeStart: (value) {
                setState(() {
                  _isDragging = true;
                  _dragValue = value;
                });
              },
              onChanged: (value) {
                setState(() => _dragValue = value);
                widget.onChanged?.call(Duration(milliseconds: value.toInt()));
              },
              onChangeEnd: (value) {
                setState(() => _isDragging = false);
                widget.onChangeEnd?.call(Duration(milliseconds: value.toInt()));
              },
            ),
          ),
          // Time labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatDuration(position.toInt()),
                  style: AppTypography.caption.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  formatDuration(widget.duration.inMilliseconds),
                  style: AppTypography.caption.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpotifyThumb extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(14, 14);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final radius = 7.0 + 3.0 * activationAnimation.value;

    // Subtle shadow
    canvas.drawCircle(
      center + const Offset(0, 2),
      radius,
      Paint()..color = Colors.black.withValues(alpha: 0.3),
    );
    // White circle
    canvas.drawCircle(center, radius, Paint()..color = Colors.white);
  }
}
