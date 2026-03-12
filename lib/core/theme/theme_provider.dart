// lib/core/theme/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeMode_ extends _$ThemeMode_ {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    // Default: dark (5am gardener mode)
    _loadFromPrefs();
    return ThemeMode.dark;
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved == 'light') state = ThemeMode.light;
    if (saved == 'dark')  state = ThemeMode.dark;
  }

  Future<void> toggle() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, next == ThemeMode.dark ? 'dark' : 'light');
  }

  bool get isDark => state == ThemeMode.dark;
}
