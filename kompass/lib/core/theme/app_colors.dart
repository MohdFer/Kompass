import 'package:flutter/material.dart';

/// Lumora Dark Mode Design System
class AppColors {
  AppColors._();

  // Primary Neon Accents
  static const Color primaryNeon = Color(0xFFE4FF00); // Neon Yellow
  static const Color primaryNeonGreen = Color(0xFF9CFF50); // Neon Green

  // Background & Surfaces
  static const Color background = Color(0xFF000000); // Pure Black
  static const Color surface = Color(0xFF1A1A1A); // Very Dark Gray (Cards)
  static const Color surfaceVariant = Color(0xFF222222); // Slightly lighter Gray
  static const Color border = Color(0xFF333333); // Borders / Dividers

  // Grayscale Palette
  static const Color grayLight = Color(0xFF7E7E7E);
  static const Color grayMedium = Color(0xFF898989);
  static const Color grayDark = Color(0xFF222222);

  // Status Colors (from image)
  static const Color error = Color(0xFFFF0000); // Red
  static const Color success = Color(0xFF15FF00); // Bright Green
  static const Color info = Color(0xFF00E5FF); // Cyan
  static const Color purpleAccent = Color(0xFFD400FF); // Purple

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF); // White
  static const Color textSecondary = Color(0xFF898989); // Medium Gray
  static const Color textOnPrimary = Color(0xFF000000); // Black text on Neon

  // Aliases for compatibility with existing code
  static const Color primaryGold = primaryNeon;
  static const Color primaryGoldLight = primaryNeon;
  static const Color primaryGoldDark = primaryNeonGreen;
  static const Color secondaryTeal = primaryNeonGreen;
  static const Color accentRed = error;
  static const Color sandDark = border;
  static const Color cardShadow = Color(0x33000000);
  static const Color textHint = grayMedium;
  static const Color warning = Color(0xFFEF6C00); // Orange/Amber
}
