import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider che espone la Locale corrente
final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

class LocaleNotifier extends Notifier<Locale> {

  @override
  Locale build() {
    // Qui potresti leggere da Hive/SharedPreferences l'ultima lingua salvata
    // Per ora partiamo con l'italiano di default
    return const Locale('it');
  }

  void setLocale(Locale locale) {
    state = locale;
    // Qui in futuro salverai la preferenza su disco
  }

  void toggleLocale() {
    state = state.languageCode == 'it' ? const Locale('en') : const Locale('it');
  }
}