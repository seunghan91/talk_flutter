import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// App theme configuration - Unified theme for the entire app
class AppTheme {
  AppTheme._();

  // ============ Light Theme ============
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.error,
      surface: AppColors.surfaceLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,

      // Font family
      fontFamily: AppTypography.fontFamily,

      // Text Theme
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge(color: AppColors.textPrimaryLight),
        displayMedium: AppTypography.displayMedium(color: AppColors.textPrimaryLight),
        displaySmall: AppTypography.displaySmall(color: AppColors.textPrimaryLight),
        headlineLarge: AppTypography.headlineLarge(color: AppColors.textPrimaryLight),
        headlineMedium: AppTypography.headlineMedium(color: AppColors.textPrimaryLight),
        headlineSmall: AppTypography.headlineSmall(color: AppColors.textPrimaryLight),
        titleLarge: AppTypography.titleLarge(color: AppColors.textPrimaryLight),
        titleMedium: AppTypography.titleMedium(color: AppColors.textPrimaryLight),
        titleSmall: AppTypography.titleSmall(color: AppColors.textPrimaryLight),
        bodyLarge: AppTypography.bodyLarge(color: AppColors.textPrimaryLight),
        bodyMedium: AppTypography.bodyMedium(color: AppColors.textPrimaryLight),
        bodySmall: AppTypography.bodySmall(color: AppColors.textSecondaryLight),
        labelLarge: AppTypography.labelLarge(color: AppColors.textPrimaryLight),
        labelMedium: AppTypography.labelMedium(color: AppColors.textSecondaryLight),
        labelSmall: AppTypography.labelSmall(color: AppColors.textSecondaryLight),
      ),

      // Scaffold
      scaffoldBackgroundColor: AppColors.backgroundLight,

      // AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textPrimaryLight,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
        ),
      ),

      // Cards (Design System)
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardRadius,
          side: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        color: AppColors.cardLight,
        margin: EdgeInsets.zero,
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: AppSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonRadius,
          ),
          minimumSize: const Size(64, 48),
        ),
      ),

      // Filled Button
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: AppSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonRadius,
          ),
          minimumSize: const Size(64, 48),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: AppSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonRadius,
          ),
          minimumSize: const Size(64, 48),
          side: BorderSide(color: colorScheme.outline),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: AppSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonRadius,
          ),
          minimumSize: const Size(64, 40),
        ),
      ),

      // Input Decoration (Design System)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: AppSpacing.inputPadding,
        border: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: TextStyle(color: AppColors.mutedForeground),
        hintStyle: TextStyle(color: AppColors.textTertiaryLight),
      ),

      // Navigation Bar (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        height: 80,
        backgroundColor: AppColors.surfaceLight,
        indicatorColor: AppColors.muted,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textTertiaryLight,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: AppColors.primary,
              size: 24,
            );
          }
          return const IconThemeData(
            color: AppColors.textTertiaryLight,
            size: 24,
          );
        }),
      ),

      // Bottom Navigation Bar (legacy)
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surfaceLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiaryLight,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.largeRadius,
        ),
        backgroundColor: AppColors.surfaceLight,
        elevation: 8,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
        ),
      ),

      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.bottomSheetRadius,
        ),
        elevation: 8,
        dragHandleColor: AppColors.neutral300,
        dragHandleSize: const Size(32, 4),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.smallRadius,
        ),
        backgroundColor: AppColors.neutral800,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),

      // Chip (Design System)
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.muted,
        selectedColor: AppColors.accent,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.smallRadius,
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // ListTile
      listTileTheme: ListTileThemeData(
        contentPadding: AppSpacing.listItemPadding,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.smallRadius,
        ),
        tileColor: Colors.transparent,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: AppColors.neutral200,
        thickness: 1,
        space: 1,
      ),

      // Progress Indicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.neutral200,
        circularTrackColor: AppColors.neutral200,
      ),
    );
  }

  // ============ Dark Theme ============
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryDarkMode,
      brightness: Brightness.dark,
      primary: AppColors.primaryDarkMode, // #FAFAFA (흰색)
      secondary: AppColors.secondaryDarkMode, // #404040
      error: AppColors.errorLight,
      surface: AppColors.surfaceDark, // #252525
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,

      // Font family
      fontFamily: AppTypography.fontFamily,

      // Text Theme
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge(color: AppColors.textPrimaryDark),
        displayMedium: AppTypography.displayMedium(color: AppColors.textPrimaryDark),
        displaySmall: AppTypography.displaySmall(color: AppColors.textPrimaryDark),
        headlineLarge: AppTypography.headlineLarge(color: AppColors.textPrimaryDark),
        headlineMedium: AppTypography.headlineMedium(color: AppColors.textPrimaryDark),
        headlineSmall: AppTypography.headlineSmall(color: AppColors.textPrimaryDark),
        titleLarge: AppTypography.titleLarge(color: AppColors.textPrimaryDark),
        titleMedium: AppTypography.titleMedium(color: AppColors.textPrimaryDark),
        titleSmall: AppTypography.titleSmall(color: AppColors.textPrimaryDark),
        bodyLarge: AppTypography.bodyLarge(color: AppColors.textPrimaryDark),
        bodyMedium: AppTypography.bodyMedium(color: AppColors.textPrimaryDark),
        bodySmall: AppTypography.bodySmall(color: AppColors.textSecondaryDark),
        labelLarge: AppTypography.labelLarge(color: AppColors.textPrimaryDark),
        labelMedium: AppTypography.labelMedium(color: AppColors.textSecondaryDark),
        labelSmall: AppTypography.labelSmall(color: AppColors.textSecondaryDark),
      ),

      // Scaffold
      scaffoldBackgroundColor: AppColors.backgroundDark,

      // AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textPrimaryDark,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryDark,
        ),
      ),

      // Cards (Dark Mode - Design System)
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardRadius,
          side: BorderSide(
            color: AppColors.borderDarkMode, // #404040
            width: 1,
          ),
        ),
        color: AppColors.cardDark, // #252525
        margin: EdgeInsets.zero,
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: AppSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonRadius,
          ),
          minimumSize: const Size(64, 48),
        ),
      ),

      // Filled Button
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: AppSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonRadius,
          ),
          minimumSize: const Size(64, 48),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: AppSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonRadius,
          ),
          minimumSize: const Size(64, 48),
          side: BorderSide(color: colorScheme.outline),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: AppSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonRadius,
          ),
          minimumSize: const Size(64, 40),
        ),
      ),

      // Input Decoration (Dark Mode - Design System)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackgroundDarkMode, // #404040
        contentPadding: AppSpacing.inputPadding,
        border: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide(color: AppColors.borderDarkMode), // #404040
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide(color: AppColors.primaryDarkMode, width: 2), // #FAFAFA
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide(color: AppColors.errorLight),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide(color: AppColors.errorLight, width: 2),
        ),
        labelStyle: TextStyle(color: AppColors.textSecondaryDark),
        hintStyle: TextStyle(color: AppColors.textTertiaryDark),
      ),

      // Navigation Bar (Material 3 - Dark Mode)
      navigationBarTheme: NavigationBarThemeData(
        height: 80,
        backgroundColor: AppColors.surfaceDark, // #252525
        indicatorColor: AppColors.mutedDarkMode, // #404040
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryDarkMode, // #FAFAFA
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textTertiaryDark,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: AppColors.primaryLight,
              size: 24,
            );
          }
          return const IconThemeData(
            color: AppColors.textTertiaryDark,
            size: 24,
          );
        }),
      ),

      // Bottom Navigation Bar (legacy)
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.textTertiaryDark,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.neutral900,
        elevation: 4,
        shape: const CircleBorder(),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.largeRadius,
        ),
        backgroundColor: AppColors.surfaceDark,
        elevation: 8,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryDark,
        ),
      ),

      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.bottomSheetRadius,
        ),
        elevation: 8,
        dragHandleColor: AppColors.neutral600,
        dragHandleSize: const Size(32, 4),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.smallRadius,
        ),
        backgroundColor: AppColors.neutral700,
        contentTextStyle: const TextStyle(
          color: AppColors.neutral50,
          fontSize: 14,
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.neutral800,
        selectedColor: AppColors.primaryLight.withValues(alpha: 0.3),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.smallRadius,
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // ListTile
      listTileTheme: ListTileThemeData(
        contentPadding: AppSpacing.listItemPadding,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.smallRadius,
        ),
        tileColor: Colors.transparent,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: AppColors.neutral700,
        thickness: 1,
        space: 1,
      ),

      // Progress Indicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primaryLight,
        linearTrackColor: AppColors.neutral700,
        circularTrackColor: AppColors.neutral700,
      ),
    );
  }
}
