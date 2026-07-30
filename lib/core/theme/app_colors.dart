import 'package:flutter/material.dart';

class AppColors {
  // ── Deep Space Dark Palette ───────────────────────────────────────────────

  /// Primary canvas — near-black with a deep blue tint
  static const Color background = Color(0xFF0A0A0F);

  /// Elevated surface — cards, panels
  static const Color surface = Color(0xFF141420);

  /// Higher surface — modals, sheets
  static const Color surfaceHigh = Color(0xFF1E1E30);

  /// Subtle dividers & borders
  static const Color surfaceBorder = Color(0xFF2A2A3E);

  // ── Brand / Accent ────────────────────────────────────────────────────────

  /// Primary indigo accent
  static const Color primary = Color(0xFF6C63FF);

  /// Lighter indigo for hover/tinted surfaces
  static const Color primaryLight = Color(0xFF8B84FF);

  /// Indigo with low opacity — subtle tints
  static const Color primaryFaint = Color(0x1A6C63FF);

  /// Playback green — seek bar fill, now-playing indicator
  static const Color green = Color(0xFF1BDB7A);

  /// Secondary coral-pink for destructive / tag accents
  static const Color secondary = Color(0xFFFF6584);

  /// Teal accent
  static const Color accent = Color(0xFF43C6AC);

  // ── Text ──────────────────────────────────────────────────────────────────

  static const Color textPrimary = Color(0xFFEEEEFF);
  static const Color textSecondary = Color(0xFF9090A8);
  static const Color textDisabled = Color(0xFF4A4A60);

  // ── Status / Misc ─────────────────────────────────────────────────────────

  static const Color divider = Color(0xFF1E1E30);
  static const Color error = Color(0xFFFF5370);
  static const Color success = Color(0xFF1BDB7A);

  // ── Glassmorphism ─────────────────────────────────────────────────────────

  /// Glass surface fill
  static const Color glassFill = Color(0x1AFFFFFF);

  /// Glass border
  static const Color glassBorder = Color(0x26FFFFFF);

  // ── Legacy aliases (kept for backward compat with widgets not yet updated) ─
  static const Color amber = primary;
  static const Color cream = textPrimary;
  static const Color burntOrange = secondary;
  static const Color neonGreen = green;
  static const Color neonGreenFaint = Color(0x301BDB7A);
  static const Color shadowDark = Color(0x40000000);
  static const Color shadowLight = Color(0x0AFFFFFF);
  static const Color surfaceLight = surfaceHigh;

  // ── Gradient presets ──────────────────────────────────────────────────────

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [green, Color(0xFF00A854)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Generate a deterministic gradient from a string (e.g. song title hash)
  static List<Color> seedGradient(String seed) {
    final palettes = [
      [const Color(0xFF6C63FF), const Color(0xFF43C6AC)],
      [const Color(0xFFFF6584), const Color(0xFFFF8C69)],
      [const Color(0xFF1BDB7A), const Color(0xFF00A8CC)],
      [const Color(0xFFFF9800), const Color(0xFFFF5722)],
      [const Color(0xFF9C27B0), const Color(0xFF673AB7)],
      [const Color(0xFF2196F3), const Color(0xFF00BCD4)],
      [const Color(0xFFE91E63), const Color(0xFF9C27B0)],
      [const Color(0xFF4CAF50), const Color(0xFF8BC34A)],
    ];
    final idx = seed.isEmpty ? 0 : seed.codeUnitAt(0) % palettes.length;
    return palettes[idx];
  }
}
