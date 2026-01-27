import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:delta_compressor_202501017/core/const/app_color.dart';
import 'package:delta_compressor_202501017/feature/article/screen/article_page.dart';
import 'package:delta_compressor_202501017/feature/home/screen/home_page.dart';
import 'package:delta_compressor_202501017/feature/main_shell/viewmodel/main_shell_viewmodel.dart';
import 'package:delta_compressor_202501017/feature/profile/screen/profile_page.dart';
import 'package:delta_compressor_202501017/feature/service/screen/service_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key});

  static const String pagePath = '/home';
  static const String pageName = 'home';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MainShellViewModel(context: context),
      child: const MainShellWidget(),
    );
  }
}

class MainShellWidget extends StatefulWidget {
  const MainShellWidget({super.key});

  @override
  State<MainShellWidget> createState() => _MainShellWidgetState();
}

class _MainShellWidgetState extends State<MainShellWidget> {
  late final MainShellViewModel _viewModel;

  static const int _maxBottomBarCount = 5;

  static List<BottomBarItem> get _bottomBarItems => [
    const BottomBarItem(
      inActiveItem: Icon(
        Symbols.home,
        color: AppColors.dark,
        size: 28,
        weight: 500,
      ),
      activeItem: Icon(
        Symbols.home,
        color: AppColors.light,
        size: 28,
        weight: 500,
      ),
      itemLabel: 'Home',
    ),
    const BottomBarItem(
      inActiveItem: Icon(
        Symbols.mobile_wrench,
        color: AppColors.dark,
        size: 28,
        weight: 500,
      ),
      activeItem: Icon(
        Symbols.mobile_wrench,
        color: AppColors.light,
        size: 28,
        weight: 500,
      ),
      itemLabel: 'Service',
    ),
    const BottomBarItem(
      inActiveItem: Icon(
        Symbols.article,
        color: AppColors.dark,
        size: 28,
        weight: 500,
      ),
      activeItem: Icon(
        Symbols.article,
        color: AppColors.light,
        size: 28,
        weight: 500,
      ),
      itemLabel: 'Article',
    ),
    const BottomBarItem(
      inActiveItem: Icon(
        Symbols.person,
        color: AppColors.dark,
        size: 28,
        weight: 500,
      ),
      activeItem: Icon(
        Symbols.person,
        color: AppColors.light,
        size: 28,
        weight: 500,
      ),
      itemLabel: 'Profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<MainShellViewModel>();
    _viewModel.attachContext(context);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomePage(),
      const ServicePage(),
      const ArticlePage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: PageView(
        controller: _viewModel.pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: pages,
      ),
      extendBody: true,
      bottomNavigationBar: (pages.length <= _maxBottomBarCount)
          ? AnimatedNotchBottomBar(
              notchBottomBarController: _viewModel.notchController,
              color: AppColors.light,
              showLabel: true,
              textOverflow: TextOverflow.visible,
              maxLine: 1,
              shadowElevation: 5,
              kBottomRadius: 28.0,
              bottomBarHeight: 76.h,
              notchColor: AppColors.success,
              removeMargins: true,
              bottomBarWidth: 500,
              showShadow: false,
              durationInMilliSeconds: 300,
              itemLabelStyle: TextStyle(
                fontSize: 16.sp,
                color: AppColors.dark,
                fontWeight: FontWeight.w500,
                fontFamily: 'DB_Helvethaica_X',
                fontStyle: FontStyle.normal,
              ),
              elevation: 1,
              bottomBarItems: _bottomBarItems,
              onTap: _viewModel.onTabTap,
              kIconSize: 28.0,
              inactiveItemTopOffset: -6,
            )
          : null,
    );
  }
}

