import 'package:delta_compressor_202501017/core/const/app_color.dart';
import 'package:delta_compressor_202501017/core/utils/ui_result.dart';
import 'package:delta_compressor_202501017/core/widgets/app_text.dart';
import 'package:delta_compressor_202501017/feature/article/models/article_model.dart';
import 'package:delta_compressor_202501017/feature/article/repository/article_repo.dart';
import 'package:delta_compressor_202501017/feature/article/viewmodel/article_viewmodel.dart';
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
      create: (context) => ArticleViewModel(
        context: context,
        articleDataSource: ArticleRepo(),
      ),
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
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Symbols.arrow_back,
                        color: AppColors.light,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
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
                      ),
                      onPressed: () => context.push(NotificationPage.pagePath),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Selector<ArticleViewModel, UiResult<ArticleListData>>(
                  selector: (context, provider) => provider.articleData,
                  builder: (context, result, child) {
                    if (result.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.success,
                        ),
                      );
                    }

                    if (result.hasError) {
                      return _buildErrorWidget();
                    }

                    if (result.isEmpty ||
                        (result.hasData && result.requireData.items.isEmpty)) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Symbols.article,
                              size: 64,
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
                      );
                    }

                    final data = result.requireData;
                    return CustomScrollView(
                      slivers: [
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = data.items[index];
                              return ListTile(
                                title: AppText(
                                  item.title,
                                  style: const TextStyle(
                                    color: AppColors.light,
                                  ),
                                ),
                                subtitle: item.publishDatetime != null
                                    ? AppText(
                                        item.publishDatetime!,
                                        style: TextStyle(
                                          color: AppColors.grey,
                                          fontSize: 12.sp,
                                        ),
                                      )
                                    : null,
                              );
                            },
                            childCount: data.items.length,
                          ),
                        ),
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

  Widget _buildErrorWidget() {
    final err = _viewModel.articleData.error;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Symbols.error_outline,
              color: AppColors.danger,
              size: 64.sp,
            ),
            SizedBox(height: 16.h),
            AppText(
              err?.toString().replaceFirst('Exception: ', '') ??
                  'เกิดข้อผิดพลาด',
              style: TextStyle(
                color: AppColors.light,
                fontSize: 16.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: _viewModel.fetchArticleList,
              icon: const Icon(Symbols.refresh, color: AppColors.light),
              label: AppText(
                'ลองใหม่อีกครั้ง',
                style: TextStyle(
                  color: AppColors.light,
                  fontSize: 18.sp,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
