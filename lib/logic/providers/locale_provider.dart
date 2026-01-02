import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../config/hive_keys.dart';


// Provider che espone la Locale corrente
final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    print("[LocaleNotifier] build");
    final box = Hive.box(HiveKeys.settingsBox);
    final languageCode = box.get(HiveKeys.language, defaultValue: 'en');
    print("[LocaleNotifier] initial language code: $languageCode");
    return Locale(languageCode);
  }

  void setLocale(Locale locale) {
    print("[LocaleNotifier] setLocale: ${locale.languageCode}");
    final box = Hive.box(HiveKeys.settingsBox);
    box.put(HiveKeys.language, locale.languageCode);
    state = locale;
  }

  void toggleLocale() {
    state = state.languageCode == 'it' ? const Locale('en') : const Locale('it');
  }
}