import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Color _brandColor = const Color(0xFFF97316);
  Color _bgColor = const Color(0xFFFFEDD5);
  bool _pureBlackDarkMode = false;

  ThemeMode get themeMode => _themeMode;
  Color get brandColor => _brandColor;
  Color get bgColor => _bgColor;
  bool get pureBlackDarkMode => _pureBlackDarkMode;

  Color get effectiveBgColor {
    if (_pureBlackDarkMode) {
      return Colors.black;
    }
    return _bgColor;
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    // Sync pure black with dark mode if needed, or keep them separate?
    // User said they are the same toggle.
    _pureBlackDarkMode = (mode == ThemeMode.dark);
    notifyListeners();
  }

  void setThemeColors(Color brand, Color bg) {
    _brandColor = brand;
    _bgColor = bg;
    notifyListeners();
  }

  void setPureBlackDarkMode(bool value) {
    _pureBlackDarkMode = value;
    _themeMode = value ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
