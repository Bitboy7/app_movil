import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  static const _key = 'dark_mode';

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_key) ?? false;
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = state == ThemeMode.light;
    await prefs.setBool(_key, isDark);
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}

final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  return themeMode == ThemeMode.dark;
});