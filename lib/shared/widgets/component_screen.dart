import 'package:flutter/material.dart';

const rowDivider = SizedBox(width: 20);
const colDivider = SizedBox(height: 10);
const tinySpacing = 3.0;
const smallSpacing = 10.0;
const double widthConstraint = 450;

const List<NavigationDestination> appBarDestinations = [
  NavigationDestination(
    tooltip: '',
    icon: Icon(Icons.dashboard_outlined),
    label: 'Tổng quan',
    selectedIcon: Icon(Icons.dashboard),
  ),
  NavigationDestination(
    tooltip: '',
    icon: Icon(Icons.edit_outlined),
    label: 'Ghi chú',
    selectedIcon: Icon(Icons.edit),
  ),
  NavigationDestination(
    tooltip: '',
    icon: Icon(Icons.calendar_month_outlined),
    label: 'Lịch',
    selectedIcon: Icon(Icons.calendar_month),
  ),
  NavigationDestination(
    tooltip: '',
    icon: Icon(Icons.settings_outlined),
    label: 'Cài đặt',
    selectedIcon: Icon(Icons.settings),
  ),
];

class NavigationBars extends StatefulWidget {
  const NavigationBars({
    super.key,
    this.onSelectItem,
    required this.selectedIndex,
  });

  final void Function(int)? onSelectItem;
  final int selectedIndex;

  @override
  State<NavigationBars> createState() => _NavigationBarsState();
}

class _NavigationBarsState extends State<NavigationBars> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(covariant NavigationBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      selectedIndex = widget.selectedIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget navigationBar = Focus(
      autofocus: true,
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
          widget.onSelectItem!(index);
        },
        destinations: appBarDestinations,
      ),
    );
    return navigationBar;
  }
}

class ComponentDecoration extends StatefulWidget {
  const ComponentDecoration({
    super.key,
    this.label = '',
    required this.child,
    this.tooltipMessage = '',
  });

  final String? label;
  final Widget child;
  final String? tooltipMessage;

  @override
  State<ComponentDecoration> createState() => _ComponentDecorationState();
}

class _ComponentDecorationState extends State<ComponentDecoration> {
  final focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: smallSpacing),
        child: Column(
          children: [
            widget.label!.isNotEmpty ? TitleTooltip(
              label: widget.label!,
              tooltipMessage: widget.tooltipMessage,
            ) : Container(),
            ConstrainedBox(
              constraints: const BoxConstraints.tightFor(
                width: widthConstraint,
              ),
              child: Focus(
                focusNode: focusNode,
                canRequestFocus: true,
                child: GestureDetector(
                  onTapDown: (_) {
                    focusNode.requestFocus();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5.0,
                        vertical: 20.0,
                      ),
                      child: Center(child: widget.child),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TitleTooltip extends StatelessWidget {
  const TitleTooltip({
    super.key,
    required this.label,
    this.tooltipMessage = '',
  });

  final String label;
  final String? tooltipMessage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Tooltip(
          message: tooltipMessage,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.0),
            child: Icon(Icons.info_outline, size: 16),
          ),
        ),
      ],
    );
  }
}


class ClearButton extends StatelessWidget {
  const ClearButton({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => IconButton(
    icon: const Icon(Icons.clear),
    onPressed: () => controller.clear(),
  );
}