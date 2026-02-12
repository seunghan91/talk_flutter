part of 'theme_cubit.dart';

/// Theme state holding the current theme mode
class ThemeState extends Equatable {
  final ThemeMode themeMode;

  const ThemeState({
    this.themeMode = ThemeMode.system,
  });

  /// Whether the current theme mode is dark
  bool get isDarkMode => themeMode == ThemeMode.dark;

  /// Whether the current theme mode is light
  bool get isLightMode => themeMode == ThemeMode.light;

  /// Whether the current theme mode follows the system setting
  bool get isSystemMode => themeMode == ThemeMode.system;

  ThemeState copyWith({ThemeMode? themeMode}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object> get props => [themeMode];
}
