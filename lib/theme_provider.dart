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

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setThemeColors(Color brand, Color bg) {
    _brandColor = brand;
    _bgColor = bg;
    notifyListeners();
  }

  void setPureBlackDarkMode(bool value) {
    _pureBlackDarkMode = value;
    notifyListeners();
  }
}
