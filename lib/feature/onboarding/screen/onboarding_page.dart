import 'package:delta_compressor_202501017/core/const/app_color.dart';
import 'package:delta_compressor_202501017/core/data/remote/models/response/app_introductions_response.dart';
import 'package:delta_compressor_202501017/core/utils/ui_result.dart';
import 'package:delta_compressor_202501017/core/widgets/app_text.dart';
import 'package:delta_compressor_202501017/feature/first_loading/repository/introductions_repo.dart';
import 'package:delta_compressor_202501017/feature/home/repository/home_repo.dart';
import 'package:delta_compressor_202501017/feature/onboarding/viewmodel/onboarding_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  static final pagePath = '/onboarding';
  static final pageName = 'onboarding';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => OnboardingViewmodel(
        context: context,
        introductionsDataSource: IntroductionsRepo(),
        homeDataSource: HomeRepo(),
      ),
      child: const OnboardingWidget(),
    );
  }
}

class OnboardingWidget extends StatefulWidget {
  const OnboardingWidget({super.key});

  @override
  State<OnboardingWidget> createState() => _OnboardingWidgetState();
}

class _OnboardingWidgetState extends State<OnboardingWidget> {
  late final OnboardingViewmodel _viewmodel;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _viewmodel = context.read<OnboardingViewmodel>();
    _viewmodel.attachContext(context);
    _pageController = PageController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _viewmodel.fetchOnboardingData();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    _viewmodel.setCurrentPage(page);
  }

  void _nextPage() {
    final items = _viewmodel.onboardingItems.requireData;
    if (_viewmodel.currentPage < items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _viewmodel.completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Selector<OnboardingViewmodel, UiResult<List<OnboardingItem>>>(
        selector: (context, provider) => provider.onboardingItems,
        builder: (context, result, child) {
          if (result.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.success),
            );
          }

          if (result.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.danger),
                  const SizedBox(height: 16),
                  Text('Error: ${result.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _viewmodel.fetchOnboardingData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (result.isEmpty) {
            return const Center(
              child: Text(
                'No onboarding data available',
                style: TextStyle(color: AppColors.light),
              ),
            );
          }

          final items = result.requireData;
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'No onboarding items',
                style: TextStyle(color: AppColors.light),
              ),
            );
          }

          return Stack(
            children: [
              // PageView with onboarding items
              PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _buildOnboardingItem(item, items.length);
                },
              ),
              // Bottom controls
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomControls(items.length),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOnboardingItem(OnboardingItem item, int totalPages) {
    return Column(
      children: [
        // Image section
        SizedBox(
          height: 500.h,
          width: double.infinity,
          child: item.image != null && item.image!.isNotEmpty
              ? Image.network(
                  item.image!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 500.h,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.success,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.softDark,
                      child: const Center(
                        child: Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppColors.danger,
                        ),
                      ),
                    );
                  },
                )
              : Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: AppColors.grey,
                    ),
                  ),
                ),
        ),
        // Content section
        Expanded(
          child: Container(
            color: AppColors.black,
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page indicators at top of black section
                Selector<OnboardingViewmodel, int>(
                  selector: (context, provider) => provider.currentPage,
                  builder: (context, currentPage, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(
                        totalPages,
                        (index) => Container(
                          width: index == currentPage ? 19.w : 8.w,
                          height: 8.h,
                          margin: EdgeInsets.symmetric(horizontal: 2.w),
                          decoration: BoxDecoration(
                            shape: index == currentPage
                                ? BoxShape.rectangle
                                : BoxShape.circle,
                            borderRadius: index == currentPage
                                ? BorderRadius.circular(12.r)
                                : null,
                            color: index == currentPage
                                ? AppColors.success
                                : AppColors.light,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 16.h),
                // Title (success) + Subtitle (light) — ข้อความธรรมดา
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.title != null && item.title!.isNotEmpty)
                          AppText(
                            item.title!,
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                        if (item.title != null && item.title!.isNotEmpty &&
                            item.subtitle != null && item.subtitle!.isNotEmpty)
                          SizedBox(height: 12.h),
                        if (item.subtitle != null && item.subtitle!.isNotEmpty)
                          AppText(
                            item.subtitle!,
                            style: TextStyle(
                              color: AppColors.light,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls(int totalPages) {
    return Selector<OnboardingViewmodel, int>(
      selector: (context, provider) => provider.currentPage,
      builder: (context, currentPage, child) {
        final isLastPage = currentPage == totalPages - 1;
        return Container(
          color: AppColors.black,
          padding: EdgeInsets.only(
            left: 24.w,
            right: 24.w,
            top: 24.h,
            bottom: isLastPage ? 40.h : 24.h,
          ),
          child: isLastPage
              ? Center(
                  child: ElevatedButton(
                    onPressed: () => _viewmodel.completeOnboarding(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: AppColors.light,
                      minimumSize: Size(310.w, 50.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: AppText(
                      'GET STARTED',
                      style: TextStyle(
                        color: AppColors.light,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // SKIP button (left side)
                    TextButton(
                      onPressed: () => _viewmodel.skipOnboarding(),
                      child: Text(
                        'SKIP',
                        style: TextStyle(
                          color: const Color(0xFFFFD400),
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Next button (right side)
                    GestureDetector(
                      onTap: _nextPage,
                      child: Container(
                        width: 40.w,
                        height: 40.h,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.success,
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/svg/OnBoardingRightArrow.svg',
                            width: 36.w,
                            height: 36.h,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
