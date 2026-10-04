import 'package:flutter/material.dart';

class AppColors {
  // ── Midnight Violet Palette ───────────────────────────────────────────────

  /// Primary canvas — deep midnight indigo (warmer than black)
  static const Color background = Color(0xFF08081A);

  /// Elevated surface — cards, panels (violet-tinted dark)
  static const Color surface = Color(0xFF10102A);

  /// Higher surface — modals, sheets
  static const Color surfaceHigh = Color(0xFF181836);

  /// Subtle dividers & borders
  static const Color surfaceBorder = Color(0xFF252548);

  // ── Brand / Accent ────────────────────────────────────────────────────────

  /// Primary — vibrant soft violet / lavender
  static const Color primary = Color(0xFFC084FC);

  /// Lighter violet for hover/tinted surfaces
  static const Color primaryLight = Color(0xFFD8AAFF);

  /// Violet with low opacity — subtle tints
  static const Color primaryFaint = Color(0x1AC084FC);

  /// Primary glow for bloom effects
  static const Color primaryGlow = Color(0x50C084FC);

  /// Playback green — seek bar fill, now-playing indicator
  static const Color green = Color(0xFF4ADE80);

  /// Green glow
  static const Color greenGlow = Color(0x404ADE80);

  /// Secondary rose-pink for destructive / tag accents
  static const Color secondary = Color(0xFFF472B6);

  /// Teal-cyan accent
  static const Color accent = Color(0xFF67E8F9);

  // ── Text ──────────────────────────────────────────────────────────────────

  static const Color textPrimary = Color(0xFFF0EEFF);
  static const Color textSecondary = Color(0xFF8878B0);
  static const Color textDisabled = Color(0xFF3A3860);

  // ── Status / Misc ─────────────────────────────────────────────────────────

  static const Color divider = Color(0xFF181836);
  static const Color error = Color(0xFFFF4D6D);
  static const Color success = Color(0xFF4ADE80);

  // ── Glassmorphism ─────────────────────────────────────────────────────────

  /// Primary glass fill — violet-white with light transparency
  static const Color glassFill = Color(0x16FFFFFF);

  /// Stronger glass fill for elevated cards
  static const Color glassFillMedium = Color(0x22FFFFFF);

  /// Top-lit glass fill for premium cards
  static const Color glassFillStrong = Color(0x2EFFFFFF);

  /// Glass border — light rim with warm violet tint
  static const Color glassBorder = Color(0x35FFFFFF);

  /// Strong glass border for modals and elevated cards
  static const Color glassBorderStrong = Color(0x50FFFFFF);

  /// Bright top-edge highlight border
  static const Color glassHighlight = Color(0x55FFFFFF);

  /// Subtle inner shadow for depth
  static const Color glassInnerShadow = Color(0x18000000);

  // ── Legacy aliases (kept for backward compat) ─────────────────────────────
  static const Color amber = primary;
  static const Color cream = textPrimary;
  static const Color burntOrange = secondary;
  static const Color neonGreen = green;
  static const Color neonGreenFaint = Color(0x304ADE80);
  static const Color shadowDark = Color(0x55000000);
  static const Color shadowLight = Color(0x0AFFFFFF);
  static const Color surfaceLight = surfaceHigh;

  // ── Gradient presets ──────────────────────────────────────────────────────

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [green, Color(0xFF22D3EE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0D0B25), Color(0xFF08081A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Generate a deterministic gradient from a string (e.g. song title hash)
  static List<Color> seedGradient(String seed) {
    final palettes = [
      [const Color(0xFFC084FC), const Color(0xFF67E8F9)],  // violet → cyan
      [const Color(0xFFF472B6), const Color(0xFFFB923C)],  // rose → orange
      [const Color(0xFF4ADE80), const Color(0xFF22D3EE)],  // green → teal
      [const Color(0xFFFBBF24), const Color(0xFFF97316)],  // amber → orange
      [const Color(0xFFA78BFA), const Color(0xFFC084FC)],  // purple → violet
      [const Color(0xFF38BDF8), const Color(0xFF67E8F9)],  // sky → cyan
      [const Color(0xFFE879F9), const Color(0xFFA78BFA)],  // fuchsia → purple
      [const Color(0xFF4ADE80), const Color(0xFF38BDF8)],  // green → sky
    ];
    final idx = seed.isEmpty ? 0 : seed.codeUnitAt(0) % palettes.length;
    return palettes[idx];
  }
}
