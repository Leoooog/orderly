import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../config/hive_keys.dart';


final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final box = Hive.box(HiveKeys.settingsBox);
    final storedTheme =
        box.get(HiveKeys.themeMode, defaultValue: 'system') as String;
    return ThemeMode.values.firstWhere(
      (mode) => mode.toString() == storedTheme,
      orElse: () => ThemeMode.system,
    );
  }

  void setTheme(ThemeMode mode) {
    final box = Hive.box(HiveKeys.settingsBox);
    box.put(HiveKeys.themeMode, mode.toString());
    state = mode;
  }

  void setSystem() {
    setTheme(ThemeMode.system);
  }
}
