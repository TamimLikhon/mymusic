import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/glass_card.dart';

/// Modern action button replacing the old neumorphic RetroButton.
class RetroButton extends StatefulWidget {
  final String label;
  final dynamic icon;
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
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.94,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.color ?? AppColors.primary;
    final useAccentGradient = accent == AppColors.primary || accent == AppColors.accent;

    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        widget.onPressed?.call();
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.isSmall ? 14 : 22,
            vertical: widget.isSmall ? 10 : 14,
          ),
          decoration: useAccentGradient
              ? GlassCard.accent(
                  radius: widget.isSmall ? 12 : 16,
                  accentColor: accent,
                )
              : BoxDecoration(
                  color: accent,
                  borderRadius:
                      BorderRadius.circular(widget.isSmall ? 12 : 16),
                ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                HugeIcon(
                  icon: widget.icon,
                  size: widget.isSmall ? 16 : 20,
                  color: Colors.white,
                ),
                SizedBox(width: widget.isSmall ? 6 : 10),
              ],
              Text(
                widget.label,
                style: AppTypography.bodyMedium.copyWith(
                  fontSize: widget.isSmall ? 12 : 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
