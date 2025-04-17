import 'package:shared_preferences/shared_preferences.dart';

class ThemePreference {
  static const String _themeKey = 'themeMode';

  Future<void> setTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  Future<bool> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? true; // Default to dark mode
  }
}
