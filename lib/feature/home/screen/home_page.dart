import 'package:carousel_slider/carousel_slider.dart';
import 'package:delta_compressor_202501017/core/const/app_color.dart';
import 'package:delta_compressor_202501017/core/utils/ui_result.dart';
import 'package:delta_compressor_202501017/core/widgets/app_text.dart';
import 'package:delta_compressor_202501017/feature/home/models/home_model.dart';
import 'package:delta_compressor_202501017/feature/home/repository/home_repo.dart';
import 'package:delta_compressor_202501017/feature/home/viewmodel/home_viewmodel.dart';
import 'package:delta_compressor_202501017/feature/main_shell/viewmodel/main_shell_viewmodel.dart';
import 'package:delta_compressor_202501017/feature/notification/screen/notification_page.dart';
import 'package:delta_compressor_202501017/feature/product/screen/product_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static final pagePath = '/home';
  static final pageName = 'home';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          HomeViewModel(context: context, homeDataSource: HomeRepo()),
      child: const HomeWidget(),
    );
  }
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<HomeViewModel>();
    _viewModel.attachContext(context);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _viewModel.fetchHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.black, AppColors.darkBlue],
          ),
        ),
        child: SafeArea(
          child: Selector<HomeViewModel, UiResult<HomeData>>(
            selector: (context, provider) => provider.homeData,
            builder: (context, homeDataResult, child) {
              if (homeDataResult.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.success),
                );
              }

              if (homeDataResult.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppColors.danger,
                      ),
                      const SizedBox(height: 16),
                      AppText(
                        'Error: ${homeDataResult.error}',
                        style: const TextStyle(color: AppColors.light),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _viewModel.fetchHomeData(),
                        child: AppText('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (homeDataResult.isEmpty) {
                return Center(
                  child: AppText(
                    'No data available',
                    style: const TextStyle(color: AppColors.light),
                  ),
                );
              }

              final homeData = homeDataResult.requireData;

              return NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                      return [
                        // Section 1: Header (Customer Info + Bell Icon)
                        SliverToBoxAdapter(
                          child: _buildHeader(homeData.customer),
                        ),
                        // Section 2: News & Updates (Carousel)
                        SliverToBoxAdapter(
                          child: _buildNewsSection(homeData.articles),
                        ),
                        // Section 3: My Product Header
                        SliverToBoxAdapter(child: _buildProductHeader()),
                      ];
                    },
                body: _buildProductList(homeData.products),
              );
            },
          ),
        ),
      ),
    );
  }

  // Section 1: Header
  Widget _buildHeader(CustomerInfo customer) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Transform.translate(
              offset: Offset(0, -4.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    customer.customerName,
                    style: TextStyle(
                      color: AppColors.light,
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppText(
                    customer.plant,
                    style: TextStyle(color: AppColors.light, fontSize: 22.sp),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            style: IconButton.styleFrom(
              alignment: Alignment.topCenter,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(Symbols.notifications, color: AppColors.light),
            onPressed: () => context.push(NotificationPage.pagePath),
          ),
        ],
      ),
    );
  }

  // Section 2: News & Updates
  Widget _buildNewsSection(List<ArticleItem> articles) {
    if (articles.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                'News & Updates',
                style: TextStyle(
                  color: AppColors.light,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  context.read<MainShellViewModel>().onTabTap(2); // Article tab
                },
                child: AppText(
                  'See More',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Container(
            height: 2.h,
            margin: EdgeInsets.only(right: 8.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              gradient: LinearGradient(
                colors: [AppColors.success, AppColors.light, AppColors.danger],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        // Carousel Slider
        CarouselSlider.builder(
          itemCount: articles.length,
          itemBuilder: (context, index, realIndex) {
            final article = articles[index];
            return _buildArticleCard(article);
          },
          options: CarouselOptions(
            height: 200.h,
            viewportFraction: 0.9,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              _viewModel.setCurrentArticleIndex(index);
            },
          ),
        ),
        SizedBox(height: 12.h),
        // Carousel Indicators
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              articles.length,
              (index) => Selector<HomeViewModel, int>(
                selector: (context, provider) => provider.currentArticleIndex,
                builder: (context, currentIndex, child) {
                  return Container(
                    width: currentIndex == index ? 12.w : 8.w,
                    height: 8.h,
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: currentIndex == index
                          ? AppColors.success
                          : Colors.grey.shade400,
                      shape: BoxShape.circle,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
      ],
    );
  }

  Widget _buildArticleCard(ArticleItem article) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: AppColors.softDark,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Image.network(
          article.image,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200.h,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.success,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.softDark,
              child: const Center(
                child: Icon(
                  Symbols.broken_image,
                  color: AppColors.light,
                  size: 48,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Section 3: My Product Header
  Widget _buildProductHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with "See More"
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                'My Product',
                style: TextStyle(
                  color: AppColors.light,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
          child: Container(
            height: 2.h,
            margin: EdgeInsets.only(right: 8.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              gradient: LinearGradient(
                colors: [AppColors.success, AppColors.light, AppColors.danger],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Section 3: My Product List
  Widget _buildProductList(List<ProductItem> products) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 100.h),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return GestureDetector(
          onTap: () => context.push(ProductDetailPage.pathFor(product.id)),
          child: _buildProductCard(product),
        );
      },
    );
  }

  Widget _buildProductCard(ProductItem product) {
    // Determine status color
    Color statusColor;
    Color statusTextColor;
    if (product.isOnline) {
      statusColor = AppColors.softGreen;
      statusTextColor = AppColors.success;
    } else if (product.isError) {
      statusColor = AppColors.softRed;
      statusTextColor = AppColors.danger;
    } else {
      statusColor = AppColors.softDark;
      statusTextColor = AppColors.dark;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: const [0.0, 0.3, 1],
          colors: [statusColor, statusColor, AppColors.light],
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Part 1: Product Image (left)
            Center(
              child: SizedBox(
                width: 70.w,
                height: 70.h,
                child: product.image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.network(
                          product.image!,
                          width: 70.w,
                          height: 70.h,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Symbols.broken_image,
                              color: AppColors.light,
                              size: 40,
                            );
                          },
                        ),
                      )
                    : Container(
                        width: 60.w,
                        height: 60.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: AppColors.light.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Symbols.precision_manufacturing,
                          color: AppColors.light,
                          size: 40,
                        ),
                      ),
              ),
            ),
            SizedBox(width: 12.w),
            // Part 2: Serial No and Model (middle)
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  AppText(
                    'SERIAL NO :',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.light,
                      height: 1.0,
                    ),
                  ),
                  AppText(
                    product.serialNo,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.light,
                      height: 1.0,
                    ),
                  ),
                  AppText(
                    'MODEL :',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.light,
                      height: 1.0,
                    ),
                  ),
                  AppText(
                    product.model,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.light,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            // Part 3: Status and Readings (right)
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Status badge - top right of Column
                  Container(
                    padding: EdgeInsets.zero,
                    child: AppText(
                      product.status,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: statusTextColor,
                      ),
                    ),
                  ),
                  // Temperature and Pressure readings - bottom right of Column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (product.temperature != null) ...[
                            Icon(
                              product.temperature! > 100
                                  ? Symbols.local_fire_department
                                  : Symbols.ac_unit,
                              size: 18,
                              color: product.temperature! > 100
                                  ? AppColors.danger
                                  : AppColors.primary,
                            ),
                            SizedBox(width: 4.w),
                          ],
                          AppText(
                            product.temperature != null
                                ? '${product.temperature!.toStringAsFixed(0)}${product.temperature! > 100 ? '°C' : ' °C'}'
                                : '_ _ °C',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: product.temperature != null
                                  ? (product.temperature! > 100
                                      ? AppColors.danger
                                      : AppColors.primary)
                                  : AppColors.dark,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (product.pressure != null) ...[
                            Icon(
                              Symbols.settings,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 4.w),
                          ],
                          AppText(
                            product.pressure != null
                                ? '${product.pressure!.toStringAsFixed(0)} BAR'
                                : '_ _ BAR',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: product.pressure != null
                                  ? AppColors.primary
                                  : AppColors.dark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
