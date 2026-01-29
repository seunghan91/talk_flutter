import 'package:flutter/material.dart';

/// App color palette - Design tokens for consistent colors across the app
class AppColors {
  AppColors._();

  // ============ Brand Colors ============
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  static const Color secondary = Color(0xFF8B5CF6);
  static const Color secondaryLight = Color(0xFFA78BFA);
  static const Color secondaryDark = Color(0xFF7C3AED);

  // ============ Semantic Colors ============
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoDark = Color(0xFF2563EB);

  // ============ Neutral Colors - Light ============
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);

  // ============ Background Colors ============
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);

  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF2D2D2D);

  // ============ Text Colors ============
  static const Color textPrimaryLight = Color(0xFF171717);
  static const Color textSecondaryLight = Color(0xFF525252);
  static const Color textTertiaryLight = Color(0xFF737373);
  static const Color textDisabledLight = Color(0xFFA3A3A3);

  static const Color textPrimaryDark = Color(0xFFFAFAFA);
  static const Color textSecondaryDark = Color(0xFFD4D4D4);
  static const Color textTertiaryDark = Color(0xFFA3A3A3);
  static const Color textDisabledDark = Color(0xFF737373);

  // ============ Gradient Colors ============
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============ Voice/Audio Colors ============
  static const Color waveformActive = primary;
  static const Color waveformInactive = neutral300;
  static const Color recordingPulse = error;

  // ============ Status Colors ============
  static const Color online = success;
  static const Color offline = neutral400;
  static const Color unread = primary;
  static const Color expiring = warning;
}

/// Extension for easy color access from BuildContext
extension AppColorsExtension on BuildContext {
  /// Check if current theme is dark mode
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Get appropriate text color based on theme
  Color get textPrimary =>
      isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

  Color get textSecondary =>
      isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

  Color get textTertiary =>
      isDarkMode ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;

  /// Get appropriate surface color based on theme
  Color get surfaceColor =>
      isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight;

  Color get cardColor =>
      isDarkMode ? AppColors.cardDark : AppColors.cardLight;
}
