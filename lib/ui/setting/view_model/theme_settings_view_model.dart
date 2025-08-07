import 'package:flutter/material.dart';
import 'package:naspend/core/constants/app_constants.dart';

class ThemeSettingsViewModel extends ChangeNotifier {
  // --- Trạng thái ---
  ThemeMode _themeMode = ThemeMode.system;
  ColorSeed _colorSelected = ColorSeed.yellow;

  // --- Getters để View truy cập trạng thái ---
  ThemeMode get themeMode => _themeMode;
  ColorSeed get colorSelected => _colorSelected;

  bool get useLightMode => switch (_themeMode) {
    ThemeMode.system => true,
    ThemeMode.light => true,
    ThemeMode.dark => false,
  };

  void handleBrightnessChange(bool useLightMode) {
    _themeMode = useLightMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void handleColorSelect(int value) {
    _colorSelected = ColorSeed.values[value];
    notifyListeners();
  }

}