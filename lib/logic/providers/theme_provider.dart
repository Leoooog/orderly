import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:orderly/data/hive_keys.dart';

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final box = Hive.box(kSettingsBox);
    final storedTheme =
        box.get(kThemeModeKey, defaultValue: 'system') as String;
    return ThemeMode.values.firstWhere(
      (mode) => mode.toString() == storedTheme,
      orElse: () => ThemeMode.system,
    );
  }

  void setTheme(ThemeMode mode) {
    final box = Hive.box(kSettingsBox);
    box.put(kThemeModeKey, mode.toString());
    state = mode;
  }

  void setSystem() {
    state = ThemeMode.system;
  }
}
