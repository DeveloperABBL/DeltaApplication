import 'package:carousel_slider/carousel_slider.dart';
import 'package:delta_compressor_202501017/core/const/app_color.dart';
import 'package:delta_compressor_202501017/core/widgets/app_text.dart';
import 'package:delta_compressor_202501017/feature/article/models/article_model.dart';
import 'package:delta_compressor_202501017/feature/article/screen/article_detail_page.dart';
import 'package:delta_compressor_202501017/feature/article/repository/article_repo.dart';
import 'package:delta_compressor_202501017/feature/article/viewmodel/article_viewmodel.dart';
import 'package:delta_compressor_202501017/feature/main_shell/viewmodel/main_shell_viewmodel.dart';
import 'package:delta_compressor_202501017/feature/notification/screen/notification_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class ArticlePage extends StatelessWidget {
  const ArticlePage({super.key});

  static const String pagePath = '/article';
  static const String pageName = 'article';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          ArticleViewModel(context: context, articleDataSource: ArticleRepo()),
      child: const ArticleWidget(),
    );
  }
}

class ArticleWidget extends StatefulWidget {
  const ArticleWidget({super.key});

  @override
  State<ArticleWidget> createState() => _ArticleWidgetState();
}

class _ArticleWidgetState extends State<ArticleWidget> {
  late final ArticleViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<ArticleViewModel>();
    _viewModel.attachContext(context);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _viewModel.fetchArticleList();
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
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Symbols.arrow_back,
                        color: AppColors.light,
                      ),
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else {
                          context.read<MainShellViewModel>().onTabTap(0);
                        }
                      },
                    ),
                    Expanded(
                      child: AppText(
                        'Article',
                        style: TextStyle(
                          color: AppColors.light,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Symbols.notifications,
                        color: AppColors.light,
                        fontWeight: FontWeight.bold,
                      ),
                      onPressed: () => context.push(NotificationPage.pagePath),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              Expanded(
                child: Consumer<ArticleViewModel>(
                  builder: (context, viewModel, child) {
                    final articleResult = viewModel.articleData;
                    final highlightResult = viewModel.articleHighlightData;

                    if (articleResult.isLoading || highlightResult.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.success,
                        ),
                      );
                    }

                    if (articleResult.hasError) {
                      return _buildErrorWidget();
                    }

                    final highlights = highlightResult.hasData
                        ? highlightResult.requireData
                        : <ArticleHighlightItem>[];
                    final articles = articleResult.hasData
                        ? articleResult.requireData.items
                        : <ArticleListItem>[];

                    return CustomScrollView(
                      slivers: [
                        if (highlights.isNotEmpty)
                          SliverToBoxAdapter(
                            child: _buildSection2(context, highlights),
                          ),
                        _buildSection3(context, articles),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection2(
      BuildContext context, List<ArticleHighlightItem> highlights) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CarouselSlider.builder(
          itemCount: highlights.length,
          itemBuilder: (context, index, realIndex) {
            final item = highlights[index];
            return _buildHighlightCard(item);
          },
          options: CarouselOptions(
            height: 180.h,
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
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              highlights.length,
              (index) => Selector<ArticleViewModel, int>(
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
        SizedBox(height: 16.h),
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
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildHighlightCard(ArticleHighlightItem item) {
    return GestureDetector(
      onTap: () => context.push(ArticleDetailPage.pathFor(item.id)),
      child: Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: AppColors.softDark,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Image.network(
          item.image,
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
      ),
    );
  }

  Widget _buildSection3(
      BuildContext context, List<ArticleListItem> articles) {
    if (articles.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Symbols.article,
                size: 64.sp,
                color: AppColors.light,
              ),
              SizedBox(height: 16.h),
              AppText(
                'Article',
                style: TextStyle(
                  color: AppColors.light,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              AppText(
                'No articles yet',
                style: TextStyle(
                  color: AppColors.light,
                  fontSize: 18.sp,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 24.h),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildArticleGridCard(articles[index]),
          childCount: articles.length,
        ),
      ),
    );
  }

  Widget _buildArticleGridCard(ArticleListItem article) {
    return GestureDetector(
      onTap: () => context.push(ArticleDetailPage.pathFor(article.id)),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.softDark,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: article.image != null
                            ? Image.network(
                                article.image!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppColors.dark,
                                    child: const Center(
                                      child: Icon(
                                        Symbols.broken_image,
                                        color: AppColors.light,
                                        size: 40,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: AppColors.softDark,
                                child: const Center(
                                  child: Icon(
                                    Symbols.broken_image,
                                    color: AppColors.light,
                                    size: 40,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: AppText(
                        article.title,
                        style: TextStyle(
                          color: AppColors.light,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Symbols.nest_clock_farsight_analog,
                          size: 14.sp,
                          color: AppColors.light,
                        ),
                        SizedBox(width: 4.w),
                        AppText(
                          article.publishDatetime ?? '',
                          style: TextStyle(
                            color: AppColors.light,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    final err = _viewModel.articleData.error;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Symbols.error_outline, color: AppColors.danger, size: 64.sp),
            SizedBox(height: 16.h),
            AppText(
              err?.toString().replaceFirst('Exception: ', '') ??
                  'เกิดข้อผิดพลาด',
              style: TextStyle(color: AppColors.light, fontSize: 16.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: _viewModel.fetchArticleList,
              icon: const Icon(Symbols.refresh, color: AppColors.light),
              label: AppText(
                'ลองใหม่อีกครั้ง',
                style: TextStyle(color: AppColors.light, fontSize: 18.sp),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
