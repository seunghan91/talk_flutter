import 'package:flutter/material.dart';

/// App typography system - Consistent text styles across the app
class AppTypography {
  AppTypography._();

  // ============ Font Family ============
  static const String fontFamily = 'Pretendard';
  static const String fontFamilyFallback = '.SF Pro Display';

  // ============ Font Weights ============
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // ============ Display Styles ============
  static TextStyle displayLarge({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 57,
        fontWeight: regular,
        letterSpacing: -0.25,
        height: 1.12,
        color: color,
      );

  static TextStyle displayMedium({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 45,
        fontWeight: regular,
        letterSpacing: 0,
        height: 1.16,
        color: color,
      );

  static TextStyle displaySmall({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 36,
        fontWeight: regular,
        letterSpacing: 0,
        height: 1.22,
        color: color,
      );

  // ============ Headline Styles ============
  static TextStyle headlineLarge({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 32,
        fontWeight: bold,
        letterSpacing: 0,
        height: 1.25,
        color: color,
      );

  static TextStyle headlineMedium({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 28,
        fontWeight: semiBold,
        letterSpacing: 0,
        height: 1.29,
        color: color,
      );

  static TextStyle headlineSmall({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: semiBold,
        letterSpacing: 0,
        height: 1.33,
        color: color,
      );

  // ============ Title Styles ============
  static TextStyle titleLarge({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 22,
        fontWeight: semiBold,
        letterSpacing: 0,
        height: 1.27,
        color: color,
      );

  static TextStyle titleMedium({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: semiBold,
        letterSpacing: 0.15,
        height: 1.5,
        color: color,
      );

  static TextStyle titleSmall({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: semiBold,
        letterSpacing: 0.1,
        height: 1.43,
        color: color,
      );

  // ============ Body Styles ============
  static TextStyle bodyLarge({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: regular,
        letterSpacing: 0.5,
        height: 1.5,
        color: color,
      );

  static TextStyle bodyMedium({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: regular,
        letterSpacing: 0.25,
        height: 1.43,
        color: color,
      );

  static TextStyle bodySmall({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: regular,
        letterSpacing: 0.4,
        height: 1.33,
        color: color,
      );

  // ============ Label Styles ============
  static TextStyle labelLarge({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: medium,
        letterSpacing: 0.1,
        height: 1.43,
        color: color,
      );

  static TextStyle labelMedium({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: medium,
        letterSpacing: 0.5,
        height: 1.33,
        color: color,
      );

  static TextStyle labelSmall({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        fontWeight: medium,
        letterSpacing: 0.5,
        height: 1.45,
        color: color,
      );

  // ============ Custom App Styles ============
  /// Timer display (for recording)
  static TextStyle timer({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 48,
        fontWeight: light,
        letterSpacing: -1,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: color,
      );

  /// Balance display (for wallet)
  static TextStyle balance({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 36,
        fontWeight: bold,
        letterSpacing: -0.5,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: color,
      );

  /// Badge text
  static TextStyle badge({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 10,
        fontWeight: bold,
        letterSpacing: 0,
        height: 1,
        color: color ?? Colors.white,
      );

  /// Empty state title - color should be provided by caller based on theme
  static TextStyle emptyStateTitle({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: semiBold,
        letterSpacing: 0,
        height: 1.33,
        color: color,
      );

  /// Empty state description - color should be provided by caller based on theme
  static TextStyle emptyStateDescription({Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: regular,
        letterSpacing: 0.25,
        height: 1.5,
        color: color,
      );
}

/// Extension for easy typography access from BuildContext
extension AppTypographyExtension on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Shorthand for common text styles
  TextStyle? get displayLarge => textTheme.displayLarge;
  TextStyle? get displayMedium => textTheme.displayMedium;
  TextStyle? get displaySmall => textTheme.displaySmall;

  TextStyle? get headlineLarge => textTheme.headlineLarge;
  TextStyle? get headlineMedium => textTheme.headlineMedium;
  TextStyle? get headlineSmall => textTheme.headlineSmall;

  TextStyle? get titleLarge => textTheme.titleLarge;
  TextStyle? get titleMedium => textTheme.titleMedium;
  TextStyle? get titleSmall => textTheme.titleSmall;

  TextStyle? get bodyLarge => textTheme.bodyLarge;
  TextStyle? get bodyMedium => textTheme.bodyMedium;
  TextStyle? get bodySmall => textTheme.bodySmall;

  TextStyle? get labelLarge => textTheme.labelLarge;
  TextStyle? get labelMedium => textTheme.labelMedium;
  TextStyle? get labelSmall => textTheme.labelSmall;
}
