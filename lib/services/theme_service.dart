import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const _themeKey = 'is_dark_mode';
  
  // ValueNotifier to allow components to listen for theme changes reactively
  static final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(true);

  static bool get isDarkMode => isDarkModeNotifier.value;

  // Curated, beautiful theme colors for Dark & Light modes
  static Color get neonColor => isDarkMode ? const Color(0xFF00FF88) : const Color(0xFF00BFA5);
  static Color get backgroundColor => isDarkMode ? const Color(0xFF121217) : const Color(0xFFF4F6F8);
  static Color get surfaceColor => isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFFFFFFF);
  static Color get cardColor => isDarkMode ? const Color(0xFF1C1C1C) : const Color(0xFFFFFFFF);
  static Color get mutedColor => isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF475569);
  static Color get textColor => isDarkMode ? Colors.white : const Color(0xFF0F172A);
  static Color get dangerColor => const Color(0xFFFF4444);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to dark mode (true)
    isDarkModeNotifier.value = prefs.getBool(_themeKey) ?? true;
  }

  static Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkModeNotifier.value = !isDarkModeNotifier.value;
    await prefs.setBool(_themeKey, isDarkModeNotifier.value);
  }

  static Future<void> setTheme(bool dark) async {
    final prefs = await SharedPreferences.getInstance();
    isDarkModeNotifier.value = dark;
    await prefs.setBool(_themeKey, dark);
  }
}
