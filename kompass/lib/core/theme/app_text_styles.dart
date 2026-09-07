import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Lumora Typography (Outfit Font Family)
class AppTextStyles {
  AppTextStyles._();

  static String get _fontFamily => GoogleFonts.outfit().fontFamily!;

  // Headings
  static TextStyle get displayLarge => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700, // Bold
    color: AppColors.textPrimary,
  );

  static TextStyle get displayMedium => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700, // Bold
    color: AppColors.textPrimary,
  );

  static TextStyle get headlineLarge => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700, // Bold (Heading 1)
    color: AppColors.textPrimary,
  );

  static TextStyle get headlineMedium => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600, // Semi-Bold (Heading 2)
    color: AppColors.textPrimary,
  );

  // Subheadings and Body
  static TextStyle get bodyLarge => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500, // Medium (Sub Heading)
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular (Paragraph)
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static TextStyle get bodySmall => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Labels
  static TextStyle get labelLarge => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get labelMedium => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static TextStyle get button => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary, // Black text on neon buttons
  );

  // Aliases for compatibility
  static TextStyle get titleMedium => headlineMedium;
}
