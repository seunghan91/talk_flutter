import 'dart:ui';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:equatable/equatable.dart';

part 'locale_state.dart';

/// LocaleCubit - manages app locale with persistence via HydratedBloc
class LocaleCubit extends HydratedCubit<LocaleState> {
  LocaleCubit() : super(const LocaleState());

  /// Set the app locale
  void setLocale(Locale locale) {
    emit(state.copyWith(locale: locale));
  }

  /// Supported locales for the app
  static const supportedLocales = [
    Locale('ko', 'KR'),
    Locale('en', 'US'),
  ];

  @override
  LocaleState? fromJson(Map<String, dynamic> json) {
    try {
      final languageCode = json['languageCode'] as String? ?? 'ko';
      final countryCode = json['countryCode'] as String? ?? 'KR';
      return LocaleState(locale: Locale(languageCode, countryCode));
    } catch (_) {
      return const LocaleState();
    }
  }

  @override
  Map<String, dynamic>? toJson(LocaleState state) {
    return {
      'languageCode': state.locale.languageCode,
      'countryCode': state.locale.countryCode,
    };
  }
}
