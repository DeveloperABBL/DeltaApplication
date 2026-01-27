import 'package:delta_compressor_202501017/core/viewmodels/app_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';

class MainShellViewModel extends AppViewModel {
  MainShellViewModel({required super.context})
      : _pageController = PageController(initialPage: 0),
        _notchController = NotchBottomBarController(index: 0);

  final PageController _pageController;
  PageController get pageController => _pageController;

  final NotchBottomBarController _notchController;
  NotchBottomBarController get notchController => _notchController;

  int get currentIndex => _notchController.index;

  void onTabTap(int index) {
    _notchController.jumpTo(index);
    if (_pageController.hasClients) {
      _pageController.jumpToPage(index);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
