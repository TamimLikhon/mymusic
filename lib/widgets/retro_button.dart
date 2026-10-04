import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/glass_card.dart';

/// Modern action button with glassmorphism & accent styling.
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
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.color ?? AppColors.primary;
    final useAccentGradient =
        accent == AppColors.primary || accent == AppColors.accent;

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
            horizontal: widget.isSmall ? 16 : 24,
            vertical: widget.isSmall ? 10 : 14,
          ),
          decoration: useAccentGradient
              ? GlassCard.accent(
                  radius: widget.isSmall ? 14 : 18,
                  accentColor: accent,
                )
              : BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accent.withValues(alpha: 0.35),
                      accent.withValues(alpha: 0.18),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius:
                      BorderRadius.circular(widget.isSmall ? 14 : 18),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.4),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
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
                SizedBox(width: widget.isSmall ? 8 : 10),
              ],
              Text(
                widget.label,
                style: AppTypography.bodyMedium.copyWith(
                  fontSize: widget.isSmall ? 13 : 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
