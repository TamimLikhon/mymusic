import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/neumorphic.dart';

class RetroButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color? color;
  final bool isSmall;

  const RetroButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.color,
    this.isSmall = false,
  });

  @override
  State<RetroButton> createState() => _RetroButtonState();
}

class _RetroButtonState extends State<RetroButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.color ?? AppColors.primary;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: EdgeInsets.symmetric(
          horizontal: widget.isSmall ? 14 : 22,
          vertical: widget.isSmall ? 9 : 13,
        ),
        decoration: _isPressed
            ? Neumorphic.pressed(
                radius: widget.isSmall ? 14 : 22,
                color: AppColors.background,
              )
            : Neumorphic.raisedAccent(
                radius: widget.isSmall ? 14 : 22,
                accent: accent,
              ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                size: widget.isSmall ? 16 : 20,
                color: Colors.white,
              ),
              SizedBox(width: widget.isSmall ? 6 : 10),
            ],
            Text(
              widget.label,
              style: AppTypography.body.copyWith(
                fontSize: widget.isSmall ? 12 : 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
