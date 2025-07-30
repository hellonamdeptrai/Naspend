import 'package:flutter/material.dart';
import 'package:naspend/core/constants/app_constants.dart';

class HomeViewModel extends ChangeNotifier {
  // --- Trạng thái (State) ---
  int _screenIndex = ScreenSelected.component.value;
  bool _showMediumSizeLayout = false;
  bool _showLargeSizeLayout = false;
  bool _controllerInitialized = false;

  // --- Getters để View truy cập trạng thái ---
  int get screenIndex => _screenIndex;
  bool get showMediumSizeLayout => _showMediumSizeLayout;
  bool get showLargeSizeLayout => _showLargeSizeLayout;

  // --- Logic xử lý (Methods) ---
  void handleScreenChanged(int screenSelected) {
    _screenIndex = screenSelected;
    notifyListeners();
  }

  // Logic kiểm tra layout được chuyển từ `didChangeDependencies` vào đây
  void updateLayout(double width, AnimationController controller) {
    final AnimationStatus status = controller.status;
    bool needsNotify = false;

    if (width > mediumWidthBreakpoint) {
      if (width > largeWidthBreakpoint) {
        if (_showMediumSizeLayout || !_showLargeSizeLayout) {
          _showMediumSizeLayout = false;
          _showLargeSizeLayout = true;
          needsNotify = true;
        }
      } else {
        if (!_showMediumSizeLayout || _showLargeSizeLayout) {
          _showMediumSizeLayout = true;
          _showLargeSizeLayout = false;
          needsNotify = true;
        }
      }
      if (status != AnimationStatus.forward &&
          status != AnimationStatus.completed) {
        controller.forward();
      }
    } else {
      if (_showMediumSizeLayout || _showLargeSizeLayout) {
        _showMediumSizeLayout = false;
        _showLargeSizeLayout = false;
        needsNotify = true;
      }
      if (status != AnimationStatus.reverse &&
          status != AnimationStatus.dismissed) {
        controller.reverse();
      }
    }
    if (!_controllerInitialized) {
      _controllerInitialized = true;
      controller.value = width > mediumWidthBreakpoint ? 1 : 0;
    }

    if (needsNotify) {
      notifyListeners();
    }
  }
}