import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  // ── Display / Hero ────────────────────────────────────────────────────────

  static TextStyle display = GoogleFonts.inter(
    color: AppColors.textPrimary,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );

  static TextStyle hero = GoogleFonts.inter(
    color: AppColors.textPrimary,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  // ── Headings ──────────────────────────────────────────────────────────────

  static TextStyle heading = GoogleFonts.inter(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );

  static TextStyle subheading = GoogleFonts.inter(
    color: AppColors.textSecondary,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
  );

  // ── Body ──────────────────────────────────────────────────────────────────

  static TextStyle body = GoogleFonts.inter(
    color: AppColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    color: AppColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  // ── Player ────────────────────────────────────────────────────────────────

  static TextStyle playerTitle = GoogleFonts.inter(
    color: AppColors.textPrimary,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  static TextStyle playerArtist = GoogleFonts.inter(
    color: AppColors.textSecondary,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  // Legacy alias
  static TextStyle playerDisplay = GoogleFonts.inter(
    color: AppColors.primary,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  // ── Caption / Label ───────────────────────────────────────────────────────

  static TextStyle caption = GoogleFonts.inter(
    color: AppColors.textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static TextStyle label = GoogleFonts.inter(
    color: AppColors.textSecondary,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
  );

  static TextStyle overline = GoogleFonts.inter(
    color: AppColors.textDisabled,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
  );
}
