import 'package:flutter/material.dart';
import 'package:naspend/core/constants/app_constants.dart';
import 'package:naspend/shared/widgets/buttons.dart';
import 'package:naspend/shared/widgets/component_screen.dart';
import 'package:naspend/shared/widgets/expanded_trailing_actions.dart';
import 'package:naspend/shared/widgets/navigation_transition.dart';
import 'package:naspend/ui/home/view_model/home_view_model.dart';
import 'package:naspend/ui/setting/view_model/theme_settings_view_model.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late final AnimationController controller;
  late final CurvedAnimation railAnimation;

  @override
  initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(milliseconds: transitionLength.toInt() * 2),
      value: 0,
      vsync: this,
    );
    railAnimation = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.5, 1.0),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final double width = MediaQuery.of(context).size.width;
    context.read<HomeViewModel>().updateLayout(width, controller);
  }

  PreferredSizeWidget _createAppBar(ThemeSettingsViewModel themeVM) {
    final homeVM = context.read<HomeViewModel>();
    return AppBar(
      title: const Text('Naspend - Sổ thu chi'),
      actions: !homeVM.showMediumSizeLayout && !homeVM.showLargeSizeLayout
          ? [
        BrightnessButton(
          handleBrightnessChange: themeVM.handleBrightnessChange,
        ),
        ColorSeedButton(
          handleColorSelect: themeVM.handleColorSelect,
          colorSelected: themeVM.colorSelected,
        ),
      ]
          : [Container()],
    );
  }

  Widget _trailingActions(ThemeSettingsViewModel themeVM) => Column(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Flexible(
        child: BrightnessButton(
          handleBrightnessChange: themeVM.handleBrightnessChange,
          showTooltipBelow: false,
        ),
      ),
      Flexible(
        child: ColorSeedButton(
          handleColorSelect: themeVM.handleColorSelect,
          colorSelected: themeVM.colorSelected,
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final homeVM = context.watch<HomeViewModel>();
    final themeVM = context.watch<ThemeSettingsViewModel>();

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return NavigationTransition(
          scaffoldKey: scaffoldKey,
          animationController: controller,
          railAnimation: railAnimation,
          appBar: _createAppBar(themeVM),
          body: Container(),
          navigationRail: NavigationRail(
            extended: homeVM.showLargeSizeLayout,
            destinations: _navRailDestinations,
            selectedIndex: homeVM.screenIndex,
            onDestinationSelected: (index) {
              homeVM.handleScreenChanged(index);
            },
            trailing: Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: homeVM.showLargeSizeLayout
                    ? ExpandedTrailingActions(
                  useLightMode: themeVM.useLightMode,
                  handleBrightnessChange: themeVM.handleBrightnessChange,
                  handleColorSelect: themeVM.handleColorSelect,
                  colorSelected: themeVM.colorSelected,
                )
                    : _trailingActions(themeVM),
              ),
            ),
          ),
          navigationBar: NavigationBars(
            onSelectItem: (index) {
              homeVM.handleScreenChanged(index);
            },
            selectedIndex: homeVM.screenIndex,
          ),
        );
      },
    );
  }
}

final List<NavigationRailDestination> _navRailDestinations = appBarDestinations
    .map(
      (destination) => NavigationRailDestination(
    icon: Tooltip(message: destination.label, child: destination.icon),
    selectedIcon: Tooltip(
      message: destination.label,
      child: destination.selectedIcon,
    ),
    label: Text(destination.label),
  ),
)
    .toList(growable: false);
