import 'package:flutter/material.dart';
import 'package:naspend/core/constants/app_constants.dart';
import 'package:naspend/shared/widgets/expanded_color_seed_action.dart';

class ExpandedTrailingActions extends StatelessWidget {
  const ExpandedTrailingActions({
    super.key,
    required this.useLightMode,
    required this.handleBrightnessChange,
    required this.handleColorSelect,
    required this.colorSelected,
  });

  final void Function(bool) handleBrightnessChange;
  final void Function(int) handleColorSelect;

  final bool useLightMode;

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
          Row(
            children: [
              const Text('Giao diện'),
              Expanded(child: Container()),
              Switch(
                value: useLightMode,
                onChanged: (value) {
                  handleBrightnessChange(value);
                },
              ),
            ],
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
