import 'package:flutter/material.dart';
import 'package:naspend/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeSettingsViewModel extends ChangeNotifier {
  late SharedPreferences _prefs;

  // --- Khai báo các key để lưu trữ ---
  static const _themeKey = 'theme_mode';
  static const _colorKey = 'color_seed';

  // --- Trạng thái ---
  ThemeMode _themeMode = ThemeMode.system;
  ColorSeed _colorSelected = ColorSeed.yellow;

  // --- Getters ---
  ThemeMode get themeMode => _themeMode;
  ColorSeed get colorSelected => _colorSelected;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    final themeIndex = _prefs.getInt(_themeKey) ?? ThemeMode.system.index;
    _themeMode = ThemeMode.values[themeIndex];

    final colorIndex = _prefs.getInt(_colorKey) ?? ColorSeed.yellow.index;
    _colorSelected = ColorSeed.values[colorIndex];

    notifyListeners();
  }

  void cycleThemeMode() {
    ThemeMode nextThemeMode;
    switch (_themeMode) {
      case ThemeMode.light:
        nextThemeMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        nextThemeMode = ThemeMode.system;
        break;
      case ThemeMode.system:
        nextThemeMode = ThemeMode.light;
        break;
    }
    handleThemeModeChange(nextThemeMode);
  }

  // --- Actions ---
  void handleThemeModeChange(ThemeMode mode) {
    if (_themeMode == mode) return; // Không thay đổi nếu giống hệt
    _themeMode = mode;
    notifyListeners();
    _prefs.setInt(_themeKey, mode.index);
  }

  void handleColorSelect(int value) {
    if (_colorSelected.index == value) return;
    _colorSelected = ColorSeed.values[value];
    notifyListeners();
    _prefs.setInt(_colorKey, value);
  }

}