import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static final ValueNotifier<bool> isDarkMode = ValueNotifier(true);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = prefs.getBool('isDarkMode') ?? true;
  }

  static void toggleTheme(bool isDark) async {
    isDarkMode.value = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }
}
