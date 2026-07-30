import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Glassmorphism & dark card decoration helpers.
/// Replaces the old Neumorphic class.
class GlassCard {
  GlassCard._();

  /// Standard dark card surface
  static BoxDecoration card({
    double radius = 16,
    Color color = AppColors.surface,
    bool withBorder = true,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: withBorder
          ? Border.all(color: AppColors.surfaceBorder, width: 1)
          : null,
    );
  }

  /// Frosted-glass surface (use with BackdropFilter)
  static BoxDecoration glass({
    double radius = 16,
  }) {
    return BoxDecoration(
      color: AppColors.glassFill,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.glassBorder, width: 1),
    );
  }

  /// Accent-tinted raised surface — for active/primary elements
  static BoxDecoration accent({
    double radius = 16,
    Color accentColor = AppColors.primary,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [accentColor, Color.lerp(accentColor, AppColors.accent, 0.4)!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: accentColor.withValues(alpha: 0.35),
          offset: const Offset(0, 8),
          blurRadius: 20,
          spreadRadius: 0,
        ),
      ],
    );
  }

  /// Circle variant of card
  static BoxDecoration circle({Color color = AppColors.surface}) {
    return BoxDecoration(
      shape: BoxShape.circle,
      color: color,
      border: Border.all(color: AppColors.surfaceBorder, width: 1),
    );
  }

  /// Gradient art placeholder for song/album cards
  static BoxDecoration artPlaceholder({
    required List<Color> colors,
    double radius = 12,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(radius),
    );
  }

  /// Subtle inset / pressed surface
  static BoxDecoration pressed({double radius = 16}) {
    return BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.surfaceBorder.withValues(alpha: 0.5)),
    );
  }

  // ── Legacy shims for old code still calling Neumorphic.* ─────────────────

  /// @deprecated Use GlassCard.card() instead
  static BoxDecoration raised({double radius = 16, Color color = AppColors.surface}) =>
      card(radius: radius, color: color);

  /// @deprecated Use GlassCard.circle() instead
  static BoxDecoration raisedCircle({Color color = AppColors.surface}) =>
      circle(color: color);

  /// @deprecated Use GlassCard.accent() instead
  static BoxDecoration raisedAccent({double radius = 16, Color accent = AppColors.primary}) =>
      GlassCard.accent(radius: radius, accentColor: accent);
}

/// Legacy alias so existing imports of `Neumorphic` still compile
/// while we migrate widget by widget.
class Neumorphic {
  Neumorphic._();
  static BoxDecoration raised({double radius = 16, Color color = AppColors.surface}) =>
      GlassCard.card(radius: radius, color: color);
  static BoxDecoration pressed({double radius = 16, Color color = AppColors.background}) =>
      GlassCard.pressed(radius: radius);
  static BoxDecoration raisedCircle({Color color = AppColors.surface}) =>
      GlassCard.circle(color: color);
  static BoxDecoration raisedAccent({double radius = 16, Color accent = AppColors.primary}) =>
      GlassCard.accent(radius: radius, accentColor: accent);
}

/// Reusable glassmorphism Widget wrapper with BackdropFilter
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final double blurSigma;
  final Color? color;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.radius = 20,
    this.blurSigma = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        decoration: GlassCard.glass(radius: radius).copyWith(
          color: color ?? AppColors.glassFill,
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}

/// Seed-based gradient art placeholder for songs without album art
class ArtPlaceholder extends StatelessWidget {
  final String seed;
  final double size;
  final double radius;
  final Widget? child;

  const ArtPlaceholder({
    super.key,
    required this.seed,
    this.size = 44,
    this.radius = 12,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.seedGradient(seed);
    return Container(
      width: size,
      height: size,
      decoration: GlassCard.artPlaceholder(colors: colors, radius: radius),
      child: child ??
          Center(
            child: Text(
              seed.isNotEmpty ? seed[0].toUpperCase() : '♪',
              style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w800,
                fontSize: size * 0.38,
              ),
            ),
          ),
    );
  }
}
