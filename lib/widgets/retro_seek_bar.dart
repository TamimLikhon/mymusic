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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Neumorphic track container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight, // changed from background to make it slightly visible
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadowDark,
                      offset: Offset(2, 2),
                      blurRadius: 4,
                    ),
                    BoxShadow(
                      color: AppColors.shadowLight,
                      offset: Offset(-2, -2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                clipBehavior: Clip.hardEdge,
                child: duration > 0
                    ? FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (position / duration).clamp(0.0, 1.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primary, AppColors.accent],
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            // Invisible slider on top for interaction
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.transparent,
                inactiveTrackColor: Colors.transparent,
                thumbColor: AppColors.primary,
                thumbShape: _NeuThumbShape(),
                trackHeight: 8,
                overlayColor: AppColors.primary.withValues(alpha: 0.15),
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
          ],
        ),
        // Time labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatDuration(position.toInt()),
                style: AppTypography.caption,
              ),
              Text(
                formatDuration(widget.duration.inMilliseconds),
                style: AppTypography.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NeuThumbShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(18, 18);

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

    // Dark shadow
    canvas.drawCircle(
      center + const Offset(3, 3),
      10,
      Paint()..color = AppColors.shadowDark,
    );
    // Light shadow
    canvas.drawCircle(
      center + const Offset(-3, -3),
      10,
      Paint()..color = AppColors.shadowLight,
    );
    // Base circle
    canvas.drawCircle(center, 10, Paint()..color = AppColors.background);
    // Accent dot
    canvas.drawCircle(
      center,
      5,
      Paint()
        ..shader = RadialGradient(
          colors: [AppColors.primary, AppColors.accent],
        ).createShader(Rect.fromCircle(center: center, radius: 5)),
    );
  }
}
