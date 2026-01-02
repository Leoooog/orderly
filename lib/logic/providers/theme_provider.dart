import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../config/hive_keys.dart';


final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    print("[ThemeModeNotifier] build");
    final box = Hive.box(HiveKeys.settingsBox);
    final theme = box.get(HiveKeys.themeMode, defaultValue: 'system');
    print("[ThemeModeNotifier] initial theme: $theme");
    switch (theme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void setThemeMode(ThemeMode themeMode) {
    print("[ThemeModeNotifier] setThemeMode: $themeMode");
    final box = Hive.box(HiveKeys.settingsBox);
    String theme;
    switch (themeMode) {
      case ThemeMode.light:
        theme = 'light';
        break;
      case ThemeMode.dark:
        theme = 'dark';
        break;
      case ThemeMode.system:
        theme = 'system';
        break;
    }
    box.put(HiveKeys.themeMode, theme);
    state = themeMode;
  }
}
