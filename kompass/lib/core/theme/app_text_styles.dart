import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// KOMPASS Typography
/// Uses bold, readable fonts optimized for outdoor use and elderly accessibility.
/// Minimum body text: 16sp for readability.
class AppTextStyles {
  AppTextStyles._();

  /// Display/heading font — adventurous and bold
  static String get _headingFamily => GoogleFonts.cinzel().fontFamily!;

  /// Body font — clean and highly readable
  static String get _bodyFamily => GoogleFonts.sourceSans3().fontFamily!;

  // ── Headings (Cinzel — elegant, adventure map aesthetic) ──
  static TextStyle get displayLarge => TextStyle(
    fontFamily: _headingFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 1.2,
  );

  static TextStyle get displayMedium => TextStyle(
    fontFamily: _headingFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.8,
  );

  static TextStyle get headlineLarge => TextStyle(
    fontFamily: _headingFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get headlineMedium => TextStyle(
    fontFamily: _headingFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // ── Body (Source Sans 3 — clean, highly readable, great for seniors) ──
  static TextStyle get bodyLarge => TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get bodySmall => TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static TextStyle get labelLarge => TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );

  static TextStyle get labelMedium => TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static TextStyle get button => TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
  );
}
