import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Animated 3-bar equalizer indicator shown on the currently-playing song tile.
/// Each bar has an independent staggered AnimationController so the motion
/// looks organic and musical rather than mechanical.
class AnimatedBars extends StatefulWidget {
  final bool isPlaying;
  final double width;
  final double height;
  final Color? color;

  const AnimatedBars({
    super.key,
    required this.isPlaying,
    this.width = 20,
    this.height = 20,
    this.color,
  });

  @override
  State<AnimatedBars> createState() => _AnimatedBarsState();
}

class _AnimatedBarsState extends State<AnimatedBars>
    with TickerProviderStateMixin {
  // Three bars with different durations for an organic feel
  static const _durations = [420, 600, 510];
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: _durations[i]),
      );
    });

    _animations = _controllers.map((c) {
      return Tween<double>(begin: 0.15, end: 1.0).animate(
        CurvedAnimation(parent: c, curve: Curves.easeInOut),
      );
    }).toList();

    if (widget.isPlaying) {
      _startAll();
    }
  }

  void _startAll() {
    // Stagger the starts so bars don't all move in unison
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 80), () {
        if (mounted && _controllers[i].status != AnimationStatus.completed) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  void _stopAll() {
    for (final c in _controllers) {
      c.stop();
    }
  }

  @override
  void didUpdateWidget(AnimatedBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _startAll();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _stopAll();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final barColor = widget.color ??
        (widget.isPlaying ? AppColors.primary : AppColors.textSecondary);
    final barWidth = (widget.width - 4) / 3; // 3 bars + 2 gaps of 2px each

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(3, (i) {
          return AnimatedBuilder(
            animation: _animations[i],
            builder: (context, _) {
              final frac = widget.isPlaying ? _animations[i].value : 0.25;
              return Container(
                width: barWidth,
                height: widget.height * frac,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: widget.isPlaying
                      ? [
                          BoxShadow(
                            color: barColor.withValues(alpha: 0.5),
                            blurRadius: 4,
                          )
                        ]
                      : null,
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
