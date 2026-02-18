import 'package:flutter/material.dart';

/// App color palette - Design tokens for consistent colors across the app
class AppColors {
  AppColors._();

  // ============ Brand Colors (Design System) ============
  /// Primary: #e63946 (강렬한 빨강) - Light mode
  static const Color primary = Color(0xFFE63946);
  static const Color primaryLight = Color(0xFFFF6B77);
  /// Primary Dark mode: oklch(0.985 0 0) → #FAFAFA (흰색)
  static const Color primaryDarkMode = Color(0xFFFAFAFA);

  /// Secondary: #ffb3ba (연한 분홍) - Light mode
  static const Color secondary = Color(0xFFFFB3BA);
  static const Color secondaryLight = Color(0xFFFFD4D8);
  /// Secondary Dark mode: oklch(0.269 0 0) → #404040
  static const Color secondaryDarkMode = Color(0xFF404040);

  /// Muted: #fff0f0 (매우 연한 분홍 배경) - Light mode
  static const Color muted = Color(0xFFFFF0F0);
  static const Color mutedForeground = Color(0xFF8B6B6B);
  /// Muted Dark mode: oklch(0.269 0 0) → #404040
  static const Color mutedDarkMode = Color(0xFF404040);
  /// Muted Foreground Dark mode: oklch(0.708 0 0) → #B3B3B3
  static const Color mutedForegroundDarkMode = Color(0xFFB3B3B3);

  /// Accent: #ffd4d8 (연한 핑크 강조색) - Light mode
  static const Color accent = Color(0xFFFFD4D8);
  static const Color accentForeground = Color(0xFF2D1B1B);
  /// Accent Dark mode: oklch(0.269 0 0) → #404040
  static const Color accentDarkMode = Color(0xFF404040);
  /// Accent Foreground Dark mode: oklch(0.985 0 0) → #FAFAFA
  static const Color accentForegroundDarkMode = Color(0xFFFAFAFA);

  /// Input background: #fff5f5 - Light mode
  static const Color inputBackground = Color(0xFFFFF5F5);
  /// Input background Dark mode: oklch(0.269 0 0) → #404040
  static const Color inputBackgroundDarkMode = Color(0xFF404040);

  /// Border: rgba(230, 57, 70, 0.15) - Light mode
  static const Color border = Color(0x26E63946);
  /// Border Dark mode: oklch(0.269 0 0) → #404040
  static const Color borderDarkMode = Color(0xFF404040);

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

  // ============ On-Color Variants (for text/icons on colored backgrounds) ============
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onWarning = Color(0xFF171717);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color onInfo = Color(0xFFFFFFFF);

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

  // ============ Background Colors (Design System) ============
  /// Light mode: #ffffff (순백)
  static const Color backgroundLight = Color(0xFFFFFFFF);
  /// Dark mode: oklch(0.145 0 0) → #252525
  static const Color backgroundDark = Color(0xFF252525);

  /// Surface: 카드/팝오버 배경
  static const Color surfaceLight = Color(0xFFFFFFFF);
  /// Dark mode: oklch(0.145 0 0) → #252525
  static const Color surfaceDark = Color(0xFF252525);

  /// Card: 카드 배경
  static const Color cardLight = Color(0xFFFFFFFF);
  /// Dark mode: oklch(0.145 0 0) → #252525
  static const Color cardDark = Color(0xFF252525);

  // ============ Text Colors ============
  /// Light mode: #2d1b1b (어두운 갈색)
  static const Color textPrimaryLight = Color(0xFF2D1B1B);
  static const Color textSecondaryLight = Color(0xFF8B6B6B);
  static const Color textTertiaryLight = Color(0xFFA89A9A);
  static const Color textDisabledLight = Color(0xFFC4BABA); // WCAG compliant

  /// Dark mode: 흰색 계열
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
  static const Color recordingPulse = primary;

  // ============ Status Colors ============
  static const Color online = success;
  static const Color offline = neutral400;
  static const Color unread = primary;
  static const Color expiring = warning;

  // ============ Shadow Colors (for boxShadow) ============
  /// Light mode: 약한 검은색 그림자
  static const Color shadowLight = Color(0x0F000000); // alpha: 0.06
  /// Dark mode: 조금 더 진한 검은색 그림자
  static const Color shadowDark = Color(0x3D000000); // alpha: 0.24
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

  /// Get appropriate shadow color based on theme
  Color get shadowColor =>
      isDarkMode ? AppColors.shadowDark : AppColors.shadowLight;

  /// Get appropriate primary color based on theme
  Color get primaryColor =>
      isDarkMode ? AppColors.primaryDarkMode : AppColors.primary;

  /// Get appropriate secondary color based on theme
  Color get secondaryColor =>
      isDarkMode ? AppColors.secondaryDarkMode : AppColors.secondary;

  /// Get appropriate muted color based on theme
  Color get mutedColor =>
      isDarkMode ? AppColors.mutedDarkMode : AppColors.muted;

  /// Get appropriate muted foreground color based on theme
  Color get mutedForegroundColor =>
      isDarkMode ? AppColors.mutedForegroundDarkMode : AppColors.mutedForeground;

  /// Get appropriate accent color based on theme
  Color get accentColor =>
      isDarkMode ? AppColors.accentDarkMode : AppColors.accent;

  /// Get appropriate border color based on theme
  Color get borderColor =>
      isDarkMode ? AppColors.borderDarkMode : AppColors.border;

  /// Get appropriate input background color based on theme
  Color get inputBgColor =>
      isDarkMode ? AppColors.inputBackgroundDarkMode : AppColors.inputBackground;
}
