import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../player/audio_library.dart';
import '../config/app_config.dart';

const appLocaleKey = 'app.locale';
const defaultLocale = Locale('my');
const supportedLocales = [Locale('my'), Locale('en')];

class LocaleController extends Notifier<Locale> {
  @override
  Locale build() {
    final code = ref.read(sharedPreferencesProvider).getString(appLocaleKey);
    return supportedLocales.firstWhere(
      (locale) => locale.languageCode == code,
      orElse: () => defaultLocale,
    );
  }

  Future<void> setLocale(Locale locale) async {
    if (locale == state) return;
    state = locale;
    ref.read(audioLibraryProvider).languageCode = locale.languageCode;
    await ref
        .read(sharedPreferencesProvider)
        .setString(appLocaleKey, locale.languageCode);
  }
}

final localeProvider = NotifierProvider<LocaleController, Locale>(
  LocaleController.new,
);
