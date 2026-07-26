import 'package:flutter/material.dart';

class NoiseOverlay extends StatelessWidget {
  final Widget child;
  final double opacity;

  const NoiseOverlay({
    super.key,
    required this.child,
    this.opacity = 0.03,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: opacity,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/noise_texture.png'),
                    fit: BoxFit.cover,
                    repeat: ImageRepeat.repeat,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
