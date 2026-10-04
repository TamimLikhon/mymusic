import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Glassmorphism & dark card decoration helpers.
/// Replaces the old Neumorphic class.
class GlassCard {
  GlassCard._();

  /// Standard dark card surface with glass feel
  static BoxDecoration card({
    double radius = 18,
    Color color = AppColors.surface,
    bool withBorder = true,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: withBorder
          ? Border.all(color: AppColors.glassBorder, width: 0.8)
          : null,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// True frosted-glass surface — pair with BackdropFilter for full effect
  static BoxDecoration glass({
    double radius = 20,
    Color? tint,
    double tintOpacity = 0.12,
  }) {
    return BoxDecoration(
      color: tint != null
          ? tint.withValues(alpha: tintOpacity)
          : AppColors.glassFill,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.glassBorder, width: 0.8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  /// Premium glass surface with a glowing accent top edge
  static BoxDecoration glassAccented({
    double radius = 20,
    Color accentColor = AppColors.primary,
  }) {
    return BoxDecoration(
      color: AppColors.glassFill,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: accentColor.withValues(alpha: 0.35), width: 1),
      boxShadow: [
        BoxShadow(
          color: accentColor.withValues(alpha: 0.15),
          blurRadius: 24,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.4),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  /// Accent-tinted raised surface — for active/primary elements
  static BoxDecoration accent({
    double radius = 16,
    Color accentColor = AppColors.primary,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          accentColor,
          Color.lerp(accentColor, AppColors.accent, 0.45)!,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: accentColor.withValues(alpha: 0.4),
          offset: const Offset(0, 8),
          blurRadius: 24,
          spreadRadius: -2,
        ),
        BoxShadow(
          color: accentColor.withValues(alpha: 0.2),
          offset: const Offset(0, 2),
          blurRadius: 6,
        ),
      ],
    );
  }

  /// Circle variant of card
  static BoxDecoration circle({Color color = AppColors.surface}) {
    return BoxDecoration(
      shape: BoxShape.circle,
      color: color,
      border: Border.all(color: AppColors.glassBorder, width: 0.8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
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

  // ── Legacy shims ─────────────────────────────────────────────────────────

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

/// Full glassmorphism widget with BackdropFilter blur, gradient overlay, and border
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final double blurSigma;
  final Color? tint;
  final double tintOpacity;
  final bool showBorder;
  final BoxBorder? border;
  final List<BoxShadow>? shadows;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.radius = 22,
    this.blurSigma = 14,
    this.tint,
    this.tintOpacity = 0.12,
    this.showBorder = true,
    this.border,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (tint ?? Colors.white).withValues(alpha: tintOpacity + 0.04),
                (tint ?? Colors.white).withValues(alpha: tintOpacity - 0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(radius),
            border: showBorder
                ? (border ?? Border.all(color: AppColors.glassBorder, width: 0.8))
                : null,
            boxShadow: shadows ??
                [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Glassmorphism widget with a gradient border shimmer (top edge lit)
class ShimmerGlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final double blurSigma;
  final Color accentColor;

  const ShimmerGlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.radius = 22,
    this.blurSigma = 14,
    this.accentColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.4),
            accentColor.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius - 1),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: AppColors.glassFill,
                borderRadius: BorderRadius.circular(radius - 1),
              ),
              child: child,
            ),
          ),
        ),
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
