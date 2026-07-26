import 'package:flutter/material.dart';

class AppColors {
  // --- Neumorphic Base Palette (Black) ---
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFF1E1E1E);

  // Neumorphic shadow colours
  static const Color shadowDark = Color(0xFF000000);
  static const Color shadowLight = Color(0xFF262626);

  // Accent & brand colours
  static const Color primary = Color(0xFF6C63FF); // soft indigo
  static const Color primaryLight = Color(0xFF3B3699);
  static const Color secondary = Color(0xFFFF6584); // coral-pink
  static const Color accent = Color(0xFF43C6AC); // teal

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textDisabled = Color(0xFF555555);

  // Status / misc
  static const Color divider = Color(0xFF222222);
  static const Color error = Color(0xFFE57373);
  static const Color success = Color(0xFF4CAF50);

  // Keep these aliases for backward compatibility with widgets that still
  // reference old names — they now map to the neumorphic equivalents.
  static const Color amber = primary;
  static const Color cream = textPrimary;
  static const Color burntOrange = secondary;
  static const Color neonGreen = accent;
  static const Color neonGreenFaint = Color(0x3043C6AC);
}
