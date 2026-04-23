import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/shared_prefs_keys.dart';

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPrefsProvider must be overridden in main');
});

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return ThemeModeNotifier(prefs);
});

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return LocaleNotifier(prefs);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._prefs) : super(_loadThemeMode(_prefs));

  final SharedPreferences _prefs;

  static ThemeMode _loadThemeMode(SharedPreferences prefs) {
    final raw = prefs.getString(SharedPrefsKeys.themeMode);
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _prefs.setString(SharedPrefsKeys.themeMode, value);
  }
}

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(this._prefs) : super(_loadLocale(_prefs));

  final SharedPreferences _prefs;

  static Locale _loadLocale(SharedPreferences prefs) {
    final code = prefs.getString(SharedPrefsKeys.localeCode) ?? 'en';
    return Locale(code);
  }

  Future<void> setLocale(String code) async {
    state = Locale(code);
    await _prefs.setString(SharedPrefsKeys.localeCode, code);
  }
}
