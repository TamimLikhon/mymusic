import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class VinylSpinner extends StatefulWidget {
  final bool isPlaying;
  final double size;

  const VinylSpinner({
    super.key,
    required this.isPlaying,
    this.size = 280,
  });

  @override
  State<VinylSpinner> createState() => _VinylSpinnerState();
}

class _VinylSpinnerState extends State<VinylSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 6-second period → realistic vinyl RPM feel
    _controller = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(VinylSpinner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_controller.isAnimating) {
      // Resume from the exact angle where we paused — no snap-back
      _controller.repeat();
    } else if (!widget.isPlaying && _controller.isAnimating) {
      // Stop but keep the current value so the disc stays at its last position
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // AnimatedBuilder rebuilds only what's needed — no setState on every tick
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final rotation = _controller.value * 2 * pi;
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _VinylPainter(
              rotation: rotation,
              isPlaying: widget.isPlaying,
            ),
          ),
        );
      },
    );
  }
}

class _VinylPainter extends CustomPainter {
  final double rotation;
  final bool isPlaying;

  _VinylPainter({required this.rotation, required this.isPlaying});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer glow (drawn BEFORE the disc so it sits behind)
    if (isPlaying) {
      final glowPaint = Paint()
        ..color = AppColors.primary.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
      canvas.drawCircle(center, radius + 12, glowPaint);
    }

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);

    // Main vinyl body
    final bodyPaint = Paint()..color = const Color(0xFF2D3250);
    canvas.drawCircle(center, radius - 2, bodyPaint);

    // Outer rim highlight
    final rimPaint = Paint()
      ..color = const Color(0xFF424872)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius - 2, rimPaint);

    // Vinyl grooves — subtle concentric rings
    final groovePaint = Paint()
      ..color = const Color(0xFF3D4470)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    for (double r = 36; r < radius - 18; r += 7) {
      canvas.drawCircle(center, r, groovePaint);
    }

    // Shiny reflection arc (top-left quadrant)
    final reflectionPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.4),
        radius: 0.9,
        colors: [
          Colors.white.withValues(alpha: 0.07),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius - 2, reflectionPaint);

    // Label area (center disc)
    final labelGradient = RadialGradient(
      colors: [
        AppColors.primary,
        AppColors.accent,
      ],
    );
    final labelPaint = Paint()
      ..shader = labelGradient.createShader(
          Rect.fromCircle(center: center, radius: 36));
    canvas.drawCircle(center, 36, labelPaint);

    // Label inner rings
    final labelRingPaint = Paint()
      ..color = AppColors.background.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, 30, labelRingPaint);
    canvas.drawCircle(center, 22, labelRingPaint);

    // Decorative lines on label
    final linePaint = Paint()
      ..color = AppColors.background.withValues(alpha: 0.5)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    for (int i = -2; i <= 2; i++) {
      canvas.drawLine(
        Offset(center.dx - 14, center.dy + i * 4.5),
        Offset(center.dx + 14, center.dy + i * 4.5),
        linePaint,
      );
    }

    // Center spindle hole
    final holePaint = Paint()..color = AppColors.background;
    canvas.drawCircle(center, 5, holePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _VinylPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.isPlaying != isPlaying;
  }
}
