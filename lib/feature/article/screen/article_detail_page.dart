import 'package:delta_compressor_202501017/core/const/app_color.dart';
import 'package:delta_compressor_202501017/core/widgets/app_text.dart';
import 'package:delta_compressor_202501017/feature/article/models/article_model.dart';
import 'package:delta_compressor_202501017/feature/article/repository/article_repo.dart';
import 'package:delta_compressor_202501017/feature/notification/screen/notification_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class ArticleDetailPage extends StatefulWidget {
  const ArticleDetailPage({super.key, required this.articleId});

  final String articleId;

  static const String pagePath = '/article-detail';
  static const String pageName = 'article-detail';

  static String pathFor(String articleId) => '$pagePath/$articleId';

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  ArticleListItem? _article;
  List<ArticleListItem> _relatedArticles = [];
  bool _isLoading = true;
  bool _isLoadingRelated = true;
  String? _errorMessage;
  final ArticleRepo _repo = ArticleRepo();

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _repo.fetchArticleDetail(widget.articleId);
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result.isSuccess) {
        _article = result.data;
        _loadRelatedArticles();
      } else {
        _article = null;
        _errorMessage = result.hasError
            ? result.error.toString().replaceFirst('Exception: ', '')
            : 'ไม่พบบทความนี้';
      }
    });
  }

  Future<void> _loadRelatedArticles() async {
    setState(() => _isLoadingRelated = true);

    final result = await _repo.fetchArticleKeepReading(widget.articleId);
    if (!mounted) return;

    setState(() {
      _isLoadingRelated = false;
      _relatedArticles = result.isSuccess ? result.data : [];
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
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.success),
                )
              : _article == null
              ? _buildError()
              : Column(
                  children: [
                    _buildAppBar(context),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeroImage(),
                            _buildArticleContent(),
                            _buildKeepReadingSection(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Symbols.arrow_back, color: AppColors.light),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: AppText(
              'Article Detail',
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
    );
  }

  Widget _buildHeroImage() {
    final imageUrl = _article!.image;
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      child: Container(
        width: double.infinity,
        height: 300.h,
        decoration: BoxDecoration(
          color: AppColors.softDark,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: imageUrl != null && imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildImagePlaceholder();
                  },
                )
              : _buildImagePlaceholder(),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.softDark,
      child: const Center(
        child: Icon(Symbols.broken_image, size: 64, color: AppColors.grey),
      ),
    );
  }

  Widget _buildArticleContent() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            _article!.title,
            style: TextStyle(
              color: AppColors.light,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          SizedBox(height: 12.h),
          if (_article!.publishDatetime != null &&
              _article!.publishDatetime!.isNotEmpty)
            Row(
              children: [
                Icon(
                  Symbols.nest_clock_farsight_analog,
                  size: 14.sp,
                  color: AppColors.light,
                ),
                SizedBox(width: 4.w),
                AppText(
                  _article!.publishDatetime!,
                  style: TextStyle(color: AppColors.light, fontSize: 14.sp),
                ),
              ],
            ),
          SizedBox(height: 16.h),
          AppText(
            _article!.detail ?? '',
            style: TextStyle(
              color: AppColors.light,
              fontSize: 16.sp,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeepReadingSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.dark,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      padding: EdgeInsets.all(18.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Keep Reading',
            style: TextStyle(
              color: AppColors.light,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            height: 2.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              gradient: LinearGradient(
                colors: [AppColors.danger, AppColors.light, AppColors.success],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          if (_isLoadingRelated)
            const Center(
              child: CircularProgressIndicator(color: AppColors.success),
            )
          else if (_relatedArticles.isEmpty)
            AppText(
              'ไม่มีบทความอื่น',
              style: TextStyle(color: AppColors.grey, fontSize: 16.sp),
            )
          else
            ..._relatedArticles.map(
              (article) => _buildRelatedArticleCard(article),
            ),
        ],
      ),
    );
  }

  Widget _buildRelatedArticleCard(ArticleListItem article) {
    return GestureDetector(
      onTap: () => context.push(ArticleDetailPage.pathFor(article.id)),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: AppColors.light,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.all(8.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: SizedBox(
                    width: 100.w,
                    child: article.image != null && article.image!.isNotEmpty
                        ? Image.network(
                            article.image!,
                            fit: BoxFit.cover,
                            height: 80.h,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildRelatedImagePlaceholder();
                            },
                          )
                        : _buildRelatedImagePlaceholder(),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        article.title,
                        style: TextStyle(
                          color: AppColors.dark,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      AppText(
                        article.detail ??
                            'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 14.sp,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRelatedImagePlaceholder() {
    return Container(
      width: 100.w,
      height: 80.h,
      color: AppColors.softDark.withValues(alpha: 0.3),
      child: const Center(
        child: Icon(Symbols.broken_image, color: AppColors.grey, size: 40),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Symbols.error_outline, color: AppColors.danger, size: 64.sp),
            SizedBox(height: 16.h),
            AppText(
              _errorMessage ?? 'ไม่พบบทความนี้',
              style: TextStyle(color: AppColors.light, fontSize: 16.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Symbols.arrow_back, color: AppColors.light),
              label: AppText(
                'กลับ',
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
