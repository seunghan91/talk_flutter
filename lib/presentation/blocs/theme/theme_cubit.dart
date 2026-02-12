import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:equatable/equatable.dart';

part 'theme_state.dart';

/// ThemeCubit - manages app theme mode with persistence via HydratedBloc
class ThemeCubit extends HydratedCubit<ThemeState> {
  ThemeCubit() : super(const ThemeState()) {
    // Force dark mode in debug for development testing
    if (kDebugMode && state.themeMode != ThemeMode.dark) {
      setThemeMode(ThemeMode.dark);
    }
  }

  /// Toggle between light and dark mode
  void toggleDarkMode() {
    emit(state.copyWith(
      themeMode: state.themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light,
    ));
  }

  /// Set a specific theme mode
  void setThemeMode(ThemeMode mode) {
    emit(state.copyWith(themeMode: mode));
  }

  @override
  ThemeState? fromJson(Map<String, dynamic> json) {
    try {
      final modeIndex = json['themeMode'] as int? ?? 0;
      return ThemeState(
        themeMode: ThemeMode.values[modeIndex],
      );
    } catch (_) {
      return const ThemeState();
    }
  }

  @override
  Map<String, dynamic>? toJson(ThemeState state) {
    return {
      'themeMode': state.themeMode.index,
    };
  }
}
