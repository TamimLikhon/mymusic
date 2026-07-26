import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextStyle heading = GoogleFonts.openSans(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
  );

  static TextStyle body = GoogleFonts.openSans(
    color: AppColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
  );

  static TextStyle playerDisplay = GoogleFonts.openSans(
    color: AppColors.primary,
    fontSize: 26,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.5,
  );

  static TextStyle caption = GoogleFonts.openSans(
    color: AppColors.textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
  );

  static TextStyle label = GoogleFonts.openSans(
    color: AppColors.textSecondary,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
  );
}
