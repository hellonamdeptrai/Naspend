import 'package:flutter/material.dart';
import 'package:naspend/core/constants/app_constants.dart';
import 'package:naspend/shared/widgets/expanded_color_seed_action.dart';

class ExpandedTrailingActions extends StatelessWidget {
  const ExpandedTrailingActions({
    super.key,
    required this.currentThemeMode,
    required this.handleThemeModeChange,
    required this.handleColorSelect,
    required this.colorSelected,
  });

  final ThemeMode currentThemeMode;
  final void Function(ThemeMode) handleThemeModeChange;

  final void Function(int) handleColorSelect;
  final ColorSeed colorSelected;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final trailingActionsBody = Container(
      constraints: const BoxConstraints.tightFor(width: 250),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Giao diện'),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: const <ButtonSegment<ThemeMode>>[
              ButtonSegment<ThemeMode>(
                value: ThemeMode.light,
                icon: Icon(Icons.light_mode_outlined),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.dark,
                icon: Icon(Icons.dark_mode_outlined),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.system,
                icon: Icon(Icons.brightness_auto_outlined),
              ),
            ],
            selected: <ThemeMode>{currentThemeMode},
            onSelectionChanged: (Set<ThemeMode> newSelection) {
              handleThemeModeChange(newSelection.first);
            },
          ),
          const Divider(),
          ExpandedColorSeedAction(
            handleColorSelect: handleColorSelect,
            colorSelected: colorSelected
          ),
        ],
      ),
    );
    return screenHeight > 740
        ? trailingActionsBody
        : SingleChildScrollView(child: trailingActionsBody);
  }
}
