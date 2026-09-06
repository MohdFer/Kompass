import 'package:flutter/material.dart';

/// KOMPASS Adventure Color Palette
/// Inspired by desert exploration, ocean voyages, and treasure hunts.
/// Designed for high-contrast outdoor readability and elderly accessibility.
class AppColors {
  AppColors._();

  // ── Primary: Compass Gold ──
  /// Rich antique gold — the brass of a weathered compass
  static const Color primaryGold = Color(0xFFB8860B);        // Dark Goldenrod
  static const Color primaryGoldLight = Color(0xFFDAA520);   // Goldenrod
  static const Color primaryGoldDark = Color(0xFF8B6914);    // Dark antique gold

  // ── Secondary: Ocean Teal ──
  /// Deep sea teal — the ocean from a crow's nest
  static const Color secondaryTeal = Color(0xFF006D6F);      // Deep teal
  static const Color secondaryTealLight = Color(0xFF00897B); // Lighter teal
  static const Color secondaryTealDark = Color(0xFF004D40);  // Very dark teal

  // ── Accent: Treasure Red ──
  /// The red X marks the spot
  static const Color accentRed = Color(0xFFC62828);          // Deep treasure red
  static const Color accentRedLight = Color(0xFFE53935);     // Lighter red

  // ── Neutrals: Parchment & Leather ──
  /// Aged parchment backgrounds
  static const Color parchment = Color(0xFFF5F0E1);          // Warm cream
  static const Color parchmentDark = Color(0xFFE8DCC8);      // Darker parchment
  /// Weathered leather browns
  static const Color leather = Color(0xFF5D4037);            // Rich brown
  static const Color leatherLight = Color(0xFF795548);       // Medium brown
  static const Color leatherDark = Color(0xFF3E2723);        // Dark leather

  // ── Sand tones ──
  static const Color sandLight = Color(0xFFFFF8E1);          // Light sand
  static const Color sand = Color(0xFFFFECB3);               // Warm sand
  static const Color sandDark = Color(0xFFD7CCC8);           // Darker sand

  // ── Functional Colors ──
  static const Color success = Color(0xFF2E7D32);            // Forest green
  static const Color warning = Color(0xFFEF6C00);            // Amber warning
  static const Color error = Color(0xFFC62828);              // Danger red
  static const Color info = Color(0xFF0277BD);               // Info blue

  // ── Text Colors ──
  static const Color textPrimary = Color(0xFF2C1810);        // Very dark brown
  static const Color textSecondary = Color(0xFF5D4037);      // Medium brown
  static const Color textOnPrimary = Color(0xFFFFF8E1);      // Light sand on dark
  static const Color textOnDark = Color(0xFFF5F0E1);         // Parchment on dark
  static const Color textHint = Color(0xFF8D6E63);           // Muted brown

  // ── Surface & Background ──
  static const Color background = Color(0xFFF5F0E1);         // Parchment
  static const Color surface = Color(0xFFFFFFFF);            // White card
  static const Color surfaceVariant = Color(0xFFFFF8E1);     // Light sand card
  static const Color cardShadow = Color(0x1A5D4037);         // Brown shadow

  // ── SOS Emergency ──
  static const Color sosRed = Color(0xFFD50000);             // Bright emergency red
  static const Color sosPulse = Color(0xFFFF1744);           // Pulsing SOS
}
