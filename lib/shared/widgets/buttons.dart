import 'package:flutter/material.dart';
import 'package:naspend/core/constants/app_constants.dart';

class BrightnessButton extends StatelessWidget {
  const BrightnessButton({
    super.key,
    required this.currentThemeMode,
    required this.cycleThemeMode,
    this.showTooltipBelow = true,
  });

  final ThemeMode currentThemeMode;
  final VoidCallback cycleThemeMode;
  final bool showTooltipBelow;

  Icon _buildIcon() {
    switch (currentThemeMode) {
      case ThemeMode.light:
        return const Icon(Icons.light_mode_outlined);
      case ThemeMode.dark:
        return const Icon(Icons.dark_mode_outlined);
      case ThemeMode.system:
        return const Icon(Icons.brightness_auto_outlined); // Icon cho chế độ hệ thống
    }
  }

  String _buildTooltip() {
    switch (currentThemeMode) {
      case ThemeMode.light:
        return 'Chuyển sang Giao diện Tối';
      case ThemeMode.dark:
        return 'Chuyển sang Giao diện Hệ thống';
      case ThemeMode.system:
        return 'Chuyển sang Giao diện Sáng';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      preferBelow: showTooltipBelow,
      message: _buildTooltip(),
      child: IconButton(
        icon: _buildIcon(),
        onPressed: cycleThemeMode,
      ),
    );
  }
}

class ColorSeedButton extends StatelessWidget {
  const ColorSeedButton({
    super.key,
    required this.handleColorSelect,
    required this.colorSelected,
  });

  final void Function(int) handleColorSelect;
  final ColorSeed colorSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: const Icon(Icons.palette_outlined),
      tooltip: 'Chọn màu giao diện',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      itemBuilder: (context) {
        return List.generate(ColorSeed.values.length, (index) {
          ColorSeed currentColor = ColorSeed.values[index];

          return PopupMenuItem(
            value: index,
            enabled: currentColor != colorSelected,
            child: Wrap(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Icon(
                    currentColor == colorSelected
                        ? Icons.color_lens
                        : Icons.color_lens_outlined,
                    color: currentColor.color,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(currentColor.label),
                ),
              ],
            ),
          );
        });
      },
      onSelected: handleColorSelect,
    );
  }
}
