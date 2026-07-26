import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Utility helpers for building neumorphic shadow decorations.
class Neumorphic {
  Neumorphic._();

  /// Standard raised surface (like a floating card).
  static BoxDecoration raised({
    double radius = 16,
    Color color = AppColors.background,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowDark,
          offset: const Offset(6, 6),
          blurRadius: 12,
          spreadRadius: 1,
        ),
        const BoxShadow(
          color: AppColors.shadowLight,
          offset: Offset(-6, -6),
          blurRadius: 12,
          spreadRadius: 1,
        ),
      ],
    );
  }

  /// Pressed/inset surface (depressed into the background).
  static BoxDecoration pressed({
    double radius = 16,
    Color color = AppColors.background,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowDark,
          offset: const Offset(3, 3),
          blurRadius: 6,
          spreadRadius: 0,
        ),
        const BoxShadow(
          color: AppColors.shadowLight,
          offset: Offset(-3, -3),
          blurRadius: 6,
          spreadRadius: 0,
        ),
      ],
    );
  }

  /// Circle raised surface.
  static BoxDecoration raisedCircle({Color color = AppColors.background}) {
    return BoxDecoration(
      shape: BoxShape.circle,
      color: color,
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowDark,
          offset: const Offset(6, 6),
          blurRadius: 14,
          spreadRadius: 1,
        ),
        const BoxShadow(
          color: AppColors.shadowLight,
          offset: Offset(-6, -6),
          blurRadius: 14,
          spreadRadius: 1,
        ),
      ],
    );
  }

  /// Accent-tinted raised surface (for active/primary elements).
  static BoxDecoration raisedAccent({
    double radius = 16,
    Color accent = AppColors.primary,
  }) {
    return BoxDecoration(
      color: accent,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: accent.withValues(alpha: 0.45),
          offset: const Offset(4, 8),
          blurRadius: 16,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.3),
          offset: const Offset(-2, -2),
          blurRadius: 6,
          spreadRadius: 0,
        ),
      ],
    );
  }
}
