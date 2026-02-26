import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _brandColorKey = 'brand_color';
  static const String _bgColorKey = 'bg_color';
  static const String _pureBlackKey = 'pure_black_dark_mode';

  ThemeMode _themeMode = ThemeMode.system;
  Color _brandColor = Colors.black;
  Color _bgColor = Colors.white;
  bool _pureBlackDarkMode = false;

  ThemeProvider() {
    loadFromPrefs();
  }

  ThemeMode get themeMode => _themeMode;
  Color get brandColor => _brandColor;
  Color get bgColor => _bgColor;
  bool get pureBlackDarkMode => _pureBlackDarkMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark || _pureBlackDarkMode;

  Color get effectiveBgColor {
    if (_pureBlackDarkMode) {
      return Colors.black;
    }
    return _bgColor;
  }

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final modeIndex = prefs.getInt(_themeModeKey);
    if (modeIndex != null) {
      _themeMode = ThemeMode.values[modeIndex];
    }

    final brandValue = prefs.getInt(_brandColorKey);
    if (brandValue != null) {
      _brandColor = Color(brandValue);
    }

    final bgValue = prefs.getInt(_bgColorKey);
    if (bgValue != null) {
      _bgColor = Color(bgValue);
    }

    _pureBlackDarkMode = prefs.getBool(_pureBlackKey) ?? false;

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    _pureBlackDarkMode = (mode == ThemeMode.dark);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
    await prefs.setBool(_pureBlackKey, _pureBlackDarkMode);
  }

  Future<void> setThemeColors(Color brand, Color bg) async {
    _brandColor = brand;
    _bgColor = bg;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_brandColorKey, brand.value);
    await prefs.setInt(_bgColorKey, bg.value);
  }

  Future<void> setPureBlackDarkMode(bool value) async {
    _pureBlackDarkMode = value;
    _themeMode = value ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pureBlackKey, value);
    await prefs.setInt(_themeModeKey, _themeMode.index);
  }
}
