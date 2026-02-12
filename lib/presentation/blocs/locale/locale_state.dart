part of 'locale_cubit.dart';

/// Locale state holding the current app locale
class LocaleState extends Equatable {
  final Locale locale;

  const LocaleState({
    this.locale = const Locale('ko', 'KR'),
  });

  /// Human-readable display name for the current locale
  String get displayName {
    switch (locale.languageCode) {
      case 'ko':
        return '\uD55C\uAD6D\uC5B4';
      case 'en':
        return 'English';
      default:
        return locale.languageCode;
    }
  }

  LocaleState copyWith({Locale? locale}) {
    return LocaleState(
      locale: locale ?? this.locale,
    );
  }

  @override
  List<Object> get props => [locale];
}
