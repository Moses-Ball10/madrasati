import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Cairo-based text styles for the entire app
class AppTextStyles {
  AppTextStyles._();

  // Headings
  static TextStyle heading1 = GoogleFonts.cairo(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
    height: 1.4,
  );

  static TextStyle heading2 = GoogleFonts.cairo(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
    height: 1.4,
  );

  static TextStyle heading3 = GoogleFonts.cairo(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
    height: 1.4,
  );

  // Body
  static TextStyle bodyLarge = GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textMedium,
    height: 1.7,
  );

  static TextStyle bodyMedium = GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textMedium,
    height: 1.7,
  );

  static TextStyle bodySmall = GoogleFonts.cairo(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
    height: 1.5,
  );

  // Labels & Buttons
  static TextStyle buttonText = GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    height: 1.2,
  );

  static TextStyle labelMedium = GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryBrown,
    height: 1.2,
  );

  static TextStyle labelSmall = GoogleFonts.cairo(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryBrownLight,
    height: 1.2,
  );

  // Caption
  static TextStyle caption = GoogleFonts.cairo(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
    height: 1.3,
  );

  // AppBar Title
  static TextStyle appBarTitle = GoogleFonts.cairo(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.beigeLight,
    height: 1.2,
  );

  // Stats / Numbers
  static TextStyle statNumber = GoogleFonts.cairo(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryBrown,
    height: 1.2,
  );

  static TextStyle statLabel = GoogleFonts.cairo(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
    height: 1.2,
  );
}
