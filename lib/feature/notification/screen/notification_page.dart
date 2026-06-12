import 'package:delta_compressor_202501017/core/const/app_color.dart';
import 'package:delta_compressor_202501017/core/utils/ui_result.dart';
import 'package:delta_compressor_202501017/core/widgets/app_refresh_indicator.dart';
import 'package:delta_compressor_202501017/core/widgets/app_text.dart';
import 'package:delta_compressor_202501017/feature/article/screen/article_detail_page.dart';
import 'package:delta_compressor_202501017/feature/notification/models/notification_model.dart';
import 'package:delta_compressor_202501017/feature/notification/repository/notification_repo.dart';
import 'package:delta_compressor_202501017/feature/notification/screen/alert_detail_page.dart';
import 'package:delta_compressor_202501017/feature/notification/screen/general_notification_detail_page.dart';
import 'package:delta_compressor_202501017/feature/notification/viewmodel/notification_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  static const String pagePath = '/notification';
  static const String pageName = 'notification';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NotificationViewModel(
        context: context,
        notificationDataSource: NotificationRepo(),
      ),
      child: const NotificationWidget(),
    );
  }
}

class NotificationWidget extends StatefulWidget {
  const NotificationWidget({super.key});

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  late final NotificationViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<NotificationViewModel>();
    _viewModel.attachContext(context);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _viewModel.fetchNotifications();
    });
  }

  Future<void> _onRefresh() =>
      _viewModel.fetchNotifications(forceRefresh: true);

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
                        'Notification',
                        style: TextStyle(
                          color: AppColors.light,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // เบลานซ์กับ IconButton ขวา
                  ],
                ),
              ),
              Expanded(
                child:
                    Selector<NotificationViewModel, UiResult<NotificationData>>(
                      selector: (context, provider) =>
                          provider.notificationData,
                      builder: (context, result, child) {
                        if (result.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.success,
                            ),
                          );
                        }

                        if (result.hasError) {
                          return AppRefreshIndicator(
                            onRefresh: _onRefresh,
                            child: AppRefreshScrollView(
                              child: _buildErrorWidget(),
                            ),
                          );
                        }

                        if (result.isEmpty ||
                            (result.hasData &&
                                result.requireData.items.isEmpty)) {
                          return AppRefreshIndicator(
                            onRefresh: _onRefresh,
                            child: AppRefreshScrollView(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Symbols.notifications,
                                      size: 64,
                                      color: AppColors.light,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    SizedBox(height: 16.h),
                                    AppText(
                                      'Notification',
                                      style: TextStyle(
                                        color: AppColors.light,
                                        fontSize: 22.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    AppText(
                                      'No notifications yet',
                                      style: TextStyle(
                                        color: AppColors.light,
                                        fontSize: 18.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        final data = result.requireData;
                        return AppRefreshIndicator(
                          onRefresh: _onRefresh,
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 16.h,
                            ),
                            itemCount: data.items.length,
                            itemBuilder: (context, index) {
                              return _buildNotificationCard(
                                context,
                                data.items[index],
                              );
                            },
                          ),
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
    final err = _viewModel.notificationData.error;
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
              onPressed: _viewModel.fetchNotifications,
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

  Widget _buildNotificationCard(BuildContext context, NotificationItem item) {
    if (item.type == 'article') {
      final article = item.article;
      if (article != null) return _buildArticleCard(context, article);
      return _buildInvalidCard('Article notification data is missing');
    }
    if (item.type == 'general') {
      final general = item.general;
      if (general != null) {
        return _buildGeneralCard(context, item.id, general);
      }
      return _buildInvalidCard('General notification data is missing');
    }
    final alert = item.alert;
    if (alert != null) {
      return _buildAlertCard(context, item.id, alert);
    }
    return _buildInvalidCard('Alert notification data is missing');
  }

  Widget _buildInvalidCard(String message) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.softDark,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.danger, width: 1),
      ),
      child: Row(
        children: [
          Icon(Symbols.error_outline, color: AppColors.danger, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: AppText(
              'ข้อมูลไม่ถูกต้อง',
              style: TextStyle(color: AppColors.danger, fontSize: 18.sp),
            ),
          ),
        ],
      ),
    );
  }

  void _openAlert(BuildContext context, String notificationId, AlertNotification alert) {
    final alertId = alert.id.isNotEmpty ? alert.id : notificationId;
    if (alertId.isEmpty) return;
    context.push(AlertDetailPage.pathFor(alertId));
  }

  void _openGeneral(BuildContext context, String notificationId) {
    if (notificationId.isEmpty) return;
    context.push(GeneralNotificationDetailPage.pathFor(notificationId));
  }

  void _openArticle(BuildContext context, ArticleNotification article) {
    if (article.id.isEmpty) return;
    context.push(ArticleDetailPage.pathFor(article.id));
  }

  Widget _buildArticleCard(BuildContext context, ArticleNotification article) {
    return GestureDetector(
      onTap: () => _openArticle(context, article),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.softDark,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    article.title,
                    style: TextStyle(
                      color: AppColors.light,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  AppText(
                    article.detail,
                    style: TextStyle(
                      color: AppColors.light,
                      fontSize: 18.sp,
                      height: 1,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  GestureDetector(
                    onTap: () => _openArticle(context, article),
                    child: AppText(
                      'อ่านเพิ่มเติม',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 18.sp,
                        height: 1,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.warning,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Symbols.access_time,
                        color: AppColors.light,
                        size: 18.sp,
                      ),
                      SizedBox(width: 4.w),
                      AppText(
                        article.articleDatetime,
                        style: TextStyle(
                          color: AppColors.light,
                          fontSize: 18.sp,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.network(
                article.image,
                width: 100.w,
                height: 100.w,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100.w,
                    height: 100.w,
                    color: AppColors.dark,
                    child: Icon(
                      Symbols.broken_image,
                      color: AppColors.light,
                      size: 40.sp,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(
    BuildContext context,
    String notificationId,
    AlertNotification alert,
  ) {
    return GestureDetector(
      onTap: () => _openAlert(context, notificationId, alert),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.softDark,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Symbols.warning, color: AppColors.danger, size: 24.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: AppText(
                    alert.title,
                    style: TextStyle(
                      color: AppColors.danger,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            AppText(
              'SERIAL NO : ${alert.serialNo}',
              style: TextStyle(
                color: AppColors.light,
                fontSize: 16.sp,
                height: 1,
              ),
            ),
            AppText(
              'MODEL : ${alert.model}',
              style: TextStyle(
                color: AppColors.light,
                fontSize: 16.sp,
                height: 1,
              ),
            ),
            AppText(
              alert.summary,
              style: TextStyle(
                color: AppColors.light,
                fontSize: 16.sp,
                height: 1,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
            AppText(
              'ดูรายละเอียด',
              style: TextStyle(
                color: AppColors.warning,
                fontSize: 18.sp,
                height: 1,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.warning,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Symbols.access_time, color: AppColors.light, size: 18.sp),
                SizedBox(width: 4.w),
                AppText(
                  alert.alertDatetime,
                  style: TextStyle(
                    color: AppColors.light,
                    fontSize: 18.sp,
                    height: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralCard(
    BuildContext context,
    String notificationId,
    GeneralNotification general,
  ) {
    return GestureDetector(
      onTap: () => _openGeneral(context, notificationId),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.softDark,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    general.title,
                    style: TextStyle(
                      color: AppColors.light,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  AppText(
                    general.detail,
                    style: TextStyle(
                      color: AppColors.light,
                      fontSize: 18.sp,
                      height: 1,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  AppText(
                    'ดูรายละเอียด',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontSize: 18.sp,
                      height: 1,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.warning,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Symbols.access_time,
                        color: AppColors.light,
                        size: 18.sp,
                      ),
                      SizedBox(width: 4.w),
                      AppText(
                        general.datetime,
                        style: TextStyle(
                          color: AppColors.light,
                          fontSize: 18.sp,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (general.image.isNotEmpty) ...[
              SizedBox(width: 16.w),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.network(
                  general.image,
                  width: 100.w,
                  height: 100.w,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100.w,
                      height: 100.w,
                      color: AppColors.dark,
                      child: Icon(
                        Symbols.broken_image,
                        color: AppColors.light,
                        size: 40.sp,
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
