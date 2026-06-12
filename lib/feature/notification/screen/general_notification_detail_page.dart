import 'package:delta_compressor_202501017/core/const/app_color.dart';
import 'package:delta_compressor_202501017/core/widgets/app_text.dart';
import 'package:delta_compressor_202501017/feature/article/screen/article_detail_page.dart';
import 'package:delta_compressor_202501017/feature/notification/models/notification_model.dart';
import 'package:delta_compressor_202501017/feature/notification/repository/notification_repo.dart';
import 'package:delta_compressor_202501017/feature/notification/screen/notification_page.dart';
import 'package:delta_compressor_202501017/feature/product/screen/product_detail_page.dart';
import 'package:delta_compressor_202501017/feature/service/screen/service_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class GeneralNotificationDetailPage extends StatefulWidget {
  const GeneralNotificationDetailPage({
    super.key,
    required this.notificationId,
  });

  final String notificationId;

  static const String pagePath = '/notifications';
  static const String pageName = 'notification-detail';

  static String pathFor(String notificationId) =>
      '$pagePath/$notificationId';

  @override
  State<GeneralNotificationDetailPage> createState() =>
      _GeneralNotificationDetailPageState();
}

class _GeneralNotificationDetailPageState
    extends State<GeneralNotificationDetailPage> {
  GeneralNotification? _notification;
  bool _isLoading = true;
  String? _errorMessage;
  final NotificationRepo _repo = NotificationRepo();

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

    final result =
        await _repo.fetchNotificationDetail(widget.notificationId);
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result.isSuccess) {
        _notification = result.data;
      } else {
        _notification = null;
        _errorMessage = result.hasError
            ? result.error.toString().replaceFirst('Exception: ', '')
            : 'ไม่พบการแจ้งเตือนนี้';
      }
    });
  }

  void _openAction() {
    final notification = _notification;
    if (notification == null || !notification.hasAction) return;

    switch (notification.actionType.toLowerCase()) {
      case 'product':
        context.push(ProductDetailPage.pathFor(notification.actionId));
      case 'service':
        context.push(ServiceDetailPage.pathFor(notification.actionId));
      case 'article':
        context.push(ArticleDetailPage.pathFor(notification.actionId));
    }
  }

  String _actionButtonLabel() {
    switch (_notification?.actionType.toLowerCase()) {
      case 'product':
        return 'ดู Product';
      case 'service':
        return 'ดู Service';
      case 'article':
        return 'อ่านบทความ';
      default:
        return 'ดูรายละเอียด';
    }
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
              : _notification == null
                  ? _buildError()
                  : Column(
                      children: [
                        _buildAppBar(context),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_notification!.image.isNotEmpty)
                                  _buildHeroImage(),
                                _buildContent(),
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
              'Notification Detail',
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
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      child: Container(
        width: double.infinity,
        height: 220.h,
        decoration: BoxDecoration(
          color: AppColors.softDark,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Image.network(
            _notification!.image,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.softDark,
                child: const Center(
                  child: Icon(
                    Symbols.broken_image,
                    size: 64,
                    color: AppColors.grey,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final notification = _notification!;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            notification.title,
            style: TextStyle(
              color: AppColors.light,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          if (notification.datetime.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(
                  Symbols.nest_clock_farsight_analog,
                  size: 14.sp,
                  color: AppColors.light,
                ),
                SizedBox(width: 4.w),
                AppText(
                  notification.datetime,
                  style: TextStyle(color: AppColors.light, fontSize: 14.sp),
                ),
              ],
            ),
          ],
          SizedBox(height: 16.h),
          AppText(
            notification.detail,
            style: TextStyle(
              color: AppColors.light,
              fontSize: 16.sp,
              height: 1.5,
            ),
          ),
          if (notification.hasAction) ...[
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _openAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: AppText(
                  _actionButtonLabel(),
                  style: TextStyle(
                    color: AppColors.light,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
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
              _errorMessage ?? 'ไม่พบการแจ้งเตือนนี้',
              style: TextStyle(color: AppColors.light, fontSize: 16.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: _loadDetail,
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
